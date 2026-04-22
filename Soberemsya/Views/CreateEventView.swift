import SwiftUI

struct CreateEventView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = AddEventViewModel()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Image selector
                        ZStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray5))
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.badge.plus")
                                                .font(.title)
                                            Text("Выберите изображение")
                                                .font(.caption)
                                        }
                                    )
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                        .onTapGesture {
                            showImagePicker = true
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(image: $selectedImage)
                        }
                        
                        // Form fields
                        VStack(spacing: 16) {
                            // Title
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Название события", systemImage: "pencil")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                TextField("Название", text: $viewModel.title)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            // Date
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Дата события", systemImage: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                TextField("День месяца", text: $viewModel.date)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            // Location
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Место проведения", systemImage: "mappin")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                TextField("Адрес", text: $viewModel.location)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            // Category
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Категория", systemImage: "tag")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Picker("Категория", selection: $viewModel.category) {
                                    ForEach(["Музыка", "Спорт", "Театр", "Кино", "Образование", "Еда", "Путешествия", "Технологии"], id: \.self) { category in
                                        Text(category).tag(category)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Описание", systemImage: "text.alignleft")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                TextEditor(text: $viewModel.description)
                                    .frame(height: 120)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                            }
                            
                            // Create button
                            Button(action: createEvent) {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Создать событие")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignConstants.Colors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(isLoading || viewModel.title.isEmpty)
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle("Создать событие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .alert("Ошибка", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "Неизвестная ошибка")
            }
        }
    }
    
    private func createEvent() {
        isLoading = true
        
        // Set image URL if image was selected
        if selectedImage != nil {
            // TODO: Upload image to server and set URL
            // For now, just use a placeholder
            viewModel.image_url = "https://picsum.photos/400/300?random=\(Int.random(in: 1...1000))"
        }
        
        viewModel.createEvent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    CreateEventView()
        .environmentObject(AuthManager.shared)
        .environmentObject(ThemeManager.shared)
}
