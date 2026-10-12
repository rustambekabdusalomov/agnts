# Swift review checklist

- Optionals: no force unwraps (`!`, `try!`, `as!`) on values that can be nil or fail at runtime; `guard let` for early exits.
- Concurrency: UI updates on the main actor; `@MainActor` annotations consistent; no data races on shared mutable state (actors or isolation); tasks cancelled when views disappear; `Sendable` warnings not silenced.
- Memory: closures capturing `self` in long-lived contexts use `[weak self]`; no retain cycles between objects and their delegates (delegates `weak`).
- Errors: `do/catch` handles errors meaningfully; no empty catch.
- SwiftUI: state owned by the right view (`@State`, `@StateObject` vs `@ObservedObject`); no heavy work in `body`; identifiers stable in `ForEach`.
- Persistence: Core Data/SwiftData contexts used on their own queue; migrations planned.
- Security: secrets in the Keychain, not UserDefaults; ATS not disabled.
- Tests: XCTest/Swift Testing with async tests awaited properly.
