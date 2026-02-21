import SwiftUI

struct DashboardView: View {
    var monitor: SystemMonitor
    var settings: AppSettings

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let isMicro = w < 200

            ScrollView {
                if isMicro {
                    // Micro mode: single column, no charts
                    VStack(spacing: 4) {
                        ForEach(settings.visibleCards) { card in
                            microCardView(for: card)
                        }
                    }
                    .padding(4)
                } else {
                    // Normal adaptive grid
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 160), spacing: AppTheme.Dimensions.gridSpacing)],
                        spacing: AppTheme.Dimensions.gridSpacing
                    ) {
                        ForEach(settings.visibleCards) { card in
                            cardView(for: card)
                        }
                    }
                    .padding(AppTheme.Dimensions.gridSpacing)
                }
            }
        }
        .background(AppTheme.Colors.background)
        .onAppear {
            monitor.startMonitoring()
            settings.applyWindowLevel()
        }
    }

    // MARK: - Micro card (no chart, just title + value)
    @ViewBuilder
    private func microCardView(for card: AppSettings.CardType) -> some View {
        HStack(spacing: 6) {
            Image(systemName: card.icon)
                .font(.system(size: 10))
                .foregroundStyle(accentColor(for: card))
                .frame(width: 14)

            Text(card.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Text(valueText(for: card))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(accentColor(for: card))
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(AppTheme.Colors.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
                }
        }
    }

    // MARK: - Normal card
    @ViewBuilder
    private func cardView(for card: AppSettings.CardType) -> some View {
        switch card {
        case .cpu:
            CPUChartView(
                metrics: monitor.cpu,
                history: monitor.cpuHistory,
                coreHistory: monitor.cpuCoreHistory,
                compact: true
            )
        case .memory:
            MemoryChartView(
                metrics: monitor.memory,
                pressureHistory: monitor.memoryPressureHistory,
                readHistory: monitor.memoryReadHistory,
                writeHistory: monitor.memoryWriteHistory,
                compact: true
            )
        case .gpu:
            GPUChartView(
                metrics: monitor.gpu,
                history: monitor.gpuHistory,
                compact: true
            )
        case .network:
            NetworkChartView(
                metrics: monitor.network,
                inHistory: monitor.networkInHistory,
                outHistory: monitor.networkOutHistory,
                compact: true
            )
        case .disk:
            DiskView(metrics: monitor.disk)
        case .npu:
            NPUView(
                metrics: monitor.npu,
                history: monitor.npuHistory
            )
        case .temperature:
            TemperatureView(
                metrics: monitor.temperature,
                history: monitor.temperatureHistory
            )
        }
    }

    // MARK: - Helpers
    private func valueText(for card: AppSettings.CardType) -> String {
        switch card {
        case .cpu: return Formatters.percentage(monitor.cpu.totalUsage)
        case .memory: return Formatters.percentage(monitor.memory.pressure)
        case .gpu: return Formatters.percentage(monitor.gpu.deviceUtilization)
        case .network: return "↓\(Formatters.speed(monitor.network.speedIn))"
        case .disk:
            if let v = monitor.disk.volumes.first { return Formatters.percentage(v.usagePercent) }
            return "—"
        case .npu: return Formatters.milliwatts(monitor.npu.powerMilliwatts)
        case .temperature:
            if let h = monitor.temperature.sensors.max(by: { $0.temperature < $1.temperature }) {
                return Formatters.temperature(h.temperature)
            }
            return "—"
        }
    }

    private func accentColor(for card: AppSettings.CardType) -> Color {
        switch card {
        case .cpu: return AppTheme.Colors.cpuGradientStart
        case .memory: return .cyan
        case .gpu: return AppTheme.Colors.gpuGradientStart
        case .network: return AppTheme.Colors.networkIn
        case .disk: return AppTheme.Colors.diskUsed
        case .npu: return AppTheme.Colors.npuActive
        case .temperature: return .orange
        }
    }
}
