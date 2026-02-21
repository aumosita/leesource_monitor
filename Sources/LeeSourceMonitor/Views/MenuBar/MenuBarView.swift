import SwiftUI

struct MenuBarView: View {
    var monitor: SystemMonitor
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "gauge.with.dots.needle.33percent")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.cyan)
                Text("LeeSource Monitor")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()
                .padding(.horizontal, 8)

            ScrollView {
                VStack(spacing: 8) {
                    // CPU
                    MenuBarMetricRow(
                        icon: "cpu",
                        label: "CPU",
                        value: Formatters.percentage(monitor.cpu.totalUsage),
                        color: AppTheme.Colors.cpuGradientStart,
                        progress: monitor.cpu.totalUsage / 100
                    )

                    // GPU
                    MenuBarMetricRow(
                        icon: "gpu",
                        label: "GPU",
                        value: Formatters.percentage(monitor.gpu.deviceUtilization),
                        color: AppTheme.Colors.gpuGradientStart,
                        progress: monitor.gpu.deviceUtilization / 100
                    )

                    // Memory
                    MenuBarMetricRow(
                        icon: "memorychip",
                        label: "MEM",
                        value: Formatters.percentage(monitor.memory.pressure),
                        color: .cyan,
                        progress: monitor.memory.pressure / 100
                    )

                    Divider()
                        .padding(.horizontal, 8)

                    // Network
                    HStack(spacing: 12) {
                        Image(systemName: "network")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.Colors.networkIn)
                            .frame(width: 16)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.networkIn)
                                Text(Formatters.speed(monitor.network.speedIn))
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(AppTheme.Colors.networkOut)
                                Text(Formatters.speed(monitor.network.speedOut))
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)

                    Divider()
                        .padding(.horizontal, 8)

                    // Temperature (top sensors)
                    let topSensors = Array(monitor.temperature.sensors.prefix(4))
                    if !topSensors.isEmpty {
                        VStack(spacing: 4) {
                            ForEach(topSensors) { sensor in
                                HStack {
                                    Image(systemName: "thermometer.medium")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.orange)
                                        .frame(width: 16)
                                    Text(sensor.name)
                                        .font(.system(size: 11))
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(Formatters.temperature(sensor.temperature))
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundStyle(tempColor(sensor.temperature))
                                }
                                .padding(.horizontal, 12)
                            }
                        }

                        Divider()
                            .padding(.horizontal, 8)
                    }

                    // Disk
                    if let mainVolume = monitor.disk.volumes.first {
                        HStack {
                            Image(systemName: "internaldrive")
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.Colors.diskUsed)
                                .frame(width: 16)

                            Text(mainVolume.name)
                                .font(.system(size: 11))
                                .foregroundStyle(AppTheme.Colors.textSecondary)

                            Spacer()

                            Text("\(Formatters.gigabytes(mainVolume.freeGB)) free")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                        }
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(maxHeight: 350)

            Divider()
                .padding(.horizontal, 8)

            // Open Dashboard button
            Button {
                NSApplication.shared.activate()
                openWindow(id: "dashboard")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    for window in NSApplication.shared.windows {
                        if window.title == "LeeSource Monitor" {
                            window.makeKeyAndOrderFront(nil)
                            window.orderFrontRegardless()
                            break
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "square.grid.2x2")
                    Text("Open Dashboard")
                    Spacer()
                    Text("⌘D")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)

            Divider()
                .padding(.horizontal, 8)

            // Quit button
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack {
                    Image(systemName: "power")
                    Text("Quit")
                    Spacer()
                    Text("⌘Q")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)
        }
        .frame(width: AppTheme.Dimensions.menuBarWidth)
        .onAppear {
            monitor.startMonitoring()
        }
    }

    private func tempColor(_ temp: Double) -> Color {
        if temp < 40 { return .green }
        if temp < 70 { return .orange }
        return .red
    }
}

private struct MenuBarMetricRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let progress: Double

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .frame(width: 28, alignment: .leading)

            UsageBar(value: progress * 100, maxValue: 100, color: color, height: 4)

            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .frame(width: 45, alignment: .trailing)
        }
        .padding(.horizontal, 12)
    }
}
