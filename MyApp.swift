import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
    let initialState = DepartmentSelection.State(
        selectedDepartment: nil, 
        searchText: "", 
        searchedDepartments: []
    )
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: initialState, 
                    reducer: { DepartmentSelection() }
                )
            )
        }
    }
}
