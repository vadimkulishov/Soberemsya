import SwiftUI
import CoreLocation

/// Главный экран в стиле Apple Health
struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var showCityPicker = false
    @State private var bannersAppeared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Хедер
                        HeaderComponent(city: locationManager.currentCity) {
                            showCityPicker = true
                        }
                        
                        // Контент с отступами
                        VStack(spacing: DesignConstants.sectionSpacing) {
                            // Баннеры
                            bannersSection
                            
                            // События
                            eventsSection
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.top, DesignConstants.padding)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCityPicker) {
                CityPickerView { selectedCity in
                    locationManager.setCity(selectedCity)
                    viewModel.setCity(selectedCity)
                    showCityPicker = false
                }
            }
            .onAppear {
                // Запрос геолокации при первом показе
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestLocationPermission()
                }
            }
        }
    }
    
    // MARK: - Banners Section
    var bannersSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.spacing) {
            Text("Специальное")
                .font(DesignConstants.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(DesignConstants.Colors.textPrimary)
                .padding(.horizontal, DesignConstants.padding)

            AutoScrollPromoView(promos: viewModel.promos) { promo in
                print("Tapped promo: \(promo.title)")
            }
        }
        .opacity(bannersAppeared ? 1 : 0)
        .offset(y: bannersAppeared ? 0 : 15)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: bannersAppeared)
        .onAppear {
            if !bannersAppeared {
                bannersAppeared = true
            }
        }
    }

    // MARK: - Events Section
    var eventsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.spacing) {
            HStack(alignment: .bottom) {
                Text("Популярные")
                    .font(DesignConstants.Typography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(DesignConstants.Colors.textPrimary)

                Spacer()

                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Все")
                            .font(DesignConstants.Typography.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(DesignConstants.Colors.primary)
                }
            }
            .padding(.horizontal, DesignConstants.padding)

            if let error = viewModel.loadingError {
                ErrorStateView(error: error) {
                    viewModel.retryLoading()
                }
                .padding(.horizontal, DesignConstants.padding)
            } else if viewModel.isLoading {
                VStack(spacing: DesignConstants.spacing) {
                    ForEach(0..<3, id: \.self) { _ in
                        SkeletonEventCard()
                    }
                }
                .padding(.horizontal, DesignConstants.padding)
            } else if viewModel.events.isEmpty {
                EmptyEventsView()
                    .padding(.horizontal, DesignConstants.padding)
            } else {
                VStack(spacing: DesignConstants.padding) {
                    ForEach(Array(viewModel.events.enumerated()), id: \.element.id) { index, event in
                        EventCardComponent(event: event)
                            .opacity(viewModel.eventsAppeared ? 1 : 0)
                            .offset(y: viewModel.eventsAppeared ? 0 : 20)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.08),
                                value: viewModel.eventsAppeared
                            )
                    }
                }
                .padding(.horizontal, DesignConstants.padding)
                .onAppear {
                    if !viewModel.eventsAppeared {
                        viewModel.eventsAppeared = true
                    }
                }
            }
        }
    }
}

// MARK: - Skeleton Loading
struct SkeletonEventCard: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous)
                .fill(shimmerGradient)
                .frame(height: 180)
            
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(shimmerGradient)
                    .frame(height: 20)
                    .frame(maxWidth: .infinity)
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(shimmerGradient)
                    .frame(height: 14)
                    .frame(maxWidth: 200)
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(shimmerGradient)
                    .frame(height: 14)
                    .frame(maxWidth: 160)
            }
            .padding(DesignConstants.padding)
        }
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous))
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06),
            radius: 8,
            x: 0,
            y: 4
        )
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var shimmerGradient: LinearGradient {
        let baseColor = colorScheme == .dark 
            ? Color.white.opacity(0.08)
            : Color.gray.opacity(0.15)
        
        let highlightColor = colorScheme == .dark
            ? Color.white.opacity(0.12)
            : Color.gray.opacity(0.25)
        
        return LinearGradient(
            gradient: Gradient(colors: [
                baseColor,
                highlightColor,
                baseColor
            ]),
            startPoint: isAnimating ? .leading : .trailing,
            endPoint: isAnimating ? .trailing : .leading
        )
    }
}

#Preview {
    HomeView()
        .environment(\.locale, .init(identifier: "ru"))
}

