import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<DepartmentSelection>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                TextField(
                    "Your department", 
                    text: viewStore.binding(
                        get: \.searchText,
                        send: { .search($0) }
                    )
                )
                .foregroundColor(
                    viewStore.selectedDepartment == nil
                    ? .primary
                    : .teal
                )
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewStore.searchedDepartments) { department in 
                            Text(department.korName)
                                .onTapGesture {
                                    viewStore.send(.select(department))
                                }
                        }
                    }
                }
            }
        }
    }
}
