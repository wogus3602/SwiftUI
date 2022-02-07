//
//  ContentView.swift
//  Shared
//
//  Created by woogus on 2022/01/29.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        List {
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
        .listStyle(SidebarListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
