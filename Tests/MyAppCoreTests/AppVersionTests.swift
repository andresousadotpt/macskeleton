import XCTest
@testable import MyAppCore

final class AppVersionTests: XCTestCase {
    func testMarketingVersionIsNonEmpty() {
        XCTAssertFalse(AppVersion.marketing.isEmpty)
    }
}
