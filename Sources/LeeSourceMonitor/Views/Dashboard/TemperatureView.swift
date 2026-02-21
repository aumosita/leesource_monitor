import SwiftUI
import Charts

struct TemperatureView: View {
    let metrics: TemperatureMetrics
    let history: [String: [MetricSample]]
    @State private var showLegend = false

    var body: some View {
        MetricCardView(title: "Temperature", icon: "thermometer.medium", accentColor: .orange) {
            VStack(spacing: 6) {
                // Overlapping line chart (taller)
                if !history.isEmpty {
                    let sortedSensors = metrics.sensors.sorted { $0.name < $1.name }

                    // Dynamic Y range from all history values
                    let allValues = history.values.flatMap { $0.map(\.value) }
                    let minTemp = max((allValues.min() ?? 20) - 5, 0)
                    let maxTemp = (allValues.max() ?? 100) + 5

                    Chart {
                        ForEach(Array(sortedSensors.enumerated()), id: \.element.id) { index, sensor in
                            let samples = history[sensor.name] ?? []
                            ForEach(samples) { sample in
                                LineMark(
                                    x: .value("Time", sample.timestamp),
                                    y: .value("Temp", sample.value),
                                    series: .value("Sensor", sensor.name)
                                )
                                .foregroundStyle(AppTheme.Colors.sensorColor(at: index))
                                .lineStyle(StrokeStyle(lineWidth: 1.2))
                            }
                        }
                    }
                    .chartYScale(domain: minTemp...maxTemp)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                Text("\(value.as(Int.self) ?? 0)°")
                                    .font(.system(size: 8))
                                    .foregroundStyle(AppTheme.Colors.textTertiary)
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                .foregroundStyle(AppTheme.Colors.textTertiary.opacity(0.3))
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartLegend(.hidden)
                    .frame(height: 120)
                }

                // Toggle button for sensor legend
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showLegend.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("\(metrics.sensors.count) sensors")
                            .font(.system(size: 9))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                        Image(systemName: showLegend ? "chevron.up" : "chevron.down")
                            .font(.system(size: 8))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                        Spacer()

                        // Show hottest sensor inline
                        if let hottest = metrics.sensors.max(by: { $0.temperature < $1.temperature }) {
                            Text("Max: \(hottest.name) \(Formatters.temperature(hottest.temperature))")
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Collapsible sensor legend
                if showLegend {
                    let sortedSensors = metrics.sensors.sorted { $0.name < $1.name }
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 4),
                        GridItem(.flexible(), spacing: 4),
                        GridItem(.flexible(), spacing: 4),
                    ], alignment: .leading, spacing: 2) {
                        ForEach(Array(sortedSensors.enumerated()), id: \.element.id) { index, sensor in
                            HStack(spacing: 3) {
                                Circle()
                                    .fill(AppTheme.Colors.sensorColor(at: index))
                                    .frame(width: 5, height: 5)

                                Text(sensor.name)
                                    .font(.system(size: 7))
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                                    .lineLimit(1)

                                Spacer(minLength: 0)

                                Text(Formatters.temperature(sensor.temperature))
                                    .font(.system(size: 8, weight: .semibold, design: .rounded))
                                    .foregroundStyle(temperatureColor(sensor.temperature))
                            }
                        }
                    }
                }
            }
        }
    }

    private func temperatureColor(_ temp: Double) -> Color {
        if temp < 40 { return Color(hue: 0.35, saturation: 0.6, brightness: 0.8) }
        if temp < 70 { return Color(hue: 0.12, saturation: 0.7, brightness: 0.9) }
        return Color(hue: 0.0, saturation: 0.7, brightness: 0.9)
    }
}
