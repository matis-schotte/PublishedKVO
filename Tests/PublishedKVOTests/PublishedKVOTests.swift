import XCTest
@testable import PublishedKVO

final class PublishedKVOTests: XCTestCase {
    func testExample() {
		class MyFoo: ObservableObject {
			@Published var b1 = false
			@Published var b2 = false
			@Published var b3 = false
			
			@PublishedKVO(\.completedUnitCount) var progress1 = Progress(totalUnitCount: 5)
			@Published var progress2 = Progress(totalUnitCount: 5)
			@Published var progress3 = "0.0"
		}
		
		let foo = MyFoo()
		
		let cancellable1 = foo.$progress1.sink { print("$progress1 incomming \($0.fractionCompleted) actual \(foo.progress1.fractionCompleted)") }
		let cancellable2 = foo.$progress2.sink { print("$progress2 incomming \($0.fractionCompleted) actual \(foo.progress2.fractionCompleted)") }
		let cancellable3 = foo.$progress3.sink { print("$progress3 incomming \($0) actual \(foo.progress3)") }
		
		foo.progress1.completedUnitCount += 1
		foo.progress2.completedUnitCount += 1
		foo.progress3 = "0.2"
		
		foo.progress1.completedUnitCount += 1
		foo.progress2.completedUnitCount += 1
		foo.progress3 = "0.4"
		
		/* Output:
		$progress1 incomming 0.0 actual 0.0
		$progress2 incomming 0.0 actual 0.0
		$progress3 incomming 0.0 actual 0.0
		
		$progress1 incomming 0.2 actual 0.2
		$progress3 incomming 0.2 actual 0.0
		
		$progress1 incomming 0.4 actual 0.4
		$progress3 incomming 0.4 actual 0.2
		*/
		
		foo.$progress1.emit()
		foo.$progress1.send(foo.progress1)
		
        XCTAssertEqual(PublishedKVO().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
