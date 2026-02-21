import Foundation
import SwiftUI

@Observable
@MainActor
final class AppSettings {
    static let shared = AppSettings()

    // Polling interval in seconds
    var pollingInterval: Double {
        didSet {
            UserDefaults.standard.set(pollingInterval, forKey: "pollingInterval")
        }
    }

    // Dashboard card order
    var cardOrder: [CardType] {
        didSet {
            let rawValues = cardOrder.map { $0.rawValue }
            UserDefaults.standard.set(rawValues, forKey: "cardOrder")
        }
    }

    enum CardType: String, CaseIterable, Identifiable, Codable {
        case cpu = "CPU"
        case memory = "Memory"
        case gpu = "GPU"
        case network = "Network"
        case disk = "Disk"
        case npu = "NPU"
        case temperature = "Temperature"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .cpu: return "cpu"
            case .memory: return "memorychip"
            case .gpu: return "gpu"
            case .network: return "network"
            case .disk: return "internaldrive"
            case .npu: return "brain"
            case .temperature: return "thermometer.medium"
            }
        }
    }

    private init() {
        let savedInterval = UserDefaults.standard.double(forKey: "pollingInterval")
        self.pollingInterval = savedInterval > 0 ? savedInterval : 1.0

        if let savedOrder = UserDefaults.standard.stringArray(forKey: "cardOrder") {
            self.cardOrder = savedOrder.compactMap { CardType(rawValue: $0) }
            // Add any missing cards
            for card in CardType.allCases where !self.cardOrder.contains(card) {
                self.cardOrder.append(card)
            }
        } else {
            self.cardOrder = CardType.allCases
        }
    }

    func moveCard(from source: IndexSet, to destination: Int) {
        cardOrder.move(fromOffsets: source, toOffset: destination)
    }

    func resetOrder() {
        cardOrder = CardType.allCases
    }
}
