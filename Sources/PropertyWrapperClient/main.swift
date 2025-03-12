import PropertyWrapper

@propertyWrapper struct Uppercased {
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
var user = User(name: "Saheed")
print(user)
