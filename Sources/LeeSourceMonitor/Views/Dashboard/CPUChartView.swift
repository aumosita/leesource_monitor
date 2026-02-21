import SwiftUI
import Charts

struct CPUChartView: View {
    let metrics: CPUMetrics
    let history: [MetricSample]
    let coreHistory: [[MetricSample]]

    var body: some View {
        MetricCardView(title: "CPU", icon: "cpu", accentColor: AppTheme.Colors.cpuGradientStart) {
            VStack(spacing: 12) {
                // Total usage header
                HStack(alignment: .firstTextBaseline) {
                    Text(Formatters.percentage(metrics.totalUsage))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.Colors.cpuGradientStart, AppTheme.Colors.cpuGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("\(metrics.coreCount) cores")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Spacer()
                }

                // History chart
                if !history.isEmpty {
                    Chart(history) { sample in
                        LineMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Usage", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.Colors.cpuGradientStart, AppTheme.Colors.cpuGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        AreaMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Usage", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.cpuGradientStart.opacity(0.3),
                                    AppTheme.Colors.cpuGradientEnd.opacity(0.05),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                    .chartYScale(domain: 0...100)
                    .chartYAxis {
                        AxisMarks(values: [0, 50, 100]) { value in
                            AxisValueLabel {
                                Text("\(value.as(Int.self) ?? 0)%")
                                    .font(.system(size: 9))
                                    .foregroundStyle(AppTheme.Colors.textTertiary)
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                .foregroundStyle(AppTheme.Colors.textTertiary.opacity(0.3))
                        }
                    }
                    .chartXAxis(.hidden)
                    .frame(height: AppTheme.Dimensions.chartHeight)
                }

                // Per-core bars
                if !metrics.coreUsages.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: min(metrics.coreCount, 8)), spacing: 4) {
                        ForEach(0..<metrics.coreUsages.count, id: \.self) { i in
                            VStack(spacing: 2) {
                                UsageBar(
                                    value: metrics.coreUsages[i],
                                    maxValue: 100,
                                    color: AppTheme.Colors.usageColor(metrics.coreUsages[i]),
                                    height: 4
                                )
                                Text("\(i)")
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundStyle(AppTheme.Colors.textTertiary)
                            }
                        }
                    }
                }
            }
        }
    }
}
