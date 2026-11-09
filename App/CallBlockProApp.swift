import SwiftUI
import CallKit
import StoreKit

@main
struct CallBlockProApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var input = ""
    @State private var numbers = BlockStore.numbers()
    @State private var message = "Enable CallBlock Pro in iPhone Phone settings, then refresh your blocking list."
    @State private var products: [Product] = []
    @State private var isSubscribed = false
    @State private var trialEligible = false
    @State private var extensionEnabled = false
    @State private var refreshing = false
    @State private var refreshPending = false
    @State private var storeBusy = false
    @State private var storeMessage = ""
    @State private var help: HelpTopic?
    @FocusState private var inputFocused: Bool
    private let productID = "callblockpro.annual"
    private let extensionID = "com.callblockpro.app.directory"

    enum HelpTopic: String, Identifiable {
        case prefixes = "Country prefixes", whatsapp = "WhatsApp calls"
        var id: String { rawValue }
        var detail: String {
            switch self {
            case .prefixes: return "Add a complete international number, including the country code. For example, +441234567890 or 00441234567890. Spaces, brackets and hyphens are accepted. A country prefix alone cannot block every number in that country: iOS Call Directory does not support prefix wildcards."
            case .whatsapp: return "This extension blocks telephone calls through iOS. To silence unknown WhatsApp callers, open WhatsApp → Settings → Privacy → Calls → Silence Unknown Callers. To block a specific caller, open that contact in WhatsApp and choose Block."
            }
        }
    }
    var body: some View {
        NavigationStack {
            Form {
                Section("Protection") {
                    Button { openSettings() } label: {
                        Label(extensionEnabled ? "Protection enabled · Open settings" : "Enable protection in iPhone settings", systemImage: extensionEnabled ? "checkmark.shield" : "exclamationmark.shield")
                    }
                    Text(message).font(.footnote).accessibilityIdentifier("protectionMessage")
                    Button(refreshing ? "Refreshing…" : "Refresh phone blocking") { refresh() }
                        .disabled(refreshing)
                }
                Section("Block a complete international number") {
                    TextField("Example: +441234567890", text: $input)
                        .keyboardType(.phonePad).focused($inputFocused)
                        .accessibilityIdentifier("numberInput")
                    Button("Add number") { addNumber() }.accessibilityIdentifier("addNumber")
                    if numbers.isEmpty { Text("No numbers added yet.").foregroundStyle(.secondary) }
                    ForEach(numbers, id: \.self) { number in
                        HStack {
                            Text("+\(String(number))").textSelection(.enabled)
                            Spacer()
                            Button(role: .destructive) {
                                inputFocused = false
                                BlockStore.remove(number)
                                numbers = BlockStore.numbers()
                                message = "Number removed from your saved list."
                                refresh()
                            } label: { Image(systemName: "trash") }
                            .buttonStyle(.borderless)
                            .accessibilityLabel("Remove +\(String(number))")
                        }
                    }
                }
                Section("Help") {
                    Button("Country prefixes") { inputFocused = false; help = .prefixes }
                    Button("WhatsApp calls") { inputFocused = false; help = .whatsapp }
                }
                Section("Subscription") {
                    Text("Prepare your number list for free. Activating telephone call blocking requires an active subscription, including an eligible free trial.").font(.footnote)
                    if isSubscribed { Label("Subscription active", systemImage: "checkmark.seal.fill") }
                    else if let product = products.first {
                        Text(trialEligible ? "3 days free, then \(product.displayPrice) per year. Renews automatically unless cancelled in your Apple Account before the trial ends." : "\(product.displayPrice) per year. Renews automatically unless cancelled in your Apple Account before renewal.").font(.footnote)
                        Button(trialEligible ? "Start 3-day free trial" : "Subscribe: \(product.displayPrice)/year") { Task { await purchase(product) } }.disabled(storeBusy)
                    } else {
                        Button(storeBusy ? "Checking availability…" : "Check subscription availability") { Task { await loadProducts() } }.disabled(storeBusy)
                    }
                    Button("Restore purchases") { Task { await restore() } }.disabled(storeBusy)
                    if !storeMessage.isEmpty { Text(storeMessage).font(.footnote).accessibilityIdentifier("storeMessage") }
                    Link("Manage Apple subscriptions", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                    Link("Privacy Policy", destination: URL(string: "https://github.com/valentinnedelcu1974-arch/CallBlock-Pro-iOS/blob/main/docs/PRIVACY.md")!)
                    Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Link("Support", destination: URL(string: "https://github.com/valentinnedelcu1974-arch/CallBlock-Pro-iOS/blob/main/docs/SUPPORT.md")!)
                }
            }
            .navigationTitle("CallBlock Pro")
            .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { inputFocused = false } } }
            .sheet(item: $help) { topic in
                NavigationStack {
                    ScrollView { Text(topic.detail).padding().frame(maxWidth: .infinity, alignment: .leading) }
                        .navigationTitle(topic.rawValue)
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { help = nil } } }
                }.presentationDetents([.medium, .large])
            }
            .task { checkExtension(); await checkEntitlements(); await loadProducts() }
            .task {
                for await result in Transaction.updates {
                    guard case .verified(let transaction) = result, transaction.productID == productID else { continue }
                    await checkEntitlements()
                    await transaction.finish()
                    refresh()
                }
            }
            .onChange(of: scenePhase) { _, phase in if phase == .active { numbers = BlockStore.numbers(); checkExtension(); Task { await checkEntitlements() } } }
        }
    }
    private func addNumber() {
        inputFocused = false
        guard let number = BlockStore.normalized(input) else {
            message = "Enter a complete international number with 7–15 digits and a country code. Letters and wildcard prefixes are not accepted."
            return
        }
        guard !numbers.contains(number) else { message = "This number is already in your list."; return }
        guard BlockStore.add(input) else { message = "Could not save the number. Please try again."; return }
        input = ""; numbers = BlockStore.numbers(); message = "Number saved."; refresh()
    }
    private func openSettings() {
        inputFocused = false
        CXCallDirectoryManager.sharedInstance.openSettings { error in
            DispatchQueue.main.async {
                message = error.map { "Could not open Phone settings: \($0.localizedDescription). Open Settings → Apps → Phone → Call Blocking & Identification." } ?? "Enable CallBlock Pro in Phone settings, then return here and refresh."
            }
        }
    }
    private func checkExtension() {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: extensionID) { status, error in
            DispatchQueue.main.async {
                extensionEnabled = status == .enabled
                if let error { message = "Could not check extension: \(error.localizedDescription)" }
            }
        }
    }
    private func refresh() {
        guard !refreshing else { refreshPending = true; return }
        inputFocused = false; refreshing = true
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: extensionID) { error in
            DispatchQueue.main.async {
                refreshing = false
                message = error.map { "Your list is saved. iOS could not refresh blocking: \($0.localizedDescription). Enable the extension in Phone settings and try again." } ?? (isSubscribed ? "Blocking list refreshed: \(numbers.count) saved number(s)." : "List saved. Start a trial or subscribe to activate telephone blocking.")
                checkExtension()
                if refreshPending { refreshPending = false; refresh() }
            }
        }
    }
    @MainActor private func loadProducts() async {
        guard !storeBusy else { return }; storeBusy = true
        defer { storeBusy = false }
        do {
            products = try await Product.products(for: [productID])
            if let info = products.first?.subscription,
               let offer = info.introductoryOffer,
               offer.paymentMode == .freeTrial,
               offer.period.unit == .day, offer.period.value == 3 {
                trialEligible = await info.isEligibleForIntroOffer
            } else { trialEligible = false }
            storeMessage = products.isEmpty ? "Apple has not returned the annual subscription. Please check your connection and retry. Saved number lists and help remain available." : "Apple confirms your eligibility and final terms before purchase."
        } catch { storeMessage = "Store unavailable: \(error.localizedDescription). Tap to retry." }
    }
    @MainActor private func checkEntitlements() async {
        var expiry: Date?
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == productID,
               transaction.revocationDate == nil, let end = transaction.expirationDate, end > Date() {
                expiry = max(expiry ?? .distantPast, end)
            }
        }
        let accessChanged = isSubscribed != (expiry != nil)
        let expiryChanged = BlockStore.setSubscriptionExpiry(expiry)
        isSubscribed = expiry != nil
        if accessChanged || expiryChanged { refresh() }
    }
    @MainActor private func purchase(_ product: Product) async {
        guard !storeBusy else { return }; storeBusy = true
        defer { storeBusy = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                guard case .verified(let transaction) = verification else { storeMessage = "Apple could not verify this purchase."; return }
                await transaction.finish(); await checkEntitlements(); storeMessage = "Purchase verified by Apple."
            case .pending: storeMessage = "Purchase awaiting approval."
            case .userCancelled: storeMessage = "Purchase cancelled."
            @unknown default: storeMessage = "Purchase not completed. Please try again."
            }
        } catch { storeMessage = "Purchase not completed: \(error.localizedDescription)" }
    }
    @MainActor private func restore() async {
        guard !storeBusy else { return }; storeBusy = true
        defer { storeBusy = false }
        do { try await AppStore.sync(); await checkEntitlements(); storeMessage = isSubscribed ? "Subscription restored." : "No active subscription was found for this Apple Account." }
        catch { storeMessage = "Restore failed: \(error.localizedDescription)" }
    }
}
