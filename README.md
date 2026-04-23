<p align="center">
  <img src="Soberemsya/Assets.xcassets/AppIcon.appiconset/Frame 1.png" width="120" height="120" alt="Soberemsya Icon" style="border-radius: 22px;" />
</p>

<h1 align="center">Соберёмся</h1>

<p align="center">
  <strong>iOS и Apple Watch приложение для поиска и организации мероприятий в твоём городе</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=flat&logo=swift&logoColor=white" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/iOS-18.0+-000000?style=flat&logo=apple&logoColor=white" alt="iOS 18.0+" />
  <img src="https://img.shields.io/badge/SwiftUI-Framework-0071E3?style=flat&logo=swift&logoColor=white" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/watchOS-11.0+-000000?style=flat&logo=apple&logoColor=white" alt="watchOS 11.0+" />
  <img src="https://img.shields.io/badge/Xcode-16+-1575F9?style=flat&logo=xcode&logoColor=white" alt="Xcode 16+" />
  <img src="https://img.shields.io/badge/Architecture-MVVM-blueviolet?style=flat" alt="MVVM" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat" alt="License MIT" />
</p>

---

## 📱 О проекте

**Соберёмся** — это нативное iOS-приложение с companion-приложением для Apple Watch. Оно позволяет находить события поблизости, регистрироваться на них, сканировать QR-билеты и управлять своими мероприятиями. Дизайн выполнен в стиле Apple Health — минималистичный, чистый и с приятными анимациями.

Этот репозиторий теперь содержит только клиентское приложение. Серверная часть и web/admin-панель вынесены в отдельные репозитории:

- [Soberemsya](https://github.com/vadimkulishov/Soberemsya) — iOS + watchOS app
- [Soberemsya-backend](https://github.com/vadimkulishov/Soberemsya-backend) — FastAPI backend
- [Soberemsya-web](https://github.com/vadimkulishov/Soberemsya-web) — web/admin panel

### Ключевые возможности

- 🔍 **Поиск событий** — по категориям (музыка, спорт, театр, кино, образование, еда, путешествия, технологии)
- 📍 **Геолокация** — автоматическое определение города и фильтрация событий
- 🎫 **Регистрация на мероприятия** — в один клик с получением QR-билета
- 📱 **QR-код билетов** — генерация и отображение для прохода на мероприятие
- 📷 **Сканер QR** — для организаторов — проверка билетов посетителей
- ⌚ **Apple Watch** — отображение QR-билета прямо на часах
- 🌗 **Темы оформления** — светлая, тёмная и системная
- ✨ **Spring-анимации** — плавные пружинные анимации при взаимодействии

---

## 🏗️ Архитектура

Проект построен на паттерне **MVVM** (Model-View-ViewModel) с использованием нативных инструментов Apple.

```
Soberemsya/
├── 📁 Models/              # Модели данных
│   ├── City.swift           # Модель города
│   ├── Event.swift          # Модель мероприятия
│   ├── EventCategory.swift  # Категории событий
│   ├── PromoItem.swift      # Промо-акции
│   ├── Registration.swift   # Регистрация на событие
│   └── User.swift           # Модель пользователя
│
├── 📁 Views/               # Экраны и UI-компоненты
│   ├── 📁 Components/       # Переиспользуемые компоненты
│   │   ├── BannerCardComponent.swift
│   │   ├── CategoryCardComponent.swift
│   │   ├── EventCardComponent.swift
│   │   ├── HeaderComponent.swift
│   │   ├── PromoCardComponent.swift
│   │   ├── ScanResultCardComponent.swift
│   │   └── SectionCard.swift
│   ├── HomeView.swift        # Главный экран
│   ├── SearchView.swift      # Поиск по категориям
│   ├── AccountView.swift     # Профиль пользователя
│   ├── MenuBar.swift         # Нижняя навигация (TabView)
│   ├── EventsСard.swift      # Детальная карточка события
│   ├── RegisterView.swift    # Экран авторизации
│   ├── AddEventView.swift    # Добавление события
│   ├── CreateEventView.swift # Создание мероприятия
│   ├── MyEventsView.swift    # Мои мероприятия
│   ├── MyTicketsView.swift   # Мои билеты
│   ├── QRCodeDisplayView.swift  # Отображение QR-кода
│   ├── QRScannerView.swift      # Сканер QR-кодов
│   ├── CityPickerView.swift     # Выбор города
│   ├── SettingsView.swift       # Настройки
│   ├── ServerSettingsView.swift # Настройки сервера
│   ├── ThemePickerView.swift    # Выбор темы
│   ├── AuthenticationView.swift # Аутентификация
│   ├── AutoScrollPromoView.swift # Карусель промо-акций
│   ├── PromoShowcaseView.swift   # Витрина промо
│   ├── EmptyEventsView.swift     # Заглушка «нет событий»
│   └── ErrorStateView.swift      # Состояния ошибок
│
├── 📁 ViewModels/          # Логика экранов
│   ├── HomeViewModel.swift
│   ├── SearchViewModel.swift
│   ├── AccountViewModel.swift
│   ├── AddEventViewModel.swift
│   ├── RegisterViewModel.swift
│   └── TicketViewModel.swift
│
├── 📁 Services/            # Сетевой и бизнес-слой
│   ├── APIClient.swift      # HTTP-клиент (REST API)
│   ├── AuthManager.swift    # Управление авторизацией
│   ├── EventService.swift   # Загрузка мероприятий
│   ├── CityService.swift    # Работа с городами
│   ├── ThemeManager.swift   # Управление темой
│   ├── PromoManager.swift   # Промо-акции
│   ├── LocationManager.swift # Геолокация
│   ├── AppConfig.swift       # Конфигурация приложения
│   └── PhoneConnectivityManager.swift # Связь с Apple Watch
│
├── 📁 Helpers/             # Утилиты и расширения
│   ├── DesignConstants.swift    # Дизайн-система (цвета, шрифты, тени)
│   ├── ColorExtensions.swift    # Расширения для Color (hex)
│   ├── ViewExtensions.swift     # Расширения View (alert, toast)
│   ├── PressableButtonStyle.swift # Анимация нажатия для кнопок
│   ├── ImageLoader.swift        # Асинхронная загрузка изображений
│   └── ImagePicker.swift        # Выбор фото из галереи
│
├── 📁 Assets.xcassets/     # Ресурсы (иконки, изображения)
├── ContentView.swift        # Корневой View
└── SoberemsyaApp.swift      # Точка входа (@main)
```

### Apple Watch

```
Soberemsya Watch App Watch App/
├── ContentView.swift
├── Soberemsya_Watch_AppApp.swift
├── WatchConnectivityManager.swift   # WatchConnectivity для связи с iPhone
├── WatchQRDisplayView.swift         # Отображение QR на часах
└── Assets.xcassets/
```

---

## 🎨 Дизайн-система

Дизайн вдохновлён **Apple Health** — минималистичный интерфейс с системными цветами и мягкими тенями.

### Цвета

| Назначение | Светлая тема | Тёмная тема |
|:---|:---|:---|
| Фон | `systemBackground` | `systemGroupedBackground` |
| Карточки | `systemBackground` | `secondarySystemGroupedBackground` |
| Акцент | SF Blue `#007AFF` | SF Blue `#007AFF` |
| Текст | `label` | `label` |
| Вторичный текст | `secondaryLabel` | `secondaryLabel` |

### Категории событий

| Категория | Цвет | Иконка |
|:---|:---|:---|
| 🎵 Музыка | `#FF453A` | `music.note` |
| 🏃 Спорт | `#FF9F0A` | `figure.run` |
| 🎭 Театр | `#BF5AF2` | `theatermasks.fill` |
| 🎬 Кино | `#007AFF` | `film.fill` |
| 📚 Образование | `#3399E6` | `book.fill` |
| 🍕 Еда | `#FFCC00` | `fork.knife` |
| ✈️ Путешествия | `#33C759` | `airplane` |
| 💻 Технологии | `#00C7BF` | `desktopcomputer` |

### Типографика

Все шрифты — **SF Pro** (системные):

- `largeTitle` — 34pt Bold
- `title` — 28pt Bold
- `headline` — 17pt Semibold
- `body` — 17pt Regular
- `footnote` — 13pt Regular
- `caption` — 12pt Regular

### Тени

Три уровня глубины:

- **Subtle** — `opacity: 0.02, radius: 4` — для мелких элементов
- **Card** — `opacity: 0.04, radius: 8` — стандартная карточка
- **Card Hover** — `opacity: 0.08, radius: 12` — при нажатии

---

## ✨ Анимации

Приложение использует пружинные (spring) анимации для естественного, физически правдоподобного ощущения.

### Типы анимаций

| Анимация | Параметры | Где используется |
|:---|:---|:---|
| **Spring** | `response: 0.3, damping: 0.7` | Нажатие на карточки |
| **Spring Bouncy** | `response: 0.4, damping: 0.6` | Появление контента |
| **Ease Out** | `duration: 0.2` | Быстрые переходы |
| **Ease In-Out** | `duration: 0.3` | Плавные переключения |

### Интерактивные элементы

- **Карточки событий** — при нажатии плавно уменьшаются (`scale: 0.97`) с пружинной анимацией
- **Карточки категорий** — `scale: 0.96` при нажатии
- **Промо-карточки** — `scale: 0.97` + изменение глубины тени
- **Баннеры** — `scale: 0.97` с обратной связью

### Появление элементов

- **Карточки событий** — каскадное появление (`fade + slide-up`, задержка 0.08с между карточками)
- **Категории** — каскадное появление в сетке (задержка 0.05с)
- **Баннеры** — плавное появление (`fade + slide`, 0.5с)
- **Скелетоны загрузки** — shimmer-анимация во время загрузки данных

### Индикатор страниц

Карусель промо-акций использует адаптивный capsule-индикатор: текущая страница отображается вытянутой капсулой (20pt), остальные — компактными точками (6pt).

---

## 🔧 Технологический стек

| Технология | Назначение |
|:---|:---|
| **SwiftUI** | Весь UI |
| **Combine** | Реактивные подписки (EventService, APIClient) |
| **async/await** | Асинхронные операции |
| **CoreLocation** | Определение местоположения |
| **AVFoundation** | Сканирование QR-кодов через камеру |
| **CoreImage** | Генерация QR-кодов |
| **WatchConnectivity** | Связь между iPhone и Apple Watch |
| **URLSession** | Сетевые запросы к REST API |
| **NSCache** | Кэширование загруженных изображений |
| **UserDefaults** | Хранение настроек (тема, токен, город) |

---

## 📡 API

Приложение подключается к отдельному REST API серверу из репозитория [Soberemsya-backend](https://github.com/vadimkulishov/Soberemsya-backend). Конфигурация автоматически определяет окружение:

| Окружение | URL |
|:---|:---|
| Симулятор | `http://localhost:8002` |
| Устройство | `http://MacBook-Air-Vadim.local:8002` |

Серверный URL можно изменить в настройках приложения (**Аккаунт → Настройки → Настройки сервера**).

### Основные эндпоинты

| Метод | Путь | Описание |
|:---|:---|:---|
| `POST` | `/auth/login` | Авторизация |
| `POST` | `/auth/register` | Регистрация |
| `GET` | `/events` | Список мероприятий |
| `POST` | `/events` | Создание мероприятия |
| `GET` | `/events/{id}` | Детали мероприятия |
| `POST` | `/events/{id}/register` | Регистрация на мероприятие |
| `GET` | `/user/tickets` | Мои билеты |
| `POST` | `/qr/scan` | Сканирование QR-кода |
| `GET` | `/cities` | Список городов |

---

## 📂 Навигация по экранам

```
┌─────────────────────────────────────────┐
│              SoberemsyaApp              │
│         (ThemeManager + AuthManager)    │
└──────────────┬──────────────────────────┘
               │
         ContentView
               │
           MenuBar (TabView)
         ┌─────┼──────────┬──────────┐
         │     │          │          │
     Главная  Билеты  Аккаунт    Поиск
     (Home)  (Tickets) (Account) (Search)
         │     │          │          │
         │     │     ┌────┴────┐     │
         │     │     │         │     │
         │     │  Настройки  Выход  Категории
         │     │  (Settings)       (Grid)
         │     │     │               │
         │     │  Тема/Сервер    Детали
         │     │               категории
         │     │
    ┌────┴───┐ │
    │        │ │
  Промо   События ──→ Детали события
(Carousel) (Cards)     (EventDetailView)
                            │
                      Регистрация
                      (QR-билет)
```

---

## ⌚ Apple Watch

Companion-приложение для Apple Watch позволяет отображать QR-билет прямо на запястье. Связь между iPhone и Watch осуществляется через **WatchConnectivity**.

**Возможности:**
- Отображение QR-кода активного билета
- Синхронизация данных билетов с iPhone
- Минималистичный интерфейс на watchOS

---

## 🚀 Запуск проекта

### Требования

- macOS 15.0+
- Xcode 16+
- iOS 18.0+ (для запуска на устройстве/симуляторе)
- watchOS 11.0+ (для Watch App)

### Шаги

1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/yourusername/Soberemsya.git
   cd Soberemsya
   ```

2. Откройте проект в Xcode:
   ```bash
   open Soberemsya.xcodeproj
   ```

3. Выберите схему **Soberemsya** и целевое устройство (симулятор или физическое).

4. Нажмите **⌘R** для сборки и запуска.

5. Для полноценной работы приложения поднимите backend из отдельного репозитория [Soberemsya-backend](https://github.com/vadimkulishov/Soberemsya-backend).

---

## 🎯 Промо-акции

Приложение включает систему промо-акций с автоматической каруселью:

| Акция | Описание | Тип |
|:---|:---|:---|
| 🏷️ Скидка 50% | Первый билет за полцены | Скидка |
| ☀️ Летний фестиваль | Сезонные мероприятия | Сезонное |
| ⭐ VIP доступ | Эксклюзивный доступ | Новая функция |
| 🤝 Партнёрская программа | Сотрудничество с площадками | Партнёрство |
| 📢 Реклама места | Продвижение мероприятий | Реклама |
| ⏰ Ранняя регистрация | Экономия до 30% при ранней записи | Скидка |
| ✨ Выходные события | Лучшие мероприятия на выходных | Сезонное |
| 👥 Скидка для групп | Скидки при групповой регистрации | Скидка |
| 🏙️ Новое в городе | Свежие площадки и форматы | Новая функция |
| 🎁 Программа лояльности | Баллы за каждое посещение | Партнёрство |

---

## 📄 Лицензия

Этот проект распространяется под лицензией **MIT**. Подробности в файле [LICENSE](LICENSE).
