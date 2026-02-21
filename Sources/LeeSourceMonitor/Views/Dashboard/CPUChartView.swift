import SwiftUI
import Charts

struct CPUChartView: View {
    let metrics: CPUMetrics
    let history: [MetricSample]
    let coreHistory: [[MetricSample]]
    var compact: Bool = false

    var body: some View {
        MetricCardView(
            title: "CPU",
            icon: "cpu",
            accentColor: AppTheme.Colors.cpuGradientStart,
            valueText: Formatters.percentage(metrics.totalUsage)
        ) {
            VStack(spacing: 4) {
                // History chart
                if !history.isEmpty {
                    Chart(history) { sample in
                        LineMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Usage", sample.value)
                        )
                        .foregroundStyle(AppTheme.Colors.cpuGradientStart)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))

                        AreaMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Usage", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.Colors.cpuGradientStart.opacity(0.2), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                    .chartYScale(domain: 0...100)
                    .chartYAxis(.hidden)
                    .chartXAxis(.hidden)
                    .frame(height: AppTheme.Dimensions.chartHeight)
                }

                // Per-core bars
                if !metrics.coreUsages.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(0..<metrics.coreUsages.count, id: \.self) { i in
                            UsageBar(
                                value: metrics.coreUsages[i],
                                maxValue: 100,
                                color: AppTheme.Colors.usageColor(metrics.coreUsages[i]),
                                height: 3
                            )
                        }
                    }
                    .frame(height: 3)
                }
            }
        }
    }
}
