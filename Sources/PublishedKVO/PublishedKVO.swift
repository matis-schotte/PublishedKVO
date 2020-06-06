/// @PublishedKVO for automatically published objects based on one or mutliple key paths
/// As KVO implies this is only for NSObject-based classes.
///
/// Attention: When using with SwiftUI unexpected results may occur since this publisher usually emits values _after_
/// they are set inside the object (and _before_ if the variable is overwritten/re-assigned), not always before as with the
/// structs willSet-based `@Published` - this is mostly related to SwiftUIs diffing and/or animation features, probably.
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
