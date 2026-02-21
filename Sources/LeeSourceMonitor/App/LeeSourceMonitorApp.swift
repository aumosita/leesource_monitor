import SwiftUI

@main
struct LeeSourceMonitorApp: App {
    @State private var monitor = SystemMonitor()

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
                .frame(minWidth: 800, idealWidth: 1000, minHeight: 600, idealHeight: 800)
        }
        .defaultSize(width: 1000, height: 800)
        .keyboardShortcut("d", modifiers: .command)
    }
}
