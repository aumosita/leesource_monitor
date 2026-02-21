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

    // Hidden cards
    var hiddenCards: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(hiddenCards), forKey: "hiddenCards")
        }
    }

    // Visible cards in order
    var visibleCards: [CardType] {
        cardOrder.filter { !hiddenCards.contains($0.rawValue) }
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

        if let savedHidden = UserDefaults.standard.stringArray(forKey: "hiddenCards") {
            self.hiddenCards = Set(savedHidden)
        } else {
            self.hiddenCards = []
        }

        if let savedOrder = UserDefaults.standard.stringArray(forKey: "cardOrder") {
            self.cardOrder = savedOrder.compactMap { CardType(rawValue: $0) }
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

    func toggleCard(_ card: CardType) {
        if hiddenCards.contains(card.rawValue) {
            hiddenCards.remove(card.rawValue)
        } else {
            hiddenCards.insert(card.rawValue)
        }
    }

    func isCardVisible(_ card: CardType) -> Bool {
        !hiddenCards.contains(card.rawValue)
    }

    func resetOrder() {
        cardOrder = CardType.allCases
        hiddenCards = []
    }
}
