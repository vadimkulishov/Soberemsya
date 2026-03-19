import SwiftUI

struct HomeView: View {
    let events = [
        Event(
            title: "Концерт классической музыки",
            date: "20 марта 2026",
            location: "Филармония",
            imageName: nil,
            description: "Приглашаем вас на вечер классической музыки. В программе: произведения Чайковского, Рахманинова и Моцарта. Исполняет симфонический оркестр под управлением заслуженного артиста России."
        ),
        Event(
            title: "Выставка современного искусства",
            date: "22 марта 2026",
            location: "Арт-галерея",
            imageName: nil,
            description: "Работы молодых художников в жанре абстракционизма и сюрреализма. Более 50 полотен, скульптуры и инсталляции."
        ),
        Event(
            title: "Хакатон по SwiftUI",
            date: "25 марта 2026",
            location: "Технопарк",
            imageName: nil,
            description: "48-часовой марафон по разработке приложений на SwiftUI. Команды от 2 до 4 человек. Призовой фонд 300 000 рублей."
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(events) { event in
                        EventsCard(event: event)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Главная")
        }
    }
}
