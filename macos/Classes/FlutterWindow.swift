//
//  FlutterWindow.swift
//  flutter_multi_window
//
//  Created by Bin Yang on 2022/1/10.
//
import Cocoa
import FlutterMacOS
import Foundation

class BaseFlutterWindow: NSObject {
  private let window: NSWindow
  let windowChannel: WindowChannel
  public var onEvent:((String) -> Void)?
  public var _isPreventClose: Bool = false
  public var _isMaximized: Bool = false

  init(window: NSWindow, channel: WindowChannel) {
    self.window = window
    self.windowChannel = channel
    super.init()
  }

  func show() {
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  func hide() {
    window.orderOut(nil)
  }

  func center() {
    window.center()
  }

  func focus() {
    window.deminiaturize(nil)
    NSApp.activate(ignoringOtherApps: false)
    window.makeKeyAndOrderFront(nil)
  }

  func showTitleBar(show: Bool) {
    if (show) {
      // ignore
    } else {
      window.styleMask.insert(.fullSizeContentView)
      window.titleVisibility = .hidden
      window.isOpaque = true
      window.hasShadow = false
      window.backgroundColor = NSColor.clear
      if (window.styleMask.contains(.titled)) {
          let titleBarView: NSView = (window.standardWindowButton(.closeButton)?.superview)!.superview!
          titleBarView.isHidden = true
      }
    }
  }

  func isMaximized() -> Bool {
    return window.isZoomed
  }

  func maximize() {
    if (!isMaximized()) {
        window.zoom(nil);
    }
  }
    
  func unmaximize() {
    if (isMaximized()) {
        window.zoom(nil);
    }
  }

  func minimize() {
      window.miniaturize(nil)
  }

  func setFullscreen(fullscreen: Bool) {
    if (fullscreen) {
      if (!window.styleMask.contains(.fullScreen)) {
          window.toggleFullScreen(nil)
      }
    } else {
      if (window.styleMask.contains(.fullScreen)) {
          window.toggleFullScreen(nil)
      }
    }
  }

  func setFrame(frame: NSRect) {
    window.setFrame(frame, display: false, animate: true)
  }

  func getFrame() -> NSDictionary {
    let frameRect: NSRect = window.frame;
    
    let data: NSDictionary = [
        "x": frameRect.topLeft.x,
        "y": frameRect.topLeft.y,
        "width": frameRect.size.width,
        "height": frameRect.size.height,
    ]
    return data;
  }

  func setTitle(title: String) {
    window.title = title
  }

  func close() {
    window.close()
  }

  func setFrameAutosaveName(name: String) {
    window.setFrameAutosaveName(name)
  }

  func startDragging() {
    DispatchQueue.main.async {
      let this: NSWindow  = self.window
      if(this.currentEvent != nil) {
          this.performDrag(with: this.currentEvent!)
      }
    }
  }

  func startResizing(arguments: [String: Any?]) {
    // ignore
  }
}

class FlutterWindow: BaseFlutterWindow {
  let windowId: Int64

  let window: NSWindow

  weak var delegate: WindowManagerDelegate?

  init(id: Int64, arguments: String) {
    windowId = id
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
      styleMask: [.miniaturizable, .closable, .resizable, .titled, .fullSizeContentView],
      backing: .buffered, defer: false)
    let project = FlutterDartProject()
    project.dartEntrypointArguments = ["multi_window", "\(windowId)", arguments]
    let flutterViewController = FlutterViewController(project: project)
    window.contentViewController = flutterViewController

    FlutterMultiWindowPlugin.RegisterGeneratedPlugins?(flutterViewController)
    let plugin = flutterViewController.registrar(forPlugin: "FlutterMultiWindowPlugin")
    FlutterMultiWindowPlugin.registerInternal(with: plugin)
    let windowChannel = WindowChannel.register(with: plugin, windowId: id)
    // Give app a chance to register plugin.
    FlutterMultiWindowPlugin.onWindowCreatedCallback?(flutterViewController)

    super.init(window: window, channel: windowChannel)

    window.delegate = self
    window.isReleasedWhenClosed = false
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
  }

  deinit {
    debugPrint("release window resource")
    window.delegate = nil
    if let flutterViewController = window.contentViewController as? FlutterViewController {
      flutterViewController.engine.shutDownEngine()
    }
    window.contentViewController = nil
    window.windowController = nil
  }
}

extension FlutterWindow: NSWindowDelegate {
  func windowWillClose(_ notification: Notification) {
    delegate?.onClose(windowId: windowId)
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    _emitEvent("close")
    delegate?.onClose(windowId: windowId)
    return true
  }
    
    public func windowDidResize(_ notification: Notification) {
        _emitEvent("resize")
        if (!_isMaximized && window.isZoomed) {
            _isMaximized = true
            _emitEvent("maximize")
        }
        if (_isMaximized && !window.isZoomed) {
            _isMaximized = false
            _emitEvent("unmaximize")
        }
    }
    
    public func windowDidEndLiveResize(_ notification: Notification) {
        _emitEvent("resized")
    }
    
    public func windowWillMove(_ notification: Notification) {
        _emitEvent("move")
    }
    
    public func windowDidMove(_ notification: Notification) {
        _emitEvent("moved")
    }
    
    public func windowDidBecomeMain(_ notification: Notification) {
        _emitEvent("focus");
    }
    
    public func windowDidResignMain(_ notification: Notification){
        _emitEvent("blur");
    }
    
    public func windowDidMiniaturize(_ notification: Notification) {
        _emitEvent("minimize");
    }
    
    public func windowDidDeminiaturize(_ notification: Notification) {
        _emitEvent("restore");
    }
    
    public func windowDidEnterFullScreen(_ notification: Notification){
        _emitEvent("enter-full-screen");
    }
    
    public func windowDidExitFullScreen(_ notification: Notification){
        _emitEvent("leave-full-screen");
    }
    
    public func _emitEvent(_ eventName: String) {
        let args: NSDictionary = [
            "eventName": eventName,
        ]
        windowChannel.invokeMethod(fromWindowId: 0 , method: "onEvent", arguments: args, result: nil)
    }
}


extension NSRect {
    var topLeft: CGPoint {
        set {
            let screenFrameRect = NSScreen.main!.frame
            origin.x = newValue.x
            origin.y = screenFrameRect.height - newValue.y - size.height
        }
        get {
            let screenFrameRect = NSScreen.main!.frame
            return CGPoint(x: origin.x, y: screenFrameRect.height - origin.y - size.height)
        }
    }
}
