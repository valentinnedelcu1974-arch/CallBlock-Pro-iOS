import CallKit
final class CallDirectoryHandler: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        if context.isIncremental { context.removeAllBlockingEntries() }
        for number in BlockStore.numbers() {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        }
        context.completeRequest()
    }
}
