import SwiftUI

struct DashboardView: View {
    var monitor: SystemMonitor
    var settings: AppSettings

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let isMicro = w < 200
            let padding = isMicro ? CGFloat(4) : AppTheme.Dimensions.gridSpacing
            let spacing = isMicro ? CGFloat(4) : AppTheme.Dimensions.gridSpacing

            // Estimate card width for expanded mode
            let minCardWidth: CGFloat = 160
            let availableWidth = w - padding * 2
            let columnCount = max(Int(availableWidth / (minCardWidth + spacing)), 1)
            let cardWidth = (availableWidth - CGFloat(columnCount - 1) * spacing) / CGFloat(columnCount)
            let isExpanded = cardWidth > 300

            ScrollView {
                if isMicro {
                    VStack(spacing: spacing) {
                        ForEach(settings.visibleCards) { card in
                            cardView(for: card, expanded: false)
                        }
                    }
                    .padding(padding)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: minCardWidth), spacing: spacing)],
                        spacing: spacing
                    ) {
                        ForEach(settings.visibleCards) { card in
                            cardView(for: card, expanded: isExpanded)
                                .frame(minHeight: isExpanded ? 260 : nil, alignment: .top)
                        }
                    }
                    .padding(padding)
                }
            }
        }
        .background(AppTheme.Colors.background)
        .onAppear {
            monitor.startMonitoring()
            settings.applyWindowLevel()
        }
    }

    @ViewBuilder
    private func cardView(for card: AppSettings.CardType, expanded: Bool) -> some View {
        switch card {
        case .cpu:
            CPUChartView(
                metrics: monitor.cpu,
                history: monitor.cpuHistory,
                coreHistory: monitor.cpuCoreHistory,
                expanded: expanded
            )
        case .memory:
            MemoryChartView(
                metrics: monitor.memory,
                gpuMetrics: monitor.gpu,
                readHistory: monitor.memoryReadHistory,
                writeHistory: monitor.memoryWriteHistory,
                appHistory: monitor.memoryAppHistory,
                systemHistory: monitor.memorySystemHistory,
                compressedHistory: monitor.memoryCompressedHistory,
                expanded: expanded
            )
        case .gpu:
            GPUChartView(
                metrics: monitor.gpu,
                history: monitor.gpuHistory,
                expanded: expanded
            )
        case .network:
            NetworkChartView(
                metrics: monitor.network,
                inHistory: monitor.networkInHistory,
                outHistory: monitor.networkOutHistory,
                expanded: expanded
            )
        case .disk:
            DiskView(metrics: monitor.disk)
        case .npu:
            NPUView(
                metrics: monitor.npu,
                history: monitor.npuHistory,
                expanded: expanded
            )
        case .temperature:
            TemperatureView(
                metrics: monitor.temperature,
                history: monitor.temperatureHistory
            )
        }
    }
}
