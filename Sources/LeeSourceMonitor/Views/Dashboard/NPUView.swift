import SwiftUI
import Charts

struct NPUView: View {
    let metrics: NPUMetrics
    let history: [MetricSample]
    var expanded: Bool = false

    private var chartHeight: CGFloat { expanded ? 120 : AppTheme.Dimensions.chartHeight }

    var body: some View {
        MetricCardView(
            title: "Neural Engine",
            icon: "brain",
            accentColor: AppTheme.Colors.npuActive,
            valueText: Formatters.milliwatts(metrics.powerMilliwatts)
        ) {
            VStack(spacing: expanded ? 8 : 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(metrics.isActive ? Color.green : Color.gray.opacity(0.4))
                        .frame(width: 6, height: 6)
                    Text(metrics.isActive ? "Active" : "Idle")
                        .font(.system(size: expanded ? 10 : 9))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Spacer()
                }

                Chart(history) { sample in
                    LineMark(
                        x: .value("Time", sample.timestamp),
                        y: .value("Power", sample.value)
                    )
                    .foregroundStyle(AppTheme.Colors.npuActive)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                }
                .chartXAxis(.hidden)
                .chartYAxis(expanded ? .automatic : .hidden)
                .frame(height: chartHeight)
            }
        }
    }
}
