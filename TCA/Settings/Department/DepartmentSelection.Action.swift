import ComposableArchitecture

extension DepartmentSelection {
    enum Action {
        case search(String)
        case select(Department)
        case searchResult(TaskResult<[Department]>)
    }
}
