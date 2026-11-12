import SwiftUI
import UniformTypeIdentifiers

struct MercuryWorkspace: View {
    @State private var batch = ""
    @State private var probe = ""
    @State private var result = ""
    @State private var revision = 0
    @State private var importing = false
    private var rows: [String] { batch.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } }
    private var valid: [Int64] { Array(Set(rows.compactMap(BlockStore.normalized))).sorted() }
    private var invalid: [String] { rows.filter { BlockStore.normalized($0) == nil } }
    private var newNumbers: [Int64] { valid.filter { !BlockStore.numbers().contains($0) } }
    var body: some View {
        Form {
            Section {
                Label("MERCURY · LIST WORKSPACE", systemImage: "waveform.path.ecg").font(.headline).foregroundStyle(.mint)
                Text("Review each entry before it reaches your phone blocking list. Processing stays on this device.")
            }
            Section("1 · Import and inspect") {
                Text("One full international phone number per line. CSV columns, names, prefixes and wildcards are not supported.").font(.footnote)
                TextEditor(text: $batch).frame(minHeight: 120).accessibilityLabel("Numbers to inspect")
                Button("Open text file") { importing = true }
                Text("\(valid.count) unique valid · \(invalid.count) invalid · \(newNumbers.count) new")
                if !invalid.isEmpty {
                    ForEach(Array(invalid.prefix(10).enumerated()), id: \.offset) { row in
                        Text("Invalid: \(row.element)").foregroundStyle(.red)
                    }
                    Text("Correct or remove invalid lines before applying the import.").font(.footnote)
                }
                Button("Apply \(newNumbers.count) new numbers") {
                    let added = newNumbers.filter { BlockStore.add("+\($0)") }.count
                    result = "Saved \(added) numbers. Open Protection and refresh to apply them to iOS."
                    batch = ""; revision += 1
                }.disabled(newNumbers.isEmpty || !invalid.isEmpty || rows.count > 10000)
                if rows.count > 10000 { Text("Import at most 10,000 lines at a time.").foregroundStyle(.red) }
            }
            Section("2 · Check your own list") {
                TextField("International number", text: $probe).keyboardType(.phonePad)
                Button("Check saved list") {
                    guard let n = BlockStore.normalized(probe) else { result = "Enter a full international number."; return }
                    result = BlockStore.numbers().contains(n) ? "This number is in your saved list. Blocking also requires an active subscription, an enabled extension and a successful refresh." : "This number is absent from your saved list. This does not establish that the caller is safe."
                }
                Text("This checks your saved rules. It does not place a call, read call history or query a spam database.").font(.footnote)
            }
            Section("3 · Portable backup") {
                ShareLink("Export saved numbers", item: BlockStore.numbers().map { "+\($0)" }.joined(separator: "\n"))
                Text("The export contains personal phone numbers. Choose where to share it.").font(.footnote)
            }
            if !result.isEmpty { Section("Result") { Text(result).textSelection(.enabled) } }
        }
        .id(revision)
        .navigationTitle("Mercury Workspace")
        .fileImporter(isPresented: $importing, allowedContentTypes: [.plainText]) { outcome in
            do {
                let url = try outcome.get()
                guard url.startAccessingSecurityScopedResource() else { result = "File access was not granted."; return }
                defer { url.stopAccessingSecurityScopedResource() }
                let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                guard size <= 1_000_000 else { result = "Choose a text file smaller than 1 MB."; return }
                batch = try String(contentsOf: url, encoding: .utf8)
            } catch { result = "Could not import file: \(error.localizedDescription)" }
        }
    }
}
