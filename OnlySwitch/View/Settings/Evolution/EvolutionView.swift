//
//  EvolutionView.swift
//  OnlySwitch
//
//  Created by Jacklandrin on 2023/5/27.
//

import AlertToast
import ComposableArchitecture
import SwiftUI

@available(macOS 13.3, *)
struct EvolutionView: View {

    let store: StoreOf<EvolutionReducer>
    @ObservedObject var viewStore: ViewStore<ViewState, EvolutionReducer.Action>

    struct ViewState: Equatable {
        let destinationTag: EvolutionReducer.DestinationState.Tag?

        init(state: EvolutionReducer.State) {
            self.destinationTag = state.destination?.tag
        }
    }

    init(store: StoreOf<EvolutionReducer>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: ViewState.init(state:)))
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack {
                    ScrollView(.vertical) {
                        if viewStore.evolutionList.isEmpty {
                            Text("You can DIY switches or buttons here.")
                            Button("Refresh") {
                                viewStore.send(.refresh)
                            }
                        } else {
                            LazyVStack {
                                ForEachStore(
                                    store.scope(
                                        state: \.evolutionList,
                                        action: EvolutionReducer.Action.editor(id: action:)
                                    )
                                ) { itemStore in
                                    evolutionItemView(
                                        viewStore: viewStore,
                                        itemStore: itemStore
                                    )
                                }
                            }

                            Spacer()
                        }
                    }
                    .padding(.top, 10)

                    HStack {
                        NavigationLink(
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.editorState,
                                        action: EvolutionReducer.Action.editorAction)
                                ) { editorStore in
                                    EvolutionEditorView(store: editorStore)
                                },
                            tag: EvolutionReducer.DestinationState.Tag.editor,
                            selection: viewStore.binding(
                                get: { _ in self.viewStore.destinationTag },
                                send: { EvolutionReducer.Action.setNavigation(tag:$0) }
                            )
                        ) {
                            Text("+")
                        }

                        Button(action: {
                            viewStore.send(.remove)
                        }) {
                            Text("-")
                        }

                        Spacer()
                    }
                    .padding(.leading, 20)
                }
                .padding(.bottom, 10)

            }
            .toast(isPresenting: viewStore.binding(
                get: { $0.showError },
                send: { .errorControl($0) }
            ),
                   alert: {
                AlertToast(
                    displayMode: .alert,
                    type: .error(.red),
                    title: "load evolution list failed"
                )
            }
            )
            .task  {
                await viewStore.send(.refresh).finish()
            }
        }
    }

    @ViewBuilder
    func evolutionItemView(
        viewStore: ViewStore<EvolutionReducer.State, EvolutionReducer.Action>,
        itemStore: StoreOf<EvolutionRowReducer>
    ) -> some View {
        WithViewStore(itemStore) { itemViewStore in
            EvolutionRowView(store: itemStore)
            .background(
                viewStore.selectID == itemViewStore.id
                ? Color.accentColor
                : Color.gray.opacity(0.1)
            )
            .onTapGesture {
                viewStore.send(.select(itemViewStore.id))
            }
            .padding(.horizontal, 20)
        }
    }
}

@available(macOS 13.3, *)
struct EvolutionView_Previews: PreviewProvider {
    static var previews: some View {
        EvolutionView(
            store: Store(
                initialState: EvolutionReducer.State(),
                reducer: EvolutionReducer()
                            .dependency(\.evolutionListService, .previewValue)
            )
        )
    }
}
