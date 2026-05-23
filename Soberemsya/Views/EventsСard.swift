import SwiftUI

// MARK: - Event Detail View
struct EventDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    let event: Event
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    @State private var isRegistered = false
    @StateObject private var ticketViewModel = TicketViewModel()
    @State private var showRegistrationAlert = false
    @State private var registrationMessage = ""
    @State private var isLoadingRegistration = false
    
    var categoryColor: Color {
        DesignConstants.Colors.categoryColor(for: event.category)
    }

    private var canManageRegistration: Bool {
        authManager.isLoggedIn
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection(topInset: proxy.safeAreaInsets.top)

                    VStack(alignment: .leading, spacing: 18) {
                        summaryCard

                        detailSection(
                            title: "О событии",
                            icon: "text.alignleft",
                            content: AnyView(
                                Text(event.description.isEmpty ? "Описание скоро появится." : event.description)
                                    .font(DesignConstants.Typography.subheadline)
                                    .foregroundColor(DesignConstants.Colors.textSecondary)
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            )
                        )

                        detailSection(
                            title: "Формат",
                            icon: "square.grid.2x2.fill",
                            content: AnyView(
                                VStack(alignment: .leading, spacing: 12) {
                                    VStack(spacing: 10) {
                                        DetailPill(
                                            icon: DesignConstants.categoryIcon(for: event.category),
                                            title: event.category,
                                            subtitle: "Категория",
                                            color: categoryColor
                                        )
                                        DetailPill(
                                            icon: "ticket.fill",
                                            title: isRegistered ? "Вы в списке" : "Открыта запись",
                                            subtitle: "Регистрация",
                                            color: categoryColor
                                        )
                                    }

                                    if let capacity = event.capacity {
                                        DetailCapacityRow(
                                            registeredCount: event.registeredCount ?? 0,
                                            capacity: capacity,
                                            color: categoryColor
                                        )
                                    }

                                    if !canManageRegistration {
                                        guestHintCard
                                    }
                                }
                            )
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .background(DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                registerButtonBar
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            guard canManageRegistration else { return }
            ticketViewModel.loadMyTickets()
        }
        .onChange(of: ticketViewModel.userTickets) { _, newTickets in
            if newTickets != nil {
                isRegistered = ticketViewModel.isRegisteredForEvent(event.id)
            }
        }
        .alert("Registration Status", isPresented: $showRegistrationAlert) {
            Button("OK") { }
        } message: {
            Text(registrationMessage)
        }
        .errorAlert(error: $ticketViewModel.error)
    }

    private func heroSection(topInset: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            EventImageView(
                imagePath: event.imageName,
                category: event.category,
                height: 280 + topInset,
                cornerRadius: 0,
                overlayStrength: 0.28,
                preferCategoryImage: true
            )

            LinearGradient(
                colors: [
                    .black.opacity(0.58),
                    .black.opacity(0.12),
                    .black.opacity(0.72)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(.black.opacity(0.24), in: Circle())
                            .overlay(Circle().strokeBorder(.white.opacity(0.18), lineWidth: 1))
                    }

                    Spacer()

                    Text(event.category.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(.white.opacity(0.92))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.14), in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 1))
                }

                Spacer()

                VStack(alignment: .leading, spacing: 14) {
                    Text(event.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)

                    VStack(alignment: .leading, spacing: 8) {
                        heroMetaChip(icon: "calendar", text: event.date)
                        heroMetaChip(icon: "clock", text: eventTimeText)
                    }

                    if let city = event.city, !city.isEmpty {
                        Text(city)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.86))
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, topInset + 14)
            .padding(.bottom, 20)
        }
        .frame(height: 280 + topInset)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ключевая информация")
                .font(DesignConstants.Typography.headline)
                .foregroundColor(DesignConstants.Colors.textPrimary)

            VStack(spacing: 12) {
                InfoRowNew(icon: "calendar.badge", label: "Дата", value: event.date, color: categoryColor)
                InfoRowNew(icon: "clock.fill", label: "Время", value: eventTimeText, color: categoryColor)
                InfoRowNew(icon: "mappin.circle.fill", label: "Место", value: event.location, color: categoryColor)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(categoryColor.opacity(colorScheme == .dark ? 0.2 : 0.12), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.14 : 0.04),
            radius: 10,
            x: 0,
            y: 4
        )
    }

    private func detailSection(title: String, icon: String, content: AnyView) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(categoryColor)
                    .frame(width: 32, height: 32)
                    .background(categoryColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(title)
                    .font(DesignConstants.Typography.headline)
                    .foregroundColor(DesignConstants.Colors.textPrimary)
            }

            content
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.12 : 0.035),
            radius: 10,
            x: 0,
            y: 4
        )
    }

    private func heroMetaChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.white.opacity(0.14), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 1))
    }

    private var guestHintCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(categoryColor)
                .frame(width: 30, height: 30)
                .background(categoryColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text("Просмотр доступен без входа, но регистрация доступна только авторизованным пользователям.")
                .font(DesignConstants.Typography.footnote)
                .foregroundColor(DesignConstants.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var registerButtonBar: some View {
        Button {
            guard canManageRegistration else { return }

            if !isRegistered {
                isLoadingRegistration = true
                ticketViewModel.registerForEvent(event.id) { success in
                    isLoadingRegistration = false
                    if success {
                        isRegistered = true
                        registrationMessage = "Successfully registered for \(event.title)"
                    } else {
                        registrationMessage = "Failed to register. Please try again."
                    }
                    showRegistrationAlert = true
                }
            } else {
                isLoadingRegistration = true
                ticketViewModel.unregisterFromEvent(event.id) { success in
                    isLoadingRegistration = false
                    if success {
                        isRegistered = false
                        registrationMessage = "Successfully unregistered from \(event.title)"
                    } else {
                        registrationMessage = "Failed to unregister. Please try again."
                    }
                    showRegistrationAlert = true
                }
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(0.16))
                        .frame(width: 34, height: 34)

                    if isLoadingRegistration {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: isRegistered ? "checkmark.circle.fill" : "ticket.fill")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(registerButtonTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(registerButtonSubtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: canManageRegistration ? "arrow.up.right" : "lock.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                isRegistered ? DesignConstants.Colors.success : categoryColor,
                                isRegistered ? DesignConstants.Colors.success.opacity(0.8) : categoryColor.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .foregroundColor(.white)
            .shadow(color: categoryColor.opacity(0.2), radius: 10, x: 0, y: 4)
        }
        .disabled(isLoadingRegistration || !canManageRegistration)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [
                    DesignConstants.Colors.mainBackground(colorScheme: colorScheme).opacity(0.0),
                    DesignConstants.Colors.mainBackground(colorScheme: colorScheme).opacity(0.82),
                    DesignConstants.Colors.mainBackground(colorScheme: colorScheme)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var registerButtonTitle: String {
        if !canManageRegistration {
            return "Нужен вход"
        }
        return isRegistered ? "Вы зарегистрированы" : "Зарегистрироваться"
    }

    private var registerButtonSubtitle: String {
        if !canManageRegistration {
            return "Гость может смотреть событие, но не может записаться"
        }
        return isRegistered ? "Место сохранено в билетах" : "Добавим событие в ваши билеты"
    }

    private var eventTimeText: String {
        switch (event.timeStart, event.timeEnd) {
        case let (start?, end?) where !start.isEmpty && !end.isEmpty:
            return "\(start) - \(end)"
        case let (start?, _) where !start.isEmpty:
            return start
        default:
            return "Уточняется"
        }
    }
}

private struct DetailPill: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(subtitle)
                    .font(DesignConstants.Typography.caption)
                    .foregroundColor(DesignConstants.Colors.textSecondary)
                Text(title)
                    .font(DesignConstants.Typography.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct DetailCapacityRow: View {
    let registeredCount: Int
    let capacity: Int
    let color: Color

    private var progress: Double {
        guard capacity > 0 else { return 0 }
        return min(Double(registeredCount) / Double(capacity), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Участники")
                    .font(DesignConstants.Typography.footnote)
                    .foregroundColor(DesignConstants.Colors.textSecondary)
                Spacer()
                Text("\(registeredCount) / \(capacity)")
                    .font(DesignConstants.Typography.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignConstants.Colors.textPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.12))
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 6)

            Text(progress >= 1 ? "Свободных мест нет" : "Свободно \(max(capacity - registeredCount, 0)) мест")
                .font(DesignConstants.Typography.caption)
                .foregroundColor(DesignConstants.Colors.textSecondary)
        }
    }
}

// MARK: - Info Row Component
struct InfoRowNew: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DesignConstants.Colors.textSecondary)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
    EventDetailView(event: Event(title: "Концерт классической музыки", description: "Приглашаем вас на вечер классической музыки с лучшими произведениями мировых композиторов.", date: "20.03.2026", location: "Филармония", imageName: nil, category: "Музыка"))
}
