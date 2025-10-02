//
//  BulkImportView.swift
//  ExpressCoach
//
//  Bulk player import from CSV files or Google Sheets
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct BulkImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let team: Team

    @State private var importMethod: ImportMethod = .file
    @State private var googleSheetsURL: String = ""
    @State private var isImporting = false
    @State private var importResult: CSVImportResult?
    @State private var errorMessage: String?
    @State private var showingFilePicker = false
    @State private var showingSampleTemplate = false

    enum ImportMethod {
        case file
        case googleSheets
    }

    var body: some View {
        NavigationStack {
            Form {
                // Import Method Selection
                Section {
                    Picker("Import Method", selection: $importMethod) {
                        Label("CSV File", systemImage: "doc.text").tag(ImportMethod.file)
                        Label("Google Sheets", systemImage: "link").tag(ImportMethod.googleSheets)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Choose Import Method")
                } footer: {
                    Text("Import players from a CSV file or directly from Google Sheets")
                }

                // Import Options
                if importMethod == .file {
                    fileImportSection
                } else {
                    googleSheetsSection
                }

                // CSV Format Guide
                csvFormatSection

                // Import Results
                if let result = importResult {
                    importResultsSection(result: result)
                }

                // Error Display
                if let error = errorMessage {
                    Section {
                        Label {
                            Text(error)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Bulk Import Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .sheet(isPresented: $showingSampleTemplate) {
                SampleTemplateView()
            }
            .disabled(isImporting)
        }
    }

    // MARK: - File Import Section

    private var fileImportSection: some View {
        Section {
            Button {
                showingFilePicker = true
            } label: {
                Label("Select CSV File", systemImage: "doc.badge.plus")
            }
            .disabled(isImporting)

            Button {
                showingSampleTemplate = true
            } label: {
                Label("View Sample Template", systemImage: "doc.text.magnifyingglass")
            }
        } header: {
            Text("CSV File Import")
        } footer: {
            Text("Select a CSV file from your device. The file must include First Name and Last Name columns.")
        }
    }

    // MARK: - Google Sheets Section

    private var googleSheetsSection: some View {
        Section {
            TextField("Google Sheets URL", text: $googleSheetsURL, axis: .vertical)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .lineLimit(3...6)
                .disabled(isImporting)

            Button {
                importFromGoogleSheets()
            } label: {
                if isImporting {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Importing...")
                    }
                } else {
                    Label("Import from Google Sheets", systemImage: "square.and.arrow.down")
                }
            }
            .disabled(googleSheetsURL.isEmpty || isImporting)
        } header: {
            Text("Google Sheets Import")
        } footer: {
            VStack(alignment: .leading, spacing: 8) {
                Text("**How to import from Google Sheets:**")
                Text("1. Open your Google Sheet")
                Text("2. Click **Share** → **Anyone with the link**")
                Text("3. Copy the sharing URL")
                Text("4. Paste it above and tap Import")
                Text("\nThe sheet must include First Name and Last Name columns.")
            }
            .font(.caption)
        }
    }

    // MARK: - CSV Format Section

    private var csvFormatSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("**Required Columns:**")
                    .font(.subheadline)
                Text("• First Name\n• Last Name")
                    .font(.caption)

                Text("**Optional Columns:**")
                    .font(.subheadline)
                Text("• Jersey Number\n• Date of Birth (MM/DD/YYYY)\n• Parent Name\n• Parent Phone\n• Parent Email\n• Position\n• Graduation Year\n• Emergency Contact\n• Emergency Phone\n• Medical Notes")
                    .font(.caption)

                Text("Column names are case-insensitive and flexible (e.g., \"First Name\", \"FirstName\", or \"first_name\" all work).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("CSV Format")
        }
    }

    // MARK: - Import Results Section

    private func importResultsSection(result: CSVImportResult) -> some View {
        Section {
            HStack {
                Label("Successfully Imported", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Spacer()
                Text("\(result.successCount)")
                    .font(.headline)
            }

            if result.hasErrors {
                HStack {
                    Label("Failed", systemImage: "xmark.circle.fill")
                        .foregroundStyle(.red)
                    Spacer()
                    Text("\(result.failedRows.count)")
                        .font(.headline)
                }

                NavigationLink {
                    FailedRowsDetailView(failedRows: result.failedRows)
                } label: {
                    Label("View Failed Rows", systemImage: "list.bullet.clipboard")
                }
            }

            HStack {
                Text("Success Rate")
                Spacer()
                Text(result.successRate, format: .percent.precision(.fractionLength(0)))
                    .font(.headline)
                    .foregroundStyle(result.successRate > 0.9 ? .green : .orange)
            }
        } header: {
            Text("Import Results")
        }
    }

    // MARK: - Import Actions

    private func handleFileImport(_ result: Result<[URL], Error>) {
        Task {
            do {
                let urls = try result.get()
                guard let url = urls.first else { return }

                // Start accessing security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    errorMessage = "Unable to access the selected file"
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }

                isImporting = true
                errorMessage = nil
                importResult = nil

                let csvContent = try String(contentsOf: url, encoding: .utf8)
                try await performImport(csvContent: csvContent)

            } catch {
                errorMessage = "Failed to read file: \(error.localizedDescription)"
            }

            isImporting = false
        }
    }

    private func importFromGoogleSheets() {
        Task {
            do {
                isImporting = true
                errorMessage = nil
                importResult = nil

                guard let exportURL = CSVImportService.convertGoogleSheetsURL(googleSheetsURL) else {
                    throw CSVImportError.invalidGoogleSheetsURL
                }

                let service = CSVImportService()
                let playerRows = try await service.downloadAndParseCSV(from: exportURL)
                let result = service.importPlayers(playerRows, to: team, modelContext: modelContext)

                self.importResult = result

            } catch let error as CSVImportError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "Failed to import from Google Sheets: \(error.localizedDescription)"
            }

            isImporting = false
        }
    }

    private func performImport(csvContent: String) async throws {
        let service = CSVImportService()
        let playerRows = try service.parseCSV(csvContent)
        let result = service.importPlayers(playerRows, to: team, modelContext: modelContext)
        self.importResult = result
    }
}

// MARK: - Sample Template View

struct SampleTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Use this template as a guide for formatting your CSV file. Copy it to Google Sheets or Excel to get started.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()

                    Text(CSVImportService.generateSampleTemplate())
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("**Tips:**")
                            .font(.headline)
                        Text("• First two columns (First Name, Last Name) are required")
                        Text("• Other columns are optional")
                        Text("• Date format: MM/DD/YYYY")
                        Text("• Phone format: Any format works")
                        Text("• You can omit columns you don't need")
                    }
                    .font(.subheadline)
                    .padding()
                }
            }
            .navigationTitle("Sample Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let data = CSVImportService.generateSampleTemplate().data(using: .utf8),
                   let url = saveTemplateToTempFile(data: data) {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private func saveTemplateToTempFile(data: Data) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("roster_template.csv")
        try? data.write(to: fileURL)
        return fileURL
    }
}

// MARK: - Failed Rows Detail View

struct FailedRowsDetailView: View {
    let failedRows: [(row: Int, reason: String)]

    var body: some View {
        List {
            ForEach(failedRows, id: \.row) { failure in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Row \(failure.row)")
                        .font(.headline)
                    Text(failure.reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Failed Rows")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    BulkImportView(team: Team(name: "Express Elite", teamCode: "ABC123", ageGroup: "U14", season: "Spring 2024"))
        .modelContainer(for: [Team.self, Player.self], inMemory: true)
}