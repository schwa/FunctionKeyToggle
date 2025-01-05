import SwiftUI
import Observation
import LaunchAtLogin
import KeyboardShortcuts
import UserNotifications

struct ContentView: View {

    @Environment(ViewModel.self)
    var viewModel

    @AppStorage("showMenuBarExtra")
    private var showMenuBarExtra = true

    @Environment(\.scenePhase) private var scenePhase


    var body: some View {
        @Bindable var viewModel = viewModel
        Form {
            AppIcon()
            Section("Function Keys") {
                Toggle("Function Key Mode", isOn: $viewModel.fnState)
                    .toggleStyle(.switch)
//                    .toggleStyle(MyToggleStyle(onLabel: Text("Function Keys"), offLabel: Text("Special")))
//                    .labelsHidden()
                KeyboardShortcuts.Recorder("Hot Key", name: .toggleFnState)
            }

            Section("Options") {
                Toggle("Show Menu Bar Extra", isOn: $showMenuBarExtra)
                    .toggleStyle(.switch)

                LaunchAtLogin.Toggle()
                    .toggleStyle(.switch)

                Toggle("Hide dock icon", isOn: $viewModel.dockIconHidden)


                Button("Quit") {
                    viewModel.quit()
                }

                Button("Send a test notification") {
                    let content = UNMutableNotificationContent()
                    content.title = "Test"
                    content.body = "Test"
                    content.sound = UNNotificationSound.default
                    content.interruptionLevel = .active
                    let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)

                }
            }
        }
        .padding()
        .onChange(of: scenePhase) {
            print(scenePhase)
        }
        .onAppear {
            viewModel.pauseMonitoring = false
        }
        .onDisappear {
            viewModel.pauseMonitoring = true
        }
    }
}

#Preview {
    ContentView()
}

//defaults read -g com.apple.keyboard.fnState

struct MyToggleStyle <OnLabel, OffLabel>: ToggleStyle where OnLabel: View, OffLabel: View {

    var onLabel: OnLabel
    var offLabel: OffLabel

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            onLabel
                .opacity(configuration.isOn ? 1 : 0.5)
                .background(configuration.isOn ? Color.blue : Color.white, in: RoundedRectangle(cornerRadius: 8))
                .padding(.trailing, 1)
                .foregroundStyle(configuration.isOn ? Color.white : Color.black)
            offLabel
                .opacity(!configuration.isOn ? 1 : 0.5)
                .background(!configuration.isOn ? Color.blue : Color.white, in: RoundedRectangle(cornerRadius: 8))
                .padding(.leading, 1)
                .foregroundStyle(!configuration.isOn ? Color.white : Color.black)
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }

}

struct AppIcon: View {
    var body: some View {



        let icon = NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
        return Image(nsImage: icon)


    }
}
