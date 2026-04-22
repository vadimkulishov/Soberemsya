import SwiftUI

// MARK: - Event Detail View
struct EventDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    let event: Event
    @Environment(\.dismiss) var dismiss
    @State private var isRegistered = false
    @StateObject private var ticketViewModel = TicketViewModel()
    @State private var showRegistrationAlert = false
    @State private var registrationMessage = ""
    @State private var isLoadingRegistration = false
    
    var categoryColor: Color {
        DesignConstants.Colors.categoryColor(for: event.category)
    }

    var displayImageUrl: String {
        if let imageUrl = event.imageName, !imageUrl.isEmpty {
            return imageUrl
        }
        return DesignConstants.categoryFallbackImageUrl(for: event.category)
    }
    
    var body: some View {
        ZStack {
            DesignConstants.Colors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Header with Image
                    ZStack(alignment: .topLeading) {
                        // Фоновый градиент (виден пока грузится фото)
                        DesignConstants.Colors.categoryGradient(for: event.category)
                            .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240)

                        // Hero image — нативный AsyncImage
                        AsyncImage(url: URL(string: displayImageUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Color.clear
                            case .empty:
                                Color.clear
                                    .overlay(ProgressView().tint(.white))
                            @unknown default:
                                Color.clear
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240)
                        .clipped()

                        // Градиент сверху для читаемости кнопок
                        LinearGradient(
                            colors: [.black.opacity(0.5), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                        .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240)

                        // Градиент снизу для плавного перехода в контент
                        VStack {
                            Spacer()
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.35)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 90)
                        }
                        .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240)
                        
                        // Back Button
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        .padding(12)
                        
                        // Category Badge
                        VStack {
                            HStack {
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "tag.fill")
                                        .font(.system(size: 9))
                                    Text(event.category)
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(categoryColor)
                                .cornerRadius(10)
                                .padding(12)
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 240)
                    
                    // MARK: - Content
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text(event.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(DesignConstants.Colors.textPrimary)
                            .lineLimit(nil)
                        
                        // Info Block
                        VStack(spacing: 12) {
                            // Info Details
                            VStack(spacing: 10) {
                                InfoRowNew(icon: "calendar.badge", label: "Дата", value: event.date, color: categoryColor)
                                InfoRowNew(icon: "clock.fill", label: "Время", value: "19:00 - 22:00", color: categoryColor)
                                InfoRowNew(icon: "mappin.circle.fill", label: "Место", value: event.location, color: categoryColor)
                            }
                            .padding(12)
                            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
                            .cornerRadius(12)
                        }
                        
                        // MARK: - Description
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(categoryColor)
                                Text("Описание")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(DesignConstants.Colors.textPrimary)
                                Spacer()
                            }
                            
                            Text(event.description)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(DesignConstants.Colors.textSecondary)
                                .lineSpacing(2)
                        }
                        .padding(12)
                        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
                        .cornerRadius(12)
                        
                        // MARK: - Additional Info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(categoryColor)
                                Text("Дополнительно")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(DesignConstants.Colors.textPrimary)
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(categoryColor)
                                        .frame(width: 20)
                                    Text("Категория: \(event.category)")
                                        .font(.system(size: 13))
                                    Spacer()
                                }
                                
                                Divider()
                                    .frame(height: 0.5)
                                
                                HStack {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(categoryColor)
                                        .frame(width: 20)
                                    Text("Для всех возрастов")
                                        .font(.system(size: 13))
                                    Spacer()
                                }
                                
                                Divider()
                                    .frame(height: 0.5)
                                
                                HStack {
                                    Image(systemName: "ticket.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(categoryColor)
                                        .frame(width: 20)
                                    Text("Предварительная регистрация")
                                        .font(.system(size: 13))
                                    Spacer()
                                }
                            }
                            .foregroundColor(DesignConstants.Colors.textSecondary)
                        }
                        .padding(12)
                        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
                        .cornerRadius(12)
                        
                        Spacer(minLength: 16)
                    }
                    .padding(12)
                }
            }
            
            // MARK: - Bottom Register Button
            VStack {
                Spacer()
                
                Button {
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
                    HStack(spacing: 10) {
                        if isLoadingRegistration {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: isRegistered ? "checkmark.circle.fill" : "ticket.fill")
                                .font(.system(size: 14))
                        }
                        Text(isRegistered ? "Зарегистрирован" : "Зарегистрироваться")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isRegistered ? DesignConstants.Colors.success : categoryColor,
                                isRegistered ? DesignConstants.Colors.success.opacity(0.8) : categoryColor.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoadingRegistration)
                .padding(12)
                .background(DesignConstants.Colors.background)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
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
}

// MARK: - Info Row Component
struct InfoRowNew: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DesignConstants.Colors.textSecondary)
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
}

#Preview {
    EventDetailView(event: Event(title: "Концерт классической музыки", description: "Приглашаем вас на вечер классической музыки с лучшими произведениями мировых композиторов.", date: "20.03.2026", location: "Филармония", imageName: nil, category: "Музыка"))
}
