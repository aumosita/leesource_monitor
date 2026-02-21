import SwiftUI

struct DashboardView: View {
    var monitor: SystemMonitor

    var body: some View {
        GeometryReader { geometry in
            let isWide = geometry.size.width > 900
            let columns = isWide ? 3 : 2

            ScrollView {
                let gridItems = Array(repeating: GridItem(.flexible(), spacing: AppTheme.Dimensions.gridSpacing), count: columns)

                LazyVGrid(columns: gridItems, spacing: AppTheme.Dimensions.gridSpacing) {
                    // CPU
                    CPUChartView(
                        metrics: monitor.cpu,
                        history: monitor.cpuHistory,
                        coreHistory: monitor.cpuCoreHistory,
                        compact: true
                    )

                    // Memory
                    MemoryChartView(
                        metrics: monitor.memory,
                        pressureHistory: monitor.memoryPressureHistory,
                        readHistory: monitor.memoryReadHistory,
                        writeHistory: monitor.memoryWriteHistory,
                        compact: true
                    )

                    // GPU
                    GPUChartView(
                        metrics: monitor.gpu,
                        history: monitor.gpuHistory,
                        compact: true
                    )

                    // Network
                    NetworkChartView(
                        metrics: monitor.network,
                        inHistory: monitor.networkInHistory,
                        outHistory: monitor.networkOutHistory,
                        compact: true
                    )

                    // Disk
                    DiskView(metrics: monitor.disk)

                    // NPU
                    NPUView(
                        metrics: monitor.npu,
                        history: monitor.npuHistory
                    )

                    // Temperature (spans full width)
                    TemperatureView(
                        metrics: monitor.temperature,
                        history: monitor.temperatureHistory
                    )
                    .gridCellColumns(columns)
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
