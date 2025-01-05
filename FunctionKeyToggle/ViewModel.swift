import SwiftUI
import Observation
import LaunchAtLogin
import KeyboardShortcuts
import UserNotifications

extension KeyboardShortcuts.Name {
    static let toggleFnState = Self("toggleFnState")
}

@Observable
class ViewModel {
    var enableDefaultsWrite: Bool = true

    var dockIconHidden: Bool {
        get {
            NSApplication.shared.activationPolicy() == .accessory
        }
        set {
            NSApplication.shared.setActivationPolicy(newValue ? .accessory : .regular)
        }
    }

    var fnState: Bool {
        willSet {
            defaultsMonitoringTask?.cancel()
        }
        didSet {
            if fnState != oldValue {
                setFnState(fnState)
            }
            restartDefaultsMonitoringTask()
        }
    }

    var pauseMonitoring: Bool = true {
        didSet {
            restartDefaultsMonitoringTask()
        }
    }
    var defaultsMonitoringTask: Task<(), any Error>?

    init() {
        fnState = UserDefaults.standard.bool(forKey: "com.apple.keyboard.fnState")

        KeyboardShortcuts.onKeyUp(for: .toggleFnState) { [self] in
            fnState.toggle()
        }

        let center = UNUserNotificationCenter.current()

        Task {
            do {
                try await center.requestAuthorization(options: [.alert, .sound, .provisional, .providesAppNotificationSettings])
            } catch {
                print(error)
            }
        }

        restartDefaultsMonitoringTask()

//        if let s = KeyboardShortcuts.getShortcut(for: .toggleFnState) {
//            print(s.modifiers)
//            print(s.key)
//        }
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }

    func restartDefaultsMonitoringTask() {
        defaultsMonitoringTask?.cancel()
        guard pauseMonitoring == false else {
            return
        }
        defaultsMonitoringTask = Task {
            while Task.isCancelled == false {
                print("TICK")
                try await Task.sleep(nanoseconds: 500_000_000)
                enableDefaultsWrite = false
                fnState = UserDefaults.standard.bool(forKey: "com.apple.keyboard.fnState")
                enableDefaultsWrite = true
            }
        }
    }

    func setFnState(_ value: Bool) {
        guard enableDefaultsWrite == true else {
            return
        }
        let standardOutput = Pipe()
        let standardError = Pipe()
        let p = Process()
        p.launchPath = "/usr/bin/defaults"
        p.arguments = ["write", "-g", "com.apple.keyboard.fnState", "-bool", value ? "true" : "false"]
        p.standardOutput = standardOutput
        p.standardError = standardError
        try! p.run()
        p.waitUntilExit()
        print("Termination status", p.terminationStatus)
        print("Stderr", String(data: standardError.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!)
        print("Stdout", String(data: standardOutput.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!)
    }
}

extension View {
    func keyboardShortcut(for shortcut: KeyboardShortcuts.Name) -> some View {
//        if let shortcut = KeyboardShortcuts.getShortcut(for: shortcut) {
//            return self.keyboardShortcut("F", modifiers: [.command])
//        }
//        else {
            return self
//        }
    }
}
