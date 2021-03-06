import ComposableArchitecture
import SwiftUI

extension Reducer {
    static func recurse(
        _ reducer: @escaping (Reducer, inout State, Action, Environment) -> Effect<Action, Never>
    ) -> Reducer {
        
        var `self`: Reducer!
        self = Reducer { state, action, environment in
            reducer(self, &state, action, environment)
        }
        return self
    }
}

struct NestedState: Equatable, Identifiable {
    var children: IdentifiedArrayOf<NestedState> = []
    let id: UUID
    var description: String = ""
}

indirect enum NestedAction: Equatable {
    case append
    case node(id: NestedState.ID, action: NestedAction)
    case remove(IndexSet)
    case rename(String)
}

struct NestedEnvironment {
    var uuid: () -> UUID
}

let nestedReducer = Reducer<
    NestedState, NestedAction, NestedEnvironment
>.recurse { `self`, state, action, environment in
    switch action {
    case .append:
        state.children.append(NestedState(id: environment.uuid()))
        return .none
        
    case .node:
        return self.forEach(
            state: \.children,
            action: /NestedAction.node(id:action:),
            environment: { $0 }
        )
            .run(&state, action, environment)
        
    case let .remove(indexSet):
        state.children.remove(atOffsets: indexSet)
        return .none
        
    case let .rename(name):
        state.description = name
        return .none
    }
}

struct NestedView: View {
    let store: Store<NestedState, NestedAction>
    
    var body: some View {
        WithViewStore(self.store.scope(state: \.description)) { viewStore in
            ForEachStore(
                self.store.scope(state: \.children, action: NestedAction.node(id:action:))
            ) { childStore in
                WithViewStore(childStore) { childViewStore in
                    DisclosureGroup(
                        content: {
                            NestedView(store: childStore)
                        },
                        label: {
                            TextField(
                                "Untitled",
                                text: childViewStore.binding(get: \.description, send: NestedAction.rename)
                            )
                        }
                    )
                    //                    HStack {
//                        TextField(
//                            "Untitled",
//                            text: childViewStore.binding(get: \.description, send: NestedAction.rename)
//                        )
//
//                        Spacer()
//
//                        NavigationLink(
//                            destination: NestedView(store: childStore)
//                        ) {
//                            Text("")
//                        }
//                    }
                }
            }
            .onDelete { viewStore.send(.remove($0)) }
        }
    }
}

extension NestedState {
    static let mock = NestedState(
        children: [
            NestedState(
                children: [
                    NestedState(
                        children: [],
                        id: UUID(),
                        description: ""
                    )
                ],
                id: UUID(),
                description: "Bar"
            ),
            NestedState(
                children: [
                    NestedState(
                        children: [],
                        id: UUID(),
                        description: "Fizz"
                    ),
                    NestedState(
                        children: [],
                        id: UUID(),
                        description: "Buzz"
                    ),
                ],
                id: UUID(),
                description: "Baz"
            ),
            NestedState(
                children: [],
                id: UUID(),
                description: ""
            ),
        ],
        id: UUID(),
        description: "Foo"
    )
}

#if DEBUG
struct NestedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NestedView(
                store: Store(
                    initialState: .mock,
                    reducer: nestedReducer,
                    environment: NestedEnvironment(
                        uuid: UUID.init
                    )
                )
            )
        }
    }
}
#endif
