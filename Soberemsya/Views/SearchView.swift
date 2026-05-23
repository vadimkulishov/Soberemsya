import SwiftUI

/// Экран поиска в стиле Apple Health
struct SearchView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedCategory: EventCategory? = nil
    @State private var categoriesAppeared = false
    
    let columns = [
        GridItem(.flexible(), spacing: DesignConstants.spacing),
        GridItem(.flexible(), spacing: DesignConstants.spacing)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DesignConstants.padding) {
                        if viewModel.filteredCategories.isEmpty {
                            SearchEmptyState(query: viewModel.query)
                                .padding(.top, 72)
                        } else {
                            LazyVGrid(columns: columns, spacing: DesignConstants.spacing) {
                                ForEach(Array(viewModel.filteredCategories.enumerated()), id: \.element.id) { index, category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        CategoryCardComponent(category: category)
                                    }
                                    .buttonStyle(PressableCardButtonStyle(pressedScale: 0.96))
                                    .opacity(categoriesAppeared ? 1 : 0)
                                    .offset(y: categoriesAppeared ? 0 : 20)
                                    .animation(
                                        .spring(response: 0.4, dampingFraction: 0.75)
                                            .delay(Double(index) * 0.05),
                                        value: categoriesAppeared
                                    )
                                }
                            }
                        }
                    }
                    .padding(DesignConstants.padding)
                    .onAppear {
                        if !categoriesAppeared {
                            categoriesAppeared = true
                        }
                    }
                }
            }
            .navigationTitle("Категории")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedCategory) { category in
                CategoryDetailView(category: category)
            }
            .searchable(text: $viewModel.query, prompt: "Музыка, спорт, кино...")
            .onChange(of: viewModel.query) {
                viewModel.updateFilteredCategories()
            }
        }
    }
}

// MARK: - Category Detail View (обновлённый)
struct CategoryDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    let category: EventCategory
    
    @ObservedObject var eventService = EventService.shared
    
    var categoryColor: Color {
        Color(hex: category.color)
    }
    
    var body: some View {
        ZStack {
            DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    // Карточка категории
                    VStack(spacing: DesignConstants.padding) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(categoryColor.opacity(0.14))
                                .frame(width: 92, height: 92)

                            Image(systemName: category.icon)
                                .font(.system(size: 42, weight: .semibold))
                                .foregroundColor(categoryColor)
                        }

                        VStack(spacing: 6) {
                            Text(category.title)
                                .font(DesignConstants.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(DesignConstants.Colors.textPrimary)

                            Text("Мероприятия этой категории")
                                .font(DesignConstants.Typography.subheadline)
                                .foregroundColor(DesignConstants.Colors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(DesignConstants.largePadding)
                    .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignConstants.cornerRadius, style: .continuous)
                            .strokeBorder(categoryColor.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(
                        color: DesignConstants.Shadows.card.color,
                        radius: DesignConstants.Shadows.card.radius,
                        x: DesignConstants.Shadows.card.x,
                        y: DesignConstants.Shadows.card.y
                    )
                    .padding(DesignConstants.padding)
                    
                    // События этой категории
                    VStack(alignment: .leading, spacing: DesignConstants.spacing) {
                        Text("События")
                            .font(DesignConstants.Typography.title3)
                            .fontWeight(.bold)
                            .foregroundColor(DesignConstants.Colors.textPrimary)
                            .padding(.horizontal, DesignConstants.padding)
                        
                        if eventService.isLoading {
                            // Loading skeleton
                            VStack(spacing: DesignConstants.spacing) {
                                ForEach(0..<3, id: \.self) { _ in
                                    SkeletonEventCard()
                                }
                            }
                            .padding(.horizontal, DesignConstants.padding)
                        } else if eventService.filteredEvents.isEmpty {
                            // Empty state
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 44, weight: .light))
                                    .foregroundColor(DesignConstants.Colors.textSecondary)
                                
                                Text("Нет событий")
                                    .font(DesignConstants.Typography.headline)
                                    .foregroundColor(DesignConstants.Colors.textPrimary)
                                
                                Text("В эту категорию пока не добавлено мероприятий")
                                    .font(DesignConstants.Typography.subheadline)
                                    .foregroundColor(DesignConstants.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            // Display events
                            VStack(spacing: DesignConstants.padding) {
                                ForEach(eventService.filteredEvents) { event in
                                    EventCardComponent(event: event)
                                }
                            }
                            .padding(.horizontal, DesignConstants.padding)
                        }
                    }
                }
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            eventService.loadEventsByCategory(category.title)
        }
    }
}

private struct SearchEmptyState: View {
    let query: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(DesignConstants.Colors.textTertiary)

            Text("Ничего не найдено")
                .font(DesignConstants.Typography.headline)
                .foregroundColor(DesignConstants.Colors.textPrimary)

            Text(query.isEmpty ? "Категории появятся здесь" : "Попробуйте другой запрос")
                .font(DesignConstants.Typography.subheadline)
                .foregroundColor(DesignConstants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SearchView()
}
