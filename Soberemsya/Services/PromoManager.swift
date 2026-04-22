import SwiftUI
import Combine

class PromoManager: ObservableObject {
    @Published var activePromos: [PromoItem] = []
    @Published var featuredPromo: PromoItem?
    
    static let shared = PromoManager()
    
    private init() {
        loadPromos()
    }
    
    func loadPromos() {
        activePromos = PromoItem.samplePromos
        featuredPromo = activePromos.first
    }
    
    func refreshPromos() {
        activePromos.shuffle()
        featuredPromo = activePromos.first
    }
    
    func getPromosByType(_ type: PromoItem.PromoType) -> [PromoItem] {
        return activePromos.filter { $0.type == type }
    }
    
    func trackPromoImpression(promoId: UUID) {
        print("📊 Promo impression tracked: \(promoId)")
    }
    
    func trackPromoClick(promoId: UUID) {
        print("🎯 Promo clicked: \(promoId)")
    }
}

extension PromoItem {
    func getPromoImage() -> String {
        switch type {
        case .discount:
            return "tag.fill"
        case .newFeature:
            return "sparkles"
        case .partnership:
            return "person.2.fill"
        case .seasonal:
            return "sun.max.fill"
        case .advertisement:
            return "megaphone.fill"
        }
    }
}
