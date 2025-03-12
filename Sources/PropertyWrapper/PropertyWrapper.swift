// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(accessor, names: named(init), named(get), named(set))
@attached(peer, names: prefixed(`$`))
public macro WrapProperty<T>() =
    #externalMacro(module: "PropertyWrapperMacros", type: "WrapPropertyMacro")
