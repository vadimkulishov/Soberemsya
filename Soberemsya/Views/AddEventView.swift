import SwiftUI

struct AddEventView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddEventViewModel()
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var showSuccess = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Cover image
                        imageSection

                        // Form fields
                        VStack(spacing: 0) {
                            formField(label: "Название", placeholder: "Джазовый вечер в парке", text: $viewModel.title)

                            Divider().padding(.leading, 16)

                            descriptionField

                            Divider().padding(.leading, 16)

                            locationField

                            Divider().padding(.leading, 16)

                            dateField
                        }
                        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
                        .cornerRadius(DesignConstants.cornerRadius)

                        // Category
                        categorySection

                        // Capacity
                        capacitySection

                        // Submit
                        submitButton

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, DesignConstants.padding)
                    .padding(.top, 8)
                }

                // Success toast
                if showSuccess {
                    VStack {
                        successToast
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationTitle("Новое событие")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
            }
            .alert("Ошибка", isPresented: $showError) {
                Button("ОК") {}
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Произошла ошибка")
            }
            .animation(.easeInOut(duration: 0.3), value: showSuccess)
        }
    }

    // MARK: - Image Section

    private var imageSection: some View {
        Button { showImagePicker = true } label: {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .overlay(alignment: .bottomTrailing) {
                        Label("Изменить", systemImage: "camera.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(12)
                    }
                    .cornerRadius(DesignConstants.cornerRadius)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 28))
                        .foregroundColor(DesignConstants.Colors.primary)

                    Text("Добавить обложку")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignConstants.Colors.primary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
                .cornerRadius(DesignConstants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                        .foregroundColor(DesignConstants.Colors.primary.opacity(0.3))
                )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Form Fields

    private func formField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(DesignConstants.Colors.textTertiary)
                .padding(.top, 12)

            TextField(placeholder, text: text)
                .font(.system(size: 16))
                .padding(.bottom, 12)
        }
        .padding(.horizontal, 16)
    }

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Описание")
                .font(.system(size: 12))
                .foregroundColor(DesignConstants.Colors.textTertiary)
                .padding(.top, 12)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.description)
                    .font(.system(size: 16))
                    .frame(minHeight: 80, maxHeight: 120)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)

                if viewModel.description.isEmpty {
                    Text("Расскажите о событии...")
                        .font(.system(size: 16))
                        .foregroundColor(Color(.placeholderText))
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 16)
    }

    private var locationField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Место")
                .font(.system(size: 12))
                .foregroundColor(DesignConstants.Colors.textTertiary)
                .padding(.top, 12)

            HStack(spacing: 8) {
                Image(systemName: "mappin")
                    .font(.system(size: 14))
                    .foregroundColor(DesignConstants.Colors.textTertiary)

                TextField("Адрес или название места", text: $viewModel.location)
                    .font(.system(size: 16))
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 16)
    }

    private var dateField: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Дата и время")
                    .font(.system(size: 12))
                    .foregroundColor(DesignConstants.Colors.textTertiary)
            }

            Spacer()

            DatePicker(
                "",
                selection: $viewModel.selectedDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Категория")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DesignConstants.Colors.textSecondary)
                .padding(.leading, 4)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(EventCategory.allCategories) { cat in
                    let isSelected = viewModel.selectedCategory == cat.title
                    let color = Color(hex: cat.color)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedCategory = cat.title
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 18))
                                .frame(width: 40, height: 40)
                                .background(isSelected ? color : color.opacity(0.1))
                                .foregroundColor(isSelected ? .white : color)
                                .clipShape(Circle())

                            Text(cat.title)
                                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? DesignConstants.Colors.textPrimary : DesignConstants.Colors.textSecondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? color.opacity(0.08) : Color.clear)
                        .cornerRadius(DesignConstants.smallCornerRadius)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
            .cornerRadius(DesignConstants.cornerRadius)
        }
    }

    // MARK: - Capacity

    private var capacitySection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Вместимость")
                    .font(.system(size: 16))
                    .foregroundColor(DesignConstants.Colors.textPrimary)

                Text(viewModel.capacity == 0 ? "Без ограничений" : "\(viewModel.capacity) человек")
                    .font(.system(size: 13))
                    .foregroundColor(DesignConstants.Colors.textSecondary)
            }

            Spacer()

            HStack(spacing: 16) {
                Button {
                    if viewModel.capacity >= 10 {
                        viewModel.capacity -= 10
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(viewModel.capacity == 0 ? DesignConstants.Colors.textTertiary : DesignConstants.Colors.primary)
                }
                .disabled(viewModel.capacity == 0)

                Text("\(viewModel.capacity)")
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                    .frame(minWidth: 44)
                    .foregroundColor(DesignConstants.Colors.textPrimary)

                Button {
                    viewModel.capacity += 10
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(DesignConstants.Colors.primary)
                }
            }
        }
        .padding(16)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
    }

    // MARK: - Submit

    private var isFormReady: Bool {
        !viewModel.title.isEmpty &&
        !viewModel.description.isEmpty &&
        !viewModel.location.isEmpty &&
        !viewModel.selectedCategory.isEmpty
    }

    private var submitButton: some View {
        Button(action: submitEvent) {
            HStack(spacing: 8) {
                if viewModel.isCreating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Создать событие")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isFormReady ? DesignConstants.Colors.primary : DesignConstants.Colors.primary.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(DesignConstants.cornerRadius)
        }
        .disabled(!isFormReady || viewModel.isCreating)
    }

    private func submitEvent() {
        // Prepare ViewModel fields before submit
        viewModel.selectedImage = image
        viewModel.category = viewModel.selectedCategory

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        viewModel.date = formatter.string(from: viewModel.selectedDate)

        viewModel.createEvent()

        // Observe result
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if viewModel.error != nil {
                showError = true
            } else {
                withAnimation {
                    showSuccess = true
                    image = nil
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { showSuccess = false }
                }
            }
        }
    }

    // MARK: - Toast

    private var successToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(DesignConstants.Colors.success)
            Text("Событие создано!")
                .font(.system(size: 14, weight: .medium))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
        .padding(.top, 60)
    }
}

#Preview {
    AddEventView()
        .environmentObject(AuthManager.shared)
}
