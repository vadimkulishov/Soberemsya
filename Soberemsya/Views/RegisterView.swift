import SwiftUI

struct RegisterView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var ticketViewModel = TicketViewModel()
    @State private var showCopiedToast = false

    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignConstants.sectionSpacing) {
                        // QR Code section
                        qrSection

                        // My tickets section
                        ticketsSection
                    }
                    .padding(.horizontal, DesignConstants.padding)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }

                // Toast
                if showCopiedToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DesignConstants.Colors.success)
                            Text("Токен скопирован")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
                        .padding(.bottom, 32)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Мой билет")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                ticketViewModel.getQRCode()
                ticketViewModel.loadMyTickets()
            }
            .errorAlert(error: $ticketViewModel.error)
            .animation(.easeInOut(duration: 0.25), value: showCopiedToast)
        }
    }

    // MARK: - QR Section

    private var qrSection: some View {
        VStack(spacing: 16) {
            if let token = ticketViewModel.qrToken {
                VStack(spacing: 16) {
                    // QR Code
                    QRCodeView(data: token.token)
                        .frame(width: 200, height: 200)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(DesignConstants.cornerRadius)

                    Text("Покажите код при входе на мероприятие")
                        .font(.system(size: 13))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                        .multilineTextAlignment(.center)

                    // Expiration
                    if !token.expiresAt.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text("до \(formatDate(token.expiresAt))")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(DesignConstants.Colors.textTertiary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
                        .cornerRadius(20)
                    }

                    // Actions
                    HStack(spacing: 10) {
                        Button(action: copyToken) {
                            Label("Скопировать", systemImage: "doc.on.doc")
                                .font(.system(size: 13, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(DesignConstants.Colors.primary.opacity(0.1))
                                .foregroundColor(DesignConstants.Colors.primary)
                                .cornerRadius(DesignConstants.smallCornerRadius)
                        }

                        Button(action: { ticketViewModel.generateQRCode() }) {
                            Label("Обновить", systemImage: "arrow.clockwise")
                                .font(.system(size: 13, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(DesignConstants.Colors.primary.opacity(0.1))
                                .foregroundColor(DesignConstants.Colors.primary)
                                .cornerRadius(DesignConstants.smallCornerRadius)
                        }
                    }
                }
                .padding(DesignConstants.largePadding)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Загрузка QR-кода...")
                        .font(.system(size: 14))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.largeCornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Tickets Section

    private var ticketsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.spacing) {
            HStack {
                Text("Мои регистрации")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)

                Spacer()

                if let count = ticketViewModel.userTickets?.registrations.count, count > 0 {
                    Text("\(count)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DesignConstants.Colors.textTertiary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
                        .cornerRadius(12)
                }
            }

            if let userTickets = ticketViewModel.userTickets {
                if userTickets.registrations.isEmpty {
                    emptyTicketsView
                } else {
                    VStack(spacing: 10) {
                        ForEach(userTickets.registrations) { registration in
                            ticketRow(registration)
                        }
                    }
                }
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 24)
            }
        }
    }

    // MARK: - Ticket Row

    private func ticketRow(_ registration: EventRegistration) -> some View {
        let event = registration.event
        let categoryColor = DesignConstants.Colors.categoryColor(for: event.category)

        return HStack(spacing: 12) {
            // Category indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(categoryColor)
                .frame(width: 4, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label(event.date, systemImage: "calendar")
                    Label(event.location, systemImage: "mappin")
                        .lineLimit(1)
                }
                .font(.system(size: 12))
                .foregroundColor(DesignConstants.Colors.textSecondary)
            }

            Spacer()

            Text(event.category)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(categoryColor)
                .cornerRadius(6)
        }
        .padding(14)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }

    // MARK: - Empty State

    private var emptyTicketsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "ticket")
                .font(.system(size: 36))
                .foregroundColor(DesignConstants.Colors.textTertiary)

            Text("Нет регистраций")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(DesignConstants.Colors.textSecondary)

            Text("Зарегистрируйтесь на событие, и оно появится здесь")
                .font(.system(size: 13))
                .foregroundColor(DesignConstants.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
    }

    // MARK: - Methods

    private func copyToken() {
        guard let token = ticketViewModel.qrToken?.token else { return }
        UIPasteboard.general.string = token

        withAnimation {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedToast = false
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            displayFormatter.locale = Locale(identifier: "ru_RU")
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    RegisterView()
}
