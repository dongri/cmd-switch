import AppKit
import SwiftUI

@main
struct CmdSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var inputSourceManager = InputSourceManager.shared

    var body: some Scene {
        MenuBarExtra("Cmd Switch", systemImage: "command") {
            ContentView()
                .environmentObject(inputSourceManager)
                .onAppear {
                    appDelegate.manualStart()
                }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)
        }
        .menuBarExtraStyle(.window)
    }
}
