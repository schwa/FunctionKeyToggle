import SwiftUI

struct MenuExtra: Scene {
    @Environment(ViewModel.self)
    var viewModel

    @AppStorage("showMenuBarExtra")
    private var showMenuBarExtra = true

    var body: some Scene {
        @Bindable var viewModel = viewModel
        MenuBarExtra("fn", image: "custom.fn.square", isInserted: $showMenuBarExtra) {
            Toggle("Toggle Function Keys", isOn: $viewModel.fnState)
                .keyboardShortcut(for: .toggleFnState)
            Divider()
            SettingsLink()
                .keyboardShortcut(",", modifiers: [.command])
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
                .keyboardShortcut("Q", modifiers: [.command])
        }

    }
}

