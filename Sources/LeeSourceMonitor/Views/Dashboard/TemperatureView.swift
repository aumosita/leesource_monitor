import SwiftUI
import Charts

struct TemperatureView: View {
    let metrics: TemperatureMetrics
    let history: [String: [MetricSample]]

    var body: some View {
        MetricCardView(title: "Temperature", icon: "thermometer.medium", accentColor: .orange) {
            VStack(spacing: 12) {
                // Overlapping line chart for all sensors
                if !history.isEmpty {
                    let sortedSensors = metrics.sensors.sorted { $0.name < $1.name }
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
                                .interpolationMethod(.catmullRom)
                                .lineStyle(StrokeStyle(lineWidth: 1.5))
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                Text("\(value.as(Int.self) ?? 0)°")
                                    .font(.system(size: 9))
                                    .foregroundStyle(AppTheme.Colors.textTertiary)
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                .foregroundStyle(AppTheme.Colors.textTertiary.opacity(0.3))
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartLegend(.hidden)
                    .frame(height: AppTheme.Dimensions.chartHeight + 30)
                }

                // Legend - sensor list with current values
                let sortedSensors = metrics.sensors.sorted { $0.name < $1.name }
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8),
                ], alignment: .leading, spacing: 4) {
                    ForEach(Array(sortedSensors.enumerated()), id: \.element.id) { index, sensor in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppTheme.Colors.sensorColor(at: index))
                                .frame(width: 6, height: 6)

                            Text(sensor.name)
                                .font(.system(size: 9))
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .lineLimit(1)

                            Spacer()

                            Text(Formatters.temperature(sensor.temperature))
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(temperatureColor(sensor.temperature))
                        }
                    }
                }
            }
        }
    }

    private func temperatureColor(_ temp: Double) -> Color {
        if temp < 40 {
            return Color(hue: 0.35, saturation: 0.6, brightness: 0.8)  // Green
        } else if temp < 70 {
            return Color(hue: 0.12, saturation: 0.7, brightness: 0.9)  // Orange
        } else {
            return Color(hue: 0.0, saturation: 0.7, brightness: 0.9)   // Red
        }
    }
}
