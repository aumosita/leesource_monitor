import SwiftUI
import Charts

struct MemoryChartView: View {
    let metrics: MemoryMetrics
    let gpuMetrics: GPUMetrics
    let readHistory: [MetricSample]
    let writeHistory: [MetricSample]
    let appHistory: [MetricSample]
    let systemHistory: [MetricSample]
    let compressedHistory: [MetricSample]
    var expanded: Bool = false

    private var chartHeight: CGFloat { expanded ? 100 : AppTheme.Dimensions.chartHeight }

    // Category info for legend
    private var categories: [(label: String, gb: Double, color: Color)] {
        [
            ("App", metrics.appGB, .cyan),
            ("System", metrics.systemGB, .orange),
            ("Compressed", metrics.compressedGB, .purple),
        ]
    }

    var body: some View {
        MetricCardView(
            title: "Memory",
            icon: "memorychip",
            accentColor: .cyan,
            valueText: "\(String(format: "%.1f", metrics.usedGB))/\(String(format: "%.0f", metrics.totalGB))GB"
        ) {
            VStack(spacing: expanded ? 8 : 4) {
                // Memory Read/Write speed chart
                Chart {
                    ForEach(readHistory) { s in
                        LineMark(
                            x: .value("Time", s.timestamp),
                            y: .value("Speed", s.value),
                            series: .value("Type", "Read")
                        )
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 1.2))
                    }
                    ForEach(writeHistory) { s in
                        LineMark(
                            x: .value("Time", s.timestamp),
                            y: .value("Speed", s.value),
                            series: .value("Type", "Write")
                        )
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 1.2))
                    }
                }
                .chartYAxis(expanded ? .automatic : .hidden)
                .chartXAxis(.hidden)
                .chartLegend(.hidden)
                .frame(height: expanded ? 50 : 30)

                // Overlapping category line chart (like Temperature)
                if !appHistory.isEmpty {
                    let allValues = (appHistory + systemHistory + compressedHistory).map(\.value)
                    let minVal = max(floor(((allValues.min() ?? 0) - 1) / 2) * 2, 0)
                    let maxVal = ceil(((allValues.max() ?? 8) + 1) / 2) * 2

                    Chart {
                        ForEach(appHistory) { s in
                            LineMark(
                                x: .value("Time", s.timestamp),
                                y: .value("GB", s.value),
                                series: .value("Category", "App")
                            )
                            .foregroundStyle(.cyan)
                            .lineStyle(StrokeStyle(lineWidth: 1.2))
                        }
                        ForEach(systemHistory) { s in
                            LineMark(
                                x: .value("Time", s.timestamp),
                                y: .value("GB", s.value),
                                series: .value("Category", "System")
                            )
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 1.2))
                        }
                        ForEach(compressedHistory) { s in
                            LineMark(
                                x: .value("Time", s.timestamp),
                                y: .value("GB", s.value),
                                series: .value("Category", "Compressed")
                            )
                            .foregroundStyle(.purple)
                            .lineStyle(StrokeStyle(lineWidth: 1.2))
                        }
                    }
                    .chartYScale(domain: minVal...maxVal)
                    .animation(nil, value: minVal)
                    .animation(nil, value: maxVal)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                Text("\(value.as(Int.self) ?? 0)GB")
                                    .font(.system(size: 8))
                                    .foregroundStyle(AppTheme.Colors.textTertiary)
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                .foregroundStyle(AppTheme.Colors.textTertiary.opacity(0.3))
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartLegend(.hidden)
                    .frame(height: chartHeight)
                }

                // Category legend
                HStack(spacing: expanded ? 10 : 6) {
                    ForEach(categories, id: \.label) { cat in
                        HStack(spacing: 3) {
                            Circle().fill(cat.color).frame(width: 5, height: 5)
                            Text("\(cat.label) \(String(format: "%.1f", cat.gb))")
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                    Spacer(minLength: 0)
                    Text("Free \(String(format: "%.1f", metrics.freeGB))GB")
                        .font(.system(size: 8, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }

                // R/W speeds & Pressure
                HStack(spacing: expanded ? 16 : 6) {
                    HStack(spacing: 2) {
                        Circle().fill(.green).frame(width: 5, height: 5)
                        Text("R \(Formatters.speed(metrics.readBytesPerSec))")
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundStyle(.green)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    HStack(spacing: 2) {
                        Circle().fill(.orange).frame(width: 5, height: 5)
                        Text("W \(Formatters.speed(metrics.writeBytesPerSec))")
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    Spacer(minLength: 0)
                    Text(Formatters.percentage(metrics.pressure))
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.usageColor(metrics.pressure))
                        .lineLimit(1)
                }
            }
        }
    }
}
