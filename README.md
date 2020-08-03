# SwiftDB

A type-safe, SwiftUI-inspired wrapper around CoreData.

## Get Started

Define an `Entity`:

```swift
struct Foo: Entity, Identifiable {
    @Attribute var bar: String = "Untitled"
    
    var id: some Hashable {
        bar
    }
}
```

Define a `Schema`:

```swift
struct MySchema: Schema {
    var entities: Entities {
        Foo.self
    }
}
```

Create a `ContentView` for your application:

```swift
struct ContentView: View {
    @StateObject var container = PersistentContainer(MySchema())
    
    var body: some View {
        Text("Hello World")
    }
}
```

Create a list view:

```swift
struct ListView: View {
    @EnvironmentObject var container: PersistentContainer
    
    @FetchedModels<Foo>() var models
    
    var body: some View {
        NavigationView {
            List(models) { foo in
                NavigationLink(destination: EditView(foo: foo)) {
                    Text(foo.bar)
                }
                .contextMenu {
                    Button {
                        container.delete(foo)
                    } label: {
                        Text("Delete")
                    }
                }
            }
            .navigationBarItems(
                trailing: Button {
                    container.create(Foo.self)
                } label: {
                    Image(systemName: .plusCircleFill)
                        .imageScale(.large)
                }
            )
            .navigationBarTitle("A List of Foo")
        }
    }
    
    struct EditView: View {
        @EnvironmentObject var container: PersistentContainer
        
        let foo: Foo
        
        var body: some View {
            VStack {
                Form {
                    TextField("Enter a value", text: foo.$bar) {
                        container.save()
                    }
                }
            }
            .navigationBarTitle("Edit Foo")
        }
    }
}
```

Add it to our `ContentView`:

```swift
struct ContentView: View {
    @StateObject var container = PersistentContainer(MySchema())
    
    var body: some View {
        ListView()
            .persistentContainer(container)
    }
}
```

That's it.
