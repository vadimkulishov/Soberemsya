import SwiftUI

struct EventsCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Картинка мероприятия
            if let imageName = event.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
            } else {
                // Заглушка, если нет картинки
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(12)
            }
            
            // Информация о мероприятии
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(event.date)
                        .font(.caption)
                    
                    Spacer()
                    
                    Image(systemName: "mappin.circle")
                        .font(.caption)
                    Text(event.location)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(.secondary)
                
                // Кнопка "Подробнее"
                NavigationLink {
                    EventDetailView(event: event)
                } label: {
                    HStack {
                        Text("Подробнее")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// Детальный экран мероприятия
struct EventDetailView: View {
    let event: Event
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Большая картинка
                if let imageName = event.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Название
                    Text(event.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Дата и место
                    HStack {
                        Label(event.date, systemImage: "calendar")
                        Spacer()
                        Label(event.location, systemImage: "mappin.circle")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Описание
                    Text("О мероприятии")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(event.description)
                        .font(.body)
                        .lineSpacing(4)
                    
//                    Spacer(minLength: 30)
                    
                    // Кнопка регистрации (пример)
                    Button {
                        print("Зарегистрироваться на \(event.title)")
                    } label: {
                        Text("Зарегистрироваться")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Детали")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Модель данных
struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let location: String
    let imageName: String?
    let description: String
}
