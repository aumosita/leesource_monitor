import SwiftUI

@main
struct LeeSourceMonitorApp: App {
    @State private var monitor = SystemMonitor()
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
            DashboardView(monitor: monitor)
                .frame(minWidth: 600, minHeight: 400)
        }
        .defaultSize(width: 900, height: 650)
        .keyboardShortcut("d", modifiers: .command)
    }
}

// Make the app show in Cmd+Tab when dashboard is open
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start as regular app (shows in Dock and Cmd+Tab)
        NSApplication.shared.setActivationPolicy(.regular)
    }
}
