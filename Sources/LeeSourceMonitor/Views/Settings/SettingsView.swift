import SwiftUI

struct SettingsView: View {
    var settings: AppSettings
    var monitor: SystemMonitor

    private let intervalOptions: [(String, Double)] = [
        ("0.5s", 0.5),
        ("1s", 1.0),
        ("2s", 2.0),
        ("5s", 5.0),
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Polling interval
            GroupBox("Update Interval") {
                HStack {
                    ForEach(intervalOptions, id: \.1) { label, value in
                        Button {
                            settings.pollingInterval = value
                            monitor.restartWithInterval(value)
                        } label: {
                            Text(label)
                                .font(.system(size: 12, weight: settings.pollingInterval == value ? .bold : .regular))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(settings.pollingInterval == value ? Color.accentColor.opacity(0.2) : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }

            // Always on top
            GroupBox("Window") {
                Toggle("Always on Top", isOn: Binding(
                    get: { settings.alwaysOnTop },
                    set: { settings.alwaysOnTop = $0 }
                ))
                .font(.system(size: 12))
                .padding(.vertical, 4)
            }

            // Card visibility & order
            GroupBox("Dashboard Cards (drag to reorder)") {
                List {
                    ForEach(settings.cardOrder) { card in
                        HStack {
                            Button {
                                settings.toggleCard(card)
                            } label: {
                                Image(systemName: settings.isCardVisible(card) ? "eye.fill" : "eye.slash")
                                    .font(.system(size: 11))
                                    .foregroundStyle(settings.isCardVisible(card) ? .primary : .tertiary)
                                    .frame(width: 20)
                            }
                            .buttonStyle(.plain)

                            Image(systemName: card.icon)
                                .frame(width: 20)
                                .foregroundStyle(settings.isCardVisible(card) ? .secondary : .tertiary)

                            Text(card.rawValue)
                                .font(.system(size: 12))
                                .foregroundStyle(settings.isCardVisible(card) ? .primary : .tertiary)

                            Spacer()

                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 2)
                    }
                    .onMove(perform: settings.moveCard)
                }
                .listStyle(.plain)
                .frame(height: 220)

                HStack {
                    Spacer()
                    Button("Reset All") {
                        settings.resetOrder()
                    }
                    .font(.system(size: 11))
                }
            }
        }
        .padding(20)
        .frame(width: 350)
    }
}
