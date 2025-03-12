import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct WrapPropertyMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let propertyName = binding.pattern.as(
                IdentifierPatternSyntax.self)?.identifier
        else {
            return []
        }

        guard
            let wrapperType = node.attributeName.as(IdentifierTypeSyntax.self)?
                .genericArgumentClause?
                .arguments.first?.argument.as(IdentifierTypeSyntax.self)?.name
        else { return [] }

        return [
            """
            private var _\(propertyName): \(wrapperType)
            """
        ]
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let propertyName = binding.pattern.as(
                IdentifierPatternSyntax.self)?.identifier
        else {
            return []
        }

        return [
            """
            @storageRestrictions(initializes: _\(propertyName))
            init(initialValue) {
                self._\(propertyName) = .init(wrappedValue: initialValue)
            }
            """,
            """
            get { self._\(propertyName).wrappedValue }
            """,

            """
            set { self._\(propertyName).wrappedValue = newValue }
            """,
        ]
    }
}

@main
struct PropertyWrapperPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        WrapPropertyMacro.self,
    ]
}


