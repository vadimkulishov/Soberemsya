import SwiftUI

struct MyTicketsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var ticketViewModel = TicketViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()

                if let userTickets = ticketViewModel.userTickets {
                    if userTickets.registrations.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(userTickets.registrations) { registration in
                                    ticketCard(registration)
                                }
                            }
                            .padding(.horizontal, DesignConstants.padding)
                            .padding(.top, 8)
                            .padding(.bottom, 40)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Загрузка билетов...")
                            .font(.system(size: 14))
                            .foregroundColor(DesignConstants.Colors.textSecondary)
                    }
                }
            }
            .navigationTitle("Мои билеты")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { ticketViewModel.loadMyTickets() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14))
                    }
                }
            }
            .onAppear {
                ticketViewModel.loadMyTickets()
            }
            .errorAlert(error: $ticketViewModel.error)
        }
    }

    // MARK: - Ticket Card

    private func ticketCard(_ registration: EventRegistration) -> some View {
        let event = registration.event
        let categoryColor = DesignConstants.Colors.categoryColor(for: event.category)

        return VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                // Category icon
                RoundedRectangle(cornerRadius: 3)
                    .fill(categoryColor)
                    .frame(width: 4, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                        .lineLimit(2)

                    Text(event.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(categoryColor)
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DesignConstants.Colors.success)
            }
            .padding(DesignConstants.padding)

            Divider()
                .padding(.horizontal, DesignConstants.padding)

            // Details
            VStack(spacing: 10) {
                detailRow(icon: "calendar", label: "Дата", value: event.date)
                detailRow(icon: "mappin.circle", label: "Место", value: event.location)
                detailRow(icon: "clock", label: "Зарегистрирован", value: formatDate(registration.registeredAt))
            }
            .padding(DesignConstants.padding)

            // Description
            if !event.description.isEmpty {
                Divider()
                    .padding(.horizontal, DesignConstants.padding)

                Text(event.description)
                    .font(.system(size: 13))
                    .foregroundColor(DesignConstants.Colors.textSecondary)
                    .lineLimit(3)
                    .padding(DesignConstants.padding)
            }
        }
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(DesignConstants.Colors.textTertiary)
                .frame(width: 20, alignment: .center)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(DesignConstants.Colors.textTertiary)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DesignConstants.Colors.textPrimary)
                .lineLimit(1)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "ticket")
                .font(.system(size: 48))
                .foregroundColor(DesignConstants.Colors.textTertiary)

            VStack(spacing: 6) {
                Text("Пока нет билетов")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)

                Text("Зарегистрируйтесь на событие, чтобы получить билет")
                    .font(.system(size: 14))
                    .foregroundColor(DesignConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }

    // MARK: - Helpers

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
    MyTicketsView()
}
