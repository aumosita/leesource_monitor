import SwiftUI

struct DashboardView: View {
    var monitor: SystemMonitor

    let columns = [
        GridItem(.flexible(), spacing: AppTheme.Dimensions.gridSpacing),
        GridItem(.flexible(), spacing: AppTheme.Dimensions.gridSpacing),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppTheme.Dimensions.gridSpacing) {
                // CPU (full width)
                CPUChartView(
                    metrics: monitor.cpu,
                    history: monitor.cpuHistory,
                    coreHistory: monitor.cpuCoreHistory
                )
                .gridCellColumns(2)

                // Memory (full width)
                MemoryChartView(
                    metrics: monitor.memory,
                    pressureHistory: monitor.memoryPressureHistory,
                    readHistory: monitor.memoryReadHistory,
                    writeHistory: monitor.memoryWriteHistory
                )
                .gridCellColumns(2)

                // GPU
                GPUChartView(
                    metrics: monitor.gpu,
                    history: monitor.gpuHistory
                )

                // Network
                NetworkChartView(
                    metrics: monitor.network,
                    inHistory: monitor.networkInHistory,
                    outHistory: monitor.networkOutHistory
                )

                // Temperature (full width)
                TemperatureView(
                    metrics: monitor.temperature,
                    history: monitor.temperatureHistory
                )
                .gridCellColumns(2)

                // Disk
                DiskView(metrics: monitor.disk)

                // NPU
                NPUView(
                    metrics: monitor.npu,
                    history: monitor.npuHistory
                )
            }
            .padding(AppTheme.Dimensions.gridSpacing)
        }
        .background(AppTheme.Colors.background)
        .onAppear {
            monitor.startMonitoring()
        }
    }
}
