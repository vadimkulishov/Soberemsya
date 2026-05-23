import SwiftUI

struct PromoShowcaseView: View {
    @StateObject private var promoManager = PromoManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedPromo: PromoItem?
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("Промо блоки - примеры")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    largeCarsSection
                    
                    compactCardsSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .background(DesignConstants.Colors.mainBackground(colorScheme: colorScheme))
            .navigationTitle("Промо блоки")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedPromo) { promo in
                PromoDetailView(promo: promo)
            }
        }
    }
    
    var largeCarsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Большие карточки (горизонтальный скролл)")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(promoManager.activePromos) { promo in
                        PromoCardComponent(promo: promo) {
                            selectedPromo = promo
                        }
                        .frame(width: 300)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var compactCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Компактные карточки (список)")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(promoManager.activePromos) { promo in
                CompactPromoCardComponent(promo: promo) {
                    selectedPromo = promo
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    PromoShowcaseView()
}
