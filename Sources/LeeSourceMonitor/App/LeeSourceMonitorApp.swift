import SwiftUI

@main
struct LeeSourceMonitorApp: App {
    @State private var monitor = SystemMonitor()
    @State private var settings = AppSettings.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar
        MenuBarExtra {
            MenuBarView(monitor: monitor)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "gauge.with.dots.needle.33percent")
                Text("\(Int(monitor.cpu.totalUsage))%")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
        }
        .menuBarExtraStyle(.window)

        // Main window
        Window("LeeSource Monitor", id: "dashboard") {
            DashboardView(monitor: monitor, settings: settings)
                .frame(minWidth: 250, minHeight: 300)
        }
        .defaultSize(width: 900, height: 650)
        .keyboardShortcut("d", modifiers: .command)

        // Settings
        Settings {
            SettingsView(settings: settings, monitor: monitor)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.regular)

        if let iconURL = Bundle.module.url(forResource: "AppIcon", withExtension: "png"),
           let iconImage = NSImage(contentsOf: iconURL) {
            NSApplication.shared.applicationIconImage = iconImage
        }
    }
}
