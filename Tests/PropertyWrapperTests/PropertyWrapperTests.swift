import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(PropertyWrapperMacros)
    import PropertyWrapperMacros

    let testMacros: [String: Macro.Type] = [
        "WrapProperty": WrapPropertyMacro.self
    ]
#endif

final class PropertyWrapperTests: XCTestCase {
    func testMacro() throws {
        #if canImport(PropertyWrapperMacros)
            assertMacroExpansion(
                """
                struct Uppercased {
                    private var value: String

                    init(wrappedValue: String) {
                        self.value = wrappedValue.uppercased()
                    }

                    var wrappedValue: String {
                        get { value }
                        set { value = newValue.uppercased() }
                    }
                }

                struct User {
                    @WrapProperty<Uppercased> var name: String
                }
                """,
                expandedSource:
                    """
                    struct Uppercased {
                        private var value: String

                        init(wrappedValue: String) {
                            self.value = wrappedValue.uppercased()
                        }

                        var wrappedValue: String {
                            get { value }
                            set { value = newValue.uppercased() }
                        }
                    }

                    struct User {
                        var name: String {
                            @storageRestrictions(initializes: _name)
                            init(initialValue) {
                                self._name = .init(wrappedValue: initialValue)
                            }
                            get {
                                self._name.wrappedValue
                            }
                            set {
                                self._name.wrappedValue = newValue
                            }
                        }

                        private var _name: Uppercased
                    }
                    """,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
