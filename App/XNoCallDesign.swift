import SwiftUI

struct XNoCallHero: View {
    let savedCount: Int
    let extensionEnabled: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image("XNoCallBrand").resizable().scaledToFit().frame(width: 84, height: 84).clipShape(RoundedRectangle(cornerRadius: 20))
                VStack(alignment: .leading, spacing: 5) {
                    Text("XNoCall").font(.largeTitle.bold())
                    Text("Your rules. Your peace.").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            HStack {
                Label("\(savedCount) saved rules", systemImage: "list.bullet.rectangle")
                Spacer()
                Label(extensionEnabled ? "Extension on" : "Setup needed", systemImage: extensionEnabled ? "checkmark.circle.fill" : "circle.dashed")
                    .foregroundStyle(extensionEnabled ? Color.mint : Color.orange)
            }.font(.caption)
            Text("Save → inspect → enable → refresh").font(.caption.monospaced()).foregroundStyle(.cyan)
        }
        .padding(20)
        .background(Color(red: 0.04, green: 0.06, blue: 0.14), in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(AngularGradient(colors: [.cyan, .blue, .purple, .pink, .orange, .green, .cyan], center: .center), lineWidth: 2)
                .opacity(pulse ? 1 : 0.45)
        }
        .onAppear {
            guard !reduceMotion && !ProcessInfo.processInfo.arguments.contains("-ui-testing") else { return }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

struct RuleNotebook: View {
    @State private var numbers = BlockStore.numbers()
    @State private var search = ""
    @State private var selected: Int64?
    @State private var label = ""
    @State private var reason = "Unwanted call"
    @State private var note = ""
    @State private var saved = false
    private var filtered: [Int64] {
        numbers.filter { search.isEmpty || String($0).contains(search) || RuleNotes.read($0).label.localizedCaseInsensitiveContains(search) }
    }
    var body: some View {
        List {
            Section {
                Text("Keep your own reason for each saved rule. Notes stay on this device and are never sent to a caller or a spam database.").font(.footnote)
            }
            Section("Saved rules") {
                if numbers.isEmpty { ContentUnavailableView("No saved rules", systemImage: "note.text", description: Text("Add a number on the Protection screen, then return here to record your decision.")) }
                ForEach(filtered, id: \.self) { number in
                    Button {
                        let entry = RuleNotes.read(number)
                        selected = number; label = entry.label; reason = entry.reason; note = entry.note; saved = false
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("+\(number)").font(.headline).foregroundStyle(.primary)
                            let entry = RuleNotes.read(number)
                            Text(entry.label.isEmpty ? "Add a private label" : entry.label).foregroundStyle(.cyan)
                            Text(entry.reason).font(.caption).foregroundStyle(.secondary)
                        }.padding(.vertical, 5)
                    }
                }
            }
            Section("Decision record") {
                Text("Labels do not identify callers. Editing a note does not change the blocking list. Apply number changes from Protection and refresh the iOS extension.").font(.footnote)
            }
        }
        .searchable(text: $search, prompt: "Find number or private label")
        .navigationTitle("Rule notebook")
        .sheet(isPresented: Binding(get: { selected != nil }, set: { if !$0 { selected = nil } })) {
            NavigationStack {
                Form {
                    Section("+\(selected ?? 0)") {
                        TextField("Private label", text: $label).accessibilityIdentifier("ruleLabel")
                        Picker("Reason", selection: $reason) {
                            ForEach(["Unwanted call", "Repeated sales", "Personal choice", "Other"], id: \.self) { Text($0) }
                        }
                        TextField("Decision notes", text: $note, axis: .vertical).lineLimit(3...6)
                    }
                    Button("Save decision") {
                        guard let selected else { return }
                        RuleNotes.save(selected, label: String(label.prefix(80)), reason: reason, note: String(note.prefix(2000)))
                        saved = true
                    }
                    if saved { Label("Saved on this device", systemImage: "checkmark.circle.fill").foregroundStyle(.mint) }
                }
                .navigationTitle("Private rule")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { selected = nil } } }
            }
        }
        .onAppear { numbers = BlockStore.numbers() }
    }
}

enum RuleNotes {
    struct Entry: Codable { var label: String; var reason: String; var note: String }
    static func read(_ number: Int64) -> Entry {
        guard let data = UserDefaults.standard.data(forKey: "xn.rule.\(number)"), let entry = try? JSONDecoder().decode(Entry.self, from: data) else { return Entry(label: "", reason: "Personal choice", note: "") }
        return entry
    }
    static func save(_ number: Int64, label: String, reason: String, note: String) {
        guard let data = try? JSONEncoder().encode(Entry(label: label, reason: reason, note: note)) else { return }
        UserDefaults.standard.set(data, forKey: "xn.rule.\(number)")
    }
    static func remove(_ number: Int64) { UserDefaults.standard.removeObject(forKey: "xn.rule.\(number)") }
}
