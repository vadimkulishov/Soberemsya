import SwiftUI

struct AutoScrollPromoView: View {
    let promos: [PromoItem]
    let onTap: ((PromoItem) -> Void)?
    
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    @GestureState private var dragOffset: CGFloat = 0
    
    private let cardSpacing: CGFloat = 16
    private let autoScrollInterval: TimeInterval = 4.0
    
    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                let cardWidth = max(260, geometry.size.width - (DesignConstants.padding * 2) - 20)
                let totalWidth = cardWidth + cardSpacing
                let offset = -CGFloat(currentIndex) * totalWidth + dragOffset
                
                HStack(spacing: cardSpacing) {
                    ForEach(Array(promos.enumerated()), id: \.element.id) { index, promo in
                        PromoCardComponent(promo: promo) {
                            onTap?(promo)
                        }
                        .frame(width: cardWidth)
                    }
                }
                .offset(x: offset + DesignConstants.padding)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                .animation(.spring(response: 0.3, dampingFraction: 0.9), value: dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width < -threshold && currentIndex < promos.count - 1 {
                                currentIndex += 1
                                resetTimer()
                            } else if value.translation.width > threshold && currentIndex > 0 {
                                currentIndex -= 1
                                resetTimer()
                            }
                        }
                )
            }
            .frame(height: 188)
            
            PageIndicator(currentPage: currentIndex, pageCount: promos.count)
                .padding(.horizontal, DesignConstants.padding)
        }
        .onAppear {
            startAutoScroll()
        }
        .onDisappear {
            stopAutoScroll()
        }
    }
    
    private func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            withAnimation {
                if currentIndex < promos.count - 1 {
                    currentIndex += 1
                } else {
                    currentIndex = 0
                }
            }
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopAutoScroll()
        startAutoScroll()
    }
}

struct PageIndicator: View {
    let currentPage: Int
    let pageCount: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.primary : Color.gray.opacity(0.3))
                    .frame(
                        width: index == currentPage ? 20 : 6,
                        height: 6
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
}

#Preview {
    VStack {
        AutoScrollPromoView(promos: PromoItem.samplePromos) { promo in
            print("Tapped: \(promo.title)")
        }
    }
    .background(Color(.systemGroupedBackground))
}
