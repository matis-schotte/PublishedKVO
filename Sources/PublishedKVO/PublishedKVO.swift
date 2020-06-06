import Foundation
import Combine

/**
PublishedKVO provides Apples Combine `@Published` for class-types using Key-Value-Observing (KVO requires classes to be NSObject-based).
`@PublishedKVO`  automatically publishes objects based on one or mutliple key paths.

Attention: When using with SwiftUI unexpected results may occur since this publisher usually emits values _after_
they are set inside the object (and _before_ if the variable is overwritten/re-assigned), not always before as with the
structs willSet-based `@Published` - this is mostly related to SwiftUIs diffing and/or animation features, probably.

```
class Example {
	@PublishedKVO(\.completedUnitCount)
	var progress = Progress(totalUnitCount: 2)
	
	@Published
	var textualRepresentation = "text"
}

let ex = Example()

// Set up the publishers
let c1 = ex.$progress.sink { print("\($0.fractionCompleted) completed") }
let c1 = ex.$textualRepresentation.sink { print("\($0)") }

// Interact with the class as usual
ex.progress.completedUnitCount += 1
// outputs "0.5 completed"

// And compare with Combines @Published (almost°) same behaviour
ex.textualRepresentation = "string"
// outputs "string"

ex.$progress.emit() // Re-emits the current value
ex.$progress.send(ex.progress) // Emits given value
```

° See `Attention` comment from above about SwiftUI and the following example:

```
class Example {
	@PublishedKVO(\.completedUnitCount)
	var progress1 = Progress(totalUnitCount: 5)
	
	@Published
	var progress2 = Progress(totalUnitCount: 5)
	
	@Published
	var progress3 = "0.0"
}

let ex = Example()

// Class using @PublishedKVO
let c1 = ex.$progress1.sink { print("$progress1 incomming \($0.fractionCompleted) actual \(ex.progress1.fractionCompleted)") }
// Class using @Published
let c2 = ex.$progress2.sink { print("$progress2 incomming \($0.fractionCompleted) actual \(ex.progress2.fractionCompleted)") }
// Struct using @Published
let c3 = ex.$progress3.sink { print("$progress3 incomming \($0) actual \(ex.progress3)") }

ex.progress1.completedUnitCount += 1
ex.progress2.completedUnitCount += 1
ex.progress3 = "0.2"

ex.progress1.completedUnitCount += 1
ex.progress2.completedUnitCount += 1
ex.progress3 = "0.4"

/* Outputs (incomming should new value, actual should be old value):
$progress1 incomming 0.0 actual 0.0
$progress2 incomming 0.0 actual 0.0
$progress3 incomming 0.0 actual 0.0

$progress1 incomming 0.2 actual 0.2
// no output from $progress2
$progress3 incomming 0.2 actual 0.0

$progress1 incomming 0.4 actual 0.4
// no output from $progress2
$progress3 incomming 0.4 actual 0.2
*/
```
*/
@propertyWrapper
class PublishedKVO<Value: NSObject, B> {
	private let subject: CurrentValueSubject<Value, Never>
	
	/// The initializer accepting multiple keyPath's to watch for changes.
	/// - parameter keyPaths: An array of `KeyPath`s to use with Key-Value-Observing.
	init(wrappedValue value: Value, _ keyPaths: [KeyPath<Value, B>]) {
		self.subject = CurrentValueSubject<Value, Never>(value)
		setupKVO(keyPaths)
	}
	
	/// The initializer accepting a keyPath to watch for changes.
	/// - parameter keyPath: A `KeyPath` to use with Key-Value-Observing.
	convenience init(wrappedValue value: Value, _ keyPath: KeyPath<Value, B>) {
		self.init(wrappedValue: value, [keyPath])
	}
	
	var projectedValue: Publisher { Publisher(subject) }
	
	var wrappedValue: Value {
		get { subject.value }
		set { subject.value = newValue } // this works as usual @Published with structs/variable re-assign
	}
	
	private var kvoTokens = [NSKeyValueObservation]()
	private func setupKVO(_ keyPaths: [KeyPath<Value, B>]) {
		keyPaths.forEach { keyPath in
			let kvoToken = subject.value.observe(keyPath) { _, _ in
				// this works different to Combine @Published since the var inside the object is already set when emitting this value
				self.subject.send(self.subject.value)
			}
			kvoTokens.append(kvoToken)
		}
	}
	
	deinit {
		kvoTokens.forEach { $0.invalidate() }
	}
	
	struct Publisher: Combine.Publisher {
		typealias Output = Value
		typealias Failure = Never
		
		private let subject: CurrentValueSubject<Value, Never>
		
		init(_ subject: CurrentValueSubject<Value, Never>) {
			self.subject = subject
		}
		
		func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
			subject.receive(subscriber: subscriber)
		}
		
		/// Send a new `Value` to all receivers.
		/// - parameter input: The value of the correct type to send.
		func send(_ input: Value) {
			subject.send(input)
		}
		
		/// Emit the current `Value` to all receivers.
		func emit() {
			subject.send(subject.value)
		}
	}
}
