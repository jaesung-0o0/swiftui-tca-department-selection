import Satellite
import ComposableArchitecture

struct DepartmentSelection: ReducerProtocol {
    let kuringSatellite = Satellite(host: "kuring.herokuapp.com", scheme: .https)
    
    var departments: [Department] {
        get async throws {
            let response: Response<[Department]> = try await kuringSatellite.response(for: "api/v2/notices/departments", httpMethod: .get)
            return response.data
        }
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .search(let keyword):
            state.selectedDepartment = nil
            state.searchText = keyword
            return .run { send in
                await send(.searchResult(TaskResult { try await departments }))
            }
        case .select(let department):
            state.selectedDepartment = department
            state.searchText = department.korName
            return .none
        case .searchResult(.success(let departments)):
            let searchedDepartments = departments.filter { $0.korName.contains(state.searchText) }
            state.searchedDepartments = searchedDepartments
            return .none
        case .searchResult(.failure(let error)):
            print(error.localizedDescription)
            return .none
        }
    }
}
