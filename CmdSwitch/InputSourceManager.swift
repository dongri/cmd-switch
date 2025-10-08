import Combine
import Carbon
import Foundation
import AppKit

struct InputSource: Identifiable, Hashable {
    let id: String
    let localizedName: String
}

final class InputSourceManager: ObservableObject {
    static let shared = InputSourceManager()
    
    @Published private(set) var availableSources: [InputSource] = []
    @Published var leftCommandSourceID: String? = nil {
        didSet {
            guard oldValue != leftCommandSourceID else { return }
            if let leftCommandSourceID {
                UserDefaults.standard.set(leftCommandSourceID, forKey: Self.leftCommandSourceDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.leftCommandSourceDefaultsKey)
            }
        }
    }
    @Published var rightCommandSourceID: String? = nil {
        didSet {
            guard oldValue != rightCommandSourceID else { return }
            if let rightCommandSourceID {
                UserDefaults.standard.set(rightCommandSourceID, forKey: Self.rightCommandSourceDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.rightCommandSourceDefaultsKey)
            }
        }
    }

    private static let leftCommandSourceDefaultsKey = "LeftCommandSourceID"
    private static let rightCommandSourceDefaultsKey = "RightCommandSourceID"
    
    private init() {
        let sources = Self.loadAvailableSources()
        availableSources = sources

        let savedLeft = UserDefaults.standard.string(forKey: Self.leftCommandSourceDefaultsKey)
        if let savedLeft, sources.contains(where: { $0.id == savedLeft }) {
            leftCommandSourceID = savedLeft
        } else {
            leftCommandSourceID = nil
        }

        let savedRight = UserDefaults.standard.string(forKey: Self.rightCommandSourceDefaultsKey)
        if let savedRight, sources.contains(where: { $0.id == savedRight }) {
            rightCommandSourceID = savedRight
        } else {
            rightCommandSourceID = nil
        }
    }

    func refreshSources() {
        let sources = Self.loadAvailableSources()
        availableSources = sources

        if let leftCommandSourceID, sources.contains(where: { $0.id == leftCommandSourceID }) == false {
            self.leftCommandSourceID = nil
        }

        if let rightCommandSourceID, sources.contains(where: { $0.id == rightCommandSourceID }) == false {
            self.rightCommandSourceID = nil
        }
    }

    func switchToLeftCommandLayout() {
        guard let leftCommandSourceID else { return }
        selectInputSource(withIdentifier: leftCommandSourceID)
    }

    func switchToRightCommandLayout() {
        guard let rightCommandSourceID else { return }
        selectInputSource(withIdentifier: rightCommandSourceID)
    }
    
    func getCurrentInputSourceID() -> String? {
        guard let currentSource = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return nil
        }
        return Self.property(for: currentSource, key: kTISPropertyInputSourceID)
    }
}

private extension InputSourceManager {
    static func loadAvailableSources() -> [InputSource] {
        let filter = [
            kTISPropertyInputSourceIsSelectCapable: true
        ] as CFDictionary

        guard let list = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }

        let allowedCategories: Set<String> = [
            String(kTISCategoryKeyboardInputSource),
            "TISCategoryInputMethod"
        ]

        return list.compactMap { source in
            let category = property(for: source, key: kTISPropertyInputSourceCategory) as String?
            guard let category, allowedCategories.contains(category) else { return nil }
            let identifier = property(for: source, key: kTISPropertyInputSourceID) as String?
            let localizedName = property(for: source, key: kTISPropertyLocalizedName) as String?
            guard let identifier, let localizedName else { return nil }
            return InputSource(id: identifier, localizedName: localizedName)
        }
        .sorted { $0.localizedName.localizedCaseInsensitiveCompare($1.localizedName) == .orderedAscending }
    }

    func selectInputSource(withIdentifier identifier: String) {
        // print("Selecting input source with identifier: \(identifier)")
        let isJapanese = identifier.contains(".Japanese")
        let isABC = identifier.contains(".ABC")

        if isJapanese {
            postKeyEvent(keyCode: 104)
            return
        }
        
        if isABC {
            postKeyEvent(keyCode: 102)
            return
        }

        let filter = [kTISPropertyInputSourceID: identifier] as CFDictionary
        guard let list = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource],
              let source = list.first else {
            return
        }
        
        let status = TISSelectInputSource(source)
        if status != noErr {
            return
        }
    }
    
    func postKeyEvent(keyCode: CGKeyCode) {
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            return
        }
        
        guard let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
              let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
            return
        }
        
        keyDownEvent.flags = CGEventFlags()
        keyUpEvent.flags = CGEventFlags()
        
        let location = CGEventTapLocation.cghidEventTap
        keyDownEvent.post(tap: location)
        keyUpEvent.post(tap: location)
    }

    static func property<T>(for source: TISInputSource, key: CFString) -> T? {
        guard let rawValue = TISGetInputSourceProperty(source, key) else { return nil }
        let unmanaged = Unmanaged<AnyObject>.fromOpaque(rawValue)
        return unmanaged.takeUnretainedValue() as? T
    }
}
