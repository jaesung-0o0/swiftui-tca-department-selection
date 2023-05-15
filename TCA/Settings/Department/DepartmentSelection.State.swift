import Foundation

extension DepartmentSelection {
    struct State: Equatable {
        var selectedDepartment: Department?
        var searchText: String
        var searchedDepartments: [Department]
    }
}
