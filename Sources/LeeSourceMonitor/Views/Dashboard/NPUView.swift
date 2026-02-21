import SwiftUI
import Charts

struct NPUView: View {
    let metrics: NPUMetrics
    let history: [MetricSample]

    var body: some View {
        MetricCardView(
            title: "Neural Engine",
            icon: "brain",
            accentColor: AppTheme.Colors.npuActive,
            valueText: Formatters.milliwatts(metrics.powerMilliwatts)
        ) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(metrics.isActive ? Color.green : Color.gray.opacity(0.4))
                        .frame(width: 5, height: 5)
                    Text(metrics.isActive ? "Active" : "Idle")
                        .font(.system(size: 9))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Spacer()
                }

                if !history.isEmpty {
                    Chart(history) { sample in
                        AreaMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Power", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.Colors.npuActive.opacity(0.2), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Power", sample.value)
                        )
                        .foregroundStyle(AppTheme.Colors.npuActive)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: AppTheme.Dimensions.chartHeight)
                }
            }
        }
    }
}
