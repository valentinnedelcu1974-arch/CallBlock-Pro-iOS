import CallKit

final class CallDirectoryHandler: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        // CallKit requires full telephone numbers in ascending order.
        if !context.isIncremental {
            for number in BlockStore.numbers() {
                context.addBlockingEntry(withNextSequentialPhoneNumber: number)
            }
        }
        context.completeRequest()
    }
}
