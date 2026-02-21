import SwiftUI

struct DashboardView: View {
    var monitor: SystemMonitor

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let columns: Int = w > 1100 ? 4 : w > 750 ? 3 : w > 500 ? 2 : 1
            let gridItems = Array(repeating: GridItem(.flexible(), spacing: AppTheme.Dimensions.gridSpacing), count: columns)
            let tempColumns = columns >= 2 ? 2 : 1

            ScrollView {
                LazyVGrid(columns: gridItems, spacing: AppTheme.Dimensions.gridSpacing) {
                    CPUChartView(
                        metrics: monitor.cpu,
                        history: monitor.cpuHistory,
                        coreHistory: monitor.cpuCoreHistory,
                        compact: true
                    )

                    MemoryChartView(
                        metrics: monitor.memory,
                        pressureHistory: monitor.memoryPressureHistory,
                        readHistory: monitor.memoryReadHistory,
                        writeHistory: monitor.memoryWriteHistory,
                        compact: true
                    )

                    GPUChartView(
                        metrics: monitor.gpu,
                        history: monitor.gpuHistory,
                        compact: true
                    )

                    NetworkChartView(
                        metrics: monitor.network,
                        inHistory: monitor.networkInHistory,
                        outHistory: monitor.networkOutHistory,
                        compact: true
                    )

                    DiskView(metrics: monitor.disk)

                    NPUView(
                        metrics: monitor.npu,
                        history: monitor.npuHistory
                    )

                    // Temperature spans 2 cols when possible
                    TemperatureView(
                        metrics: monitor.temperature,
                        history: monitor.temperatureHistory
                    )
                    .gridCellColumns(tempColumns)
                }
                .padding(AppTheme.Dimensions.gridSpacing)
            }
        }
        .background(AppTheme.Colors.background)
        .onAppear {
            monitor.startMonitoring()
        }
    }
}
