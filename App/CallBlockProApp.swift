import SwiftUI
import CallKit
import StoreKit

@main
struct CallBlockProApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}

struct ContentView: View {
    @State private var input = ""
    @State private var numbers = BlockStore.numbers()
    @State private var message = "Enable CallBlock Pro in Settings → Apps → Phone → Call Blocking & Identification."
    @State private var products: [Product] = []
    @State private var isSubscribed = false
    @State private var extensionEnabled = false
    private let productID = "callblockpro.annual"

    var body: some View {
        NavigationStack {
            Form {
                Section("Protection") {
                    Label("CallBlock Pro", systemImage: "shield.lefthalf.filled")
                    Text(message).font(.footnote)
                    Button("Refresh phone blocking") { refresh() }
                    Label(extensionEnabled ? "iOS extension enabled" : "Enable extension in iOS Settings", systemImage: extensionEnabled ? "checkmark.shield" : "exclamationmark.shield")
                }
                Section("Block a complete international number") {
                    TextField("Example: +441234567890", text: $input)
                        .keyboardType(.phonePad)
                    Button("Add number") {
                        if BlockStore.add(input) {
                            input = ""; numbers = BlockStore.numbers(); refresh()
                        } else { message = "Enter a complete number with 7–15 digits and country code." }
                    }
                    ForEach(numbers, id: \.self) { number in
                        HStack {
                            Text("+\(number)")
                            Spacer()
                            Button(role: .destructive) {
                                BlockStore.remove(number); numbers = BlockStore.numbers(); refresh()
                            } label: { Image(systemName: "trash") }
                        }
                    }
                }
                Section("Country prefixes") {
                    Text("A country prefix alone cannot be registered as a wildcard with Apple's Call Directory API. Add full numbers from that country. Bulk number imports require validation and platform limits.")
                        .font(.footnote)
                }
                Section("WhatsApp") {
                    Text("WhatsApp calls cannot be blocked by this extension. In WhatsApp, open Settings → Privacy → Calls → Silence Unknown Callers, or block individual contacts.")
                        .font(.footnote)
                }
                Section("Premium • $19.99/year") {
                    Text("Eligible new subscribers may receive a 3-day free trial. Final terms and regional price are shown by Apple before purchase.")
                    if isSubscribed { Label("Premium active", systemImage: "checkmark.seal.fill") }
                    else if let product = products.first {
                        Button("Subscribe: \(product.displayPrice)/year") { Task { await purchase(product) } }
                    } else { Text("Subscription not configured in App Store Connect yet.") }
                    Button("Restore purchases") { Task { await restore() } }
                }
            }
            .navigationTitle("CallBlock Pro")
            .task { await loadProducts(); await checkEntitlements(); checkExtension() }
        }
    }

    private func checkExtension() {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: "com.callblockpro.app.directory") { status, _ in
            DispatchQueue.main.async { extensionEnabled = (status == .enabled) }
        }
    }
    private func refresh() {
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.callblockpro.app.directory") { error in
            DispatchQueue.main.async {
                message = error.map { "Could not refresh: \($0.localizedDescription)" } ?? "Blocking list refreshed. Check iOS Phone settings for extension status."
                checkExtension()
            }
        }
    }
    private func loadProducts() async {
        do { products = try await Product.products(for: [productID]) }
        catch { message = "Store unavailable: \(error.localizedDescription)" }
    }
    private func checkEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == productID {
                active = true
            }
        }
        isSubscribed = active
    }
    private func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result, case .verified(let transaction) = verification {
                await transaction.finish()
                await checkEntitlements()
            }
        } catch { message = "Purchase not completed: \(error.localizedDescription)" }
    }
    private func restore() async {
        do { try await AppStore.sync(); await checkEntitlements() }
        catch { message = "Restore failed: \(error.localizedDescription)" }
    }
}
