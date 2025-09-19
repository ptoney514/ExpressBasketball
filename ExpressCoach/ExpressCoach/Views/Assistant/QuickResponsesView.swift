import SwiftUI
import SwiftData

struct QuickResponsesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuickResponse.usageCount, order: .reverse) private var responses: [QuickResponse]
    @State private var selectedCategory: QuestionCategory? = nil
    @State private var showingAddTemplate = false
    @State private var editingResponse: QuickResponse?

    var filteredResponses: [QuickResponse] {
        if let category = selectedCategory {
            return responses.filter { $0.category == category }
        }
        return responses
    }

    var responsesByCategory: [QuestionCategory: [QuickResponse]] {
        Dictionary(grouping: responses, by: { $0.category })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategoryFilter(selectedCategory: $selectedCategory)

                if responses.isEmpty {
                    EmptyTemplatesView(onAdd: {
                        showingAddTemplate = true
                    })
                } else if filteredResponses.isEmpty {
                    NoResultsView(category: selectedCategory)
                } else {
                    List {
                        if selectedCategory == nil {
                            ForEach(QuestionCategory.allCases, id: \.self) { category in
                                if let categoryResponses = responsesByCategory[category], !categoryResponses.isEmpty {
                                    Section {
                                        ForEach(categoryResponses) { response in
                                            QuickResponseRow(response: response) {
                                                editingResponse = response
                                            }
                                        }
                                        .onDelete { indexSet in
                                            deleteResponses(categoryResponses, at: indexSet)
                                        }
                                    } header: {
                                        Label(category.rawValue, systemImage: category.icon)
                                            .foregroundColor(Color(category.color))
                                    }
                                }
                            }
                        } else {
                            ForEach(filteredResponses) { response in
                                QuickResponseRow(response: response) {
                                    editingResponse = response
                                }
                            }
                            .onDelete { indexSet in
                                deleteResponses(filteredResponses, at: indexSet)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTemplate = true
                    }) {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: loadDefaultTemplates) {
                            Label("Load Defaults", systemImage: "arrow.down.doc")
                        }

                        Button(action: resetUsageStats) {
                            Label("Reset Stats", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddTemplate) {
                AddQuickResponseView()
            }
            .sheet(item: $editingResponse) { response in
                EditQuickResponseView(response: response)
            }
        }
        .onAppear {
            if responses.isEmpty {
                loadDefaultTemplates()
            }
        }
    }

    private func deleteResponses(_ responses: [QuickResponse], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(responses[index])
        }
        try? modelContext.save()
    }

    private func loadDefaultTemplates() {
        for template in QuickResponse.defaultTemplates {
            modelContext.insert(template)
        }
        try? modelContext.save()
    }

    private func resetUsageStats() {
        for response in responses {
            response.usageCount = 0
            response.lastUsed = nil
        }
        try? modelContext.save()
    }
}

struct CategoryFilter: View {
    @Binding var selectedCategory: QuestionCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    color: .gray,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(QuestionCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: Color(category.color),
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.05))
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct QuickResponseRow: View {
    let response: QuickResponse
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(response.title)
                        .font(.headline)

                    HStack {
                        if response.isAIGenerated {
                            Label("AI Generated", systemImage: "sparkles")
                                .font(.caption2)
                                .foregroundColor(.purple)
                        }

                        if response.isCustom {
                            Label("Custom", systemImage: "person.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }

                        if response.usageCount > 0 {
                            Label("Used \(response.usageCount)x", systemImage: "chart.bar.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }

                Spacer()

                Button(action: onEdit) {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.gray)
                }
            }

            Text(response.template)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if !response.keywords.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(response.keywords, id: \.self) { keyword in
                            Text(keyword)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddQuickResponseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var template = ""
    @State private var category = QuestionCategory.general
    @State private var keywords = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Template Details") {
                    TextField("Title", text: $title)

                    Picker("Category", selection: $category) {
                        ForEach(QuestionCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }

                Section("Template Message") {
                    TextEditor(text: $template)
                        .frame(minHeight: 100)

                    Text("Use placeholders like {time}, {location}, {uniform_color}")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Keywords") {
                    TextField("Comma-separated keywords", text: $keywords)
                    Text("Keywords help match this template to parent questions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty || template.isEmpty)
                }
            }
        }
    }

    private func saveTemplate() {
        let keywordArray = keywords
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let response = QuickResponse(
            title: title,
            template: template,
            category: category,
            keywords: keywordArray,
            isCustom: true
        )

        modelContext.insert(response)
        try? modelContext.save()
        dismiss()
    }
}

struct EditQuickResponseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var response: QuickResponse
    @State private var title: String
    @State private var template: String
    @State private var category: QuestionCategory
    @State private var keywords: String

    init(response: QuickResponse) {
        self.response = response
        _title = State(initialValue: response.title)
        _template = State(initialValue: response.template)
        _category = State(initialValue: response.category)
        _keywords = State(initialValue: response.keywords.joined(separator: ", "))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Template Details") {
                    TextField("Title", text: $title)

                    Picker("Category", selection: $category) {
                        ForEach(QuestionCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }

                Section("Template Message") {
                    TextEditor(text: $template)
                        .frame(minHeight: 100)
                }

                Section("Keywords") {
                    TextField("Comma-separated keywords", text: $keywords)
                }

                if response.usageCount > 0 {
                    Section("Statistics") {
                        HStack {
                            Text("Times Used")
                            Spacer()
                            Text("\(response.usageCount)")
                                .foregroundColor(.secondary)
                        }

                        if let lastUsed = response.lastUsed {
                            HStack {
                                Text("Last Used")
                                Spacer()
                                Text(lastUsed, style: .date)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveChanges() {
        response.title = title
        response.template = template
        response.category = category
        response.keywords = keywords
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        try? modelContext.save()
        dismiss()
    }
}

struct EmptyTemplatesView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "text.bubble")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text("No Templates Yet")
                .font(.headline)

            Text("Create templates to quickly respond to common parent questions")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onAdd) {
                Label("Add Template", systemImage: "plus")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color("BasketballOrange"))
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }

            Spacer()
        }
    }
}

struct NoResultsView: View {
    let category: QuestionCategory?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: category?.icon ?? "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text("No templates in \(category?.rawValue ?? "this category")")
                .font(.headline)
                .foregroundColor(.secondary)

            Spacer()
        }
    }
}