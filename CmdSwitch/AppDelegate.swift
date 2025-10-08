import ApplicationServices
import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private var leftCommandKeyCode: CGKeyCode = 55
    private var rightCommandKeyCode: CGKeyCode = 54
    private var currentPressedKeyCode: CGKeyCode?
    private var otherKeyPressed = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        requestInputMonitoringPermission()
        startEventTap()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopEventTap()
    }
    
    func manualStart() {
        requestInputMonitoringPermission()
        startEventTap()
    }

    private func startEventTap() {
        guard eventTap == nil else {
            return
        }
        
        let eventMask = (1 << CGEventType.flagsChanged.rawValue) | (1 << CGEventType.keyDown.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passUnretained(event)
                }
                let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon).takeUnretainedValue()
                return appDelegate.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func stopEventTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
            eventTap = nil
            runLoopSource = nil
        }
    }

    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case .flagsChanged:
            return handleFlagsChanged(event: event)
        case .keyDown:
            return handleKeyDown(event: event)
        default:
            return Unmanaged.passUnretained(event)
        }
    }

    private func handleFlagsChanged(event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags
        let isCommandDown = flags.contains(.maskCommand)
        
        if keyCode == leftCommandKeyCode || keyCode == rightCommandKeyCode {
            if isCommandDown {
                currentPressedKeyCode = keyCode
                otherKeyPressed = false
            } else if let pressedKey = currentPressedKeyCode, pressedKey == keyCode {
                if !otherKeyPressed {
                    switchInputSource(for: keyCode)
                }
                currentPressedKeyCode = nil
            }
        }
        
        return Unmanaged.passUnretained(event)
    }

    private func handleKeyDown(event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        
        if keyCode != leftCommandKeyCode && keyCode != rightCommandKeyCode {
            otherKeyPressed = true
        }
        
        return Unmanaged.passUnretained(event)
    }

    private func switchInputSource(for keyCode: CGKeyCode) {
        let manager = InputSourceManager.shared
        
        if keyCode == leftCommandKeyCode {
            manager.switchToLeftCommandLayout()
        } else if keyCode == rightCommandKeyCode {
            manager.switchToRightCommandLayout()
        }
    }

    private func requestInputMonitoringPermission() {
        guard AXIsProcessTrusted() == false else {
            return
        }
        
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }
}
