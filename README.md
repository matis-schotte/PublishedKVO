# PublishedKVO

![build](https://img.shields.io/badge/build-passing-success)
![tests](https://img.shields.io/badge/tests-passing-success)
![language](https://img.shields.io/badge/language-swift-important)
[![license](https://img.shields.io/github/license/matis-schotte/PublishedKVO.svg)](./LICENSE)

![platform](https://img.shields.io/badge/platform-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-lightgrey.svg)
[![Twitter](https://img.shields.io/badge/twitter-@matis_schotte-blue.svg)](http://twitter.com/matis_schotte)

![Ethereum](https://img.shields.io/badge/ethereum-0x25C93954ad65f1Bb5A1fd70Ec33f3b9fe72e5e58-yellowgreen.svg)
![Litecoin](https://img.shields.io/badge/litecoin-MPech47X9GjaatuV4sQsEzoMwGMxKzdXaH-lightgrey.svg)

PublishedKVO provides Apples Combine `@Published` for class-types using Key-Value-Observing (KVO requires classes to be NSObject-based).
`@PublishedKVO`  automatically publishes objects based on one or mutliple key paths.
Attention: When using with SwiftUI unexpected results may occur since this publisher usually emits values _after_
they are set inside the object (and _before_ if the variable is overwritten/re-assigned), not always before as with the
structs willSet-based `@Published` - this is mostly related to SwiftUIs diffing and/or animation features, probably.

## Requirements
- Swift >= 5
- iOS >= 13
- macOS >= 10.15
- tvOS >= 13
- watchOS >= 6

## Installation
### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Add the Package URL `https://github.com/matis-schotte/PublishedKVO.git` in Xcodes project viewer.
Adding it to another Package as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
	.package(url: "https://github.com/matis-schotte/PublishedKVO.git", from: "0.1.0")
]
```

## Usage

```swift
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

```swift
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

[//]: # (Example: See the example project inside the `examples/` folder.)

## ToDo
- Add SwiftLint (by adding xcodeproj: `swift package generate-xcodeproj`, helps support Xcode Server, too)
- Add Travis CI (without xcodeproj see [reddit](https://www.reddit.com/r/iOSProgramming/comments/d7oyvh/configure_travis_ci_on_github_to_build_ios_swift/), [medium](https://medium.com/@aclaytonscott/creating-and-distributing-swift-packages-132444f5dd1))
- Add codecov
- Add codebeat
- Add codeclimate
- Add codetriage
- Add jazzy docs
- Add CHANGELOG.md
- Add Carthage support
- Add Cocoapods support

[//]: # (Donations: ETH, LTC welcome.)

## License
PublishedKVO is available under the Apache-2.0 license. See the [LICENSE](https://github.com/matis-schotte/PublishedKVO/blob/master/LICENSE) file for more info.

## Author
Matis Schotte, [dm26f1cab8aa26@ungeord.net](mailto:dm26f1cab8aa26@ungeord.net)

[https://github.com/matis-schotte/PublishedKVO](https://github.com/matis-schotte/PublishedKVO)
