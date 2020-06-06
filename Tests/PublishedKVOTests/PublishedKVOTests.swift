import XCTest
import Combine
@testable import PublishedKVO

final class PublishedKVOTests: XCTestCase {
    func testPublishedKVO() {
		var step = 0 // step 0 = start, step 1 = first publisher value, ...
		let exp = expectation(description: "testPublishedKVO")
		
		class Example {
			@PublishedKVO(\.completedUnitCount)
			var progress = Progress(totalUnitCount: 5)
		}
		
		let ex = Example()
		XCTAssertEqual(ex.progress.completedUnitCount, 0)
		
		let c1 = ex.$progress.sink { object in
			switch step {
			case 0:
				XCTAssertEqual(object.completedUnitCount, 0)
				step += 1
			case 1:
				XCTAssertEqual(object.completedUnitCount, 1)
				step += 1
			case 2:
				XCTAssertEqual(object.completedUnitCount, 2)
				step += 1
			case 3:
				XCTAssertEqual(object.completedUnitCount, 2)
				step += 1
			case 4:
				XCTAssertEqual(object.completedUnitCount, 2)
				exp.fulfill()
			default:
				XCTFail("unexpected case")
			}
		}
		
		ex.progress.completedUnitCount += 1
		ex.progress.completedUnitCount += 1
		
		ex.$progress.emit()
		ex.$progress.send(ex.progress)
		
        waitForExpectations(timeout: 1)
		c1.cancel()
    }

    static var allTests = [
        ("testPublishedKVO", testPublishedKVO),
    ]
}
