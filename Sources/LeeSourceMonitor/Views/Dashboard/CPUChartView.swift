import SwiftUI
import Charts

struct CPUChartView: View {
    let metrics: CPUMetrics
    let history: [MetricSample]
    let coreHistory: [[MetricSample]]
    var expanded: Bool = false

    private var chartHeight: CGFloat { expanded ? 120 : AppTheme.Dimensions.chartHeight }

    var body: some View {
        MetricCardView(
            title: "CPU",
            icon: "cpu",
            accentColor: AppTheme.Colors.cpuGradientStart,
            valueText: Formatters.percentage(metrics.totalUsage)
        ) {
            VStack(spacing: expanded ? 8 : 4) {
                if expanded {
                    HStack {
                        Text("\(metrics.coreCount) cores")
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                        Spacer()
                    }
                }

                Chart(history) { sample in
                    LineMark(
                        x: .value("Time", sample.timestamp),
                        y: .value("Usage", sample.value)
                    )
                    .foregroundStyle(AppTheme.Colors.cpuGradientStart)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                }
                .chartYScale(domain: 0...100)
                .chartYAxis(expanded ? .automatic : .hidden)
                .chartXAxis(.hidden)
                .frame(height: chartHeight)

                // Per-core bars
                HStack(spacing: 2) {
                    ForEach(0..<max(metrics.coreUsages.count, 1), id: \.self) { i in
                        if i < metrics.coreUsages.count {
                            VStack(spacing: 1) {
                                UsageBar(
                                    value: metrics.coreUsages[i],
                                    maxValue: 100,
                                    color: AppTheme.Colors.usageColor(metrics.coreUsages[i]),
                                    height: expanded ? 5 : 3
                                )
                                if expanded {
                                    Text("\(Int(metrics.coreUsages[i]))%")
                                        .font(.system(size: 6, design: .monospaced))
                                        .foregroundStyle(AppTheme.Colors.textTertiary)
                                }
                            }
                        }
                    }
                }
                .frame(minHeight: expanded ? 16 : 3)
            }
        }
    }
}
