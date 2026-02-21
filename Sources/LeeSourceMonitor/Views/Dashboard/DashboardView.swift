import SwiftUI

struct DashboardView: View {
    var monitor: SystemMonitor
    var settings: AppSettings

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let columns: Int = w > 1100 ? 4 : w > 750 ? 3 : w > 400 ? 2 : 1
            let gridItems = Array(repeating: GridItem(.flexible(), spacing: AppTheme.Dimensions.gridSpacing), count: columns)

            ScrollView {
                LazyVGrid(columns: gridItems, spacing: AppTheme.Dimensions.gridSpacing) {
                    ForEach(settings.visibleCards) { card in
                        cardView(for: card, columns: columns)
                    }
                }
                .padding(AppTheme.Dimensions.gridSpacing)
            }
        }
        .background(AppTheme.Colors.background)
        .onAppear {
            monitor.startMonitoring()
        }
    }

    @ViewBuilder
    private func cardView(for card: AppSettings.CardType, columns: Int) -> some View {
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
            .gridCellColumns(min(columns, 2))
        }
    }
}
