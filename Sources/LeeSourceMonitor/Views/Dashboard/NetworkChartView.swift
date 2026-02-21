import SwiftUI
import Charts

struct NetworkChartView: View {
    let metrics: NetworkMetrics
    let inHistory: [MetricSample]
    let outHistory: [MetricSample]
    var expanded: Bool = false

    private var chartHeight: CGFloat { expanded ? 55 : AppTheme.Dimensions.chartHeight / 2 }

    var body: some View {
        MetricCardView(title: "Network", icon: "network", accentColor: AppTheme.Colors.networkIn) {
            VStack(spacing: expanded ? 6 : 4) {
                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Text("↓")
                            .font(.system(size: expanded ? 12 : 10, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.networkIn)
                        Text(Formatters.speed(metrics.speedIn))
                            .font(.system(size: expanded ? 13 : 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.networkIn)
                    }
                    HStack(spacing: 3) {
                        Text("↑")
                            .font(.system(size: expanded ? 12 : 10, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.networkOut)
                        Text(Formatters.speed(metrics.speedOut))
                            .font(.system(size: expanded ? 13 : 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.networkOut)
                    }
                    Spacer()
                }

                // Download
                Chart(inHistory) { sample in
                    BarMark(
                        x: .value("Time", sample.timestamp),
                        y: .value("Speed", sample.value)
                    )
                    .foregroundStyle(AppTheme.Colors.networkIn)
                }
                .chartXAxis(.hidden)
                .chartYAxis(expanded ? .automatic : .hidden)
                .frame(height: chartHeight)

                // Upload
                Chart(outHistory) { sample in
                    BarMark(
                        x: .value("Time", sample.timestamp),
                        y: .value("Speed", sample.value)
                    )
                    .foregroundStyle(AppTheme.Colors.networkOut)
                }
                .chartXAxis(.hidden)
                .chartYAxis(expanded ? .automatic : .hidden)
                .frame(height: chartHeight)

                HStack {
                    Text("Total ↓\(Formatters.bytes(metrics.bytesIn))")
                        .font(.system(size: expanded ? 9 : 8, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Spacer()
                    Text("Total ↑\(Formatters.bytes(metrics.bytesOut))")
                        .font(.system(size: expanded ? 9 : 8, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
        }
    }
}
