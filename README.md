# swiftui-tca-department-selection
SwiftUI TCA Study - Search and select departments in Konkuk Univ.

> **TECH DEBT**:
> 
> 검색할 때마다 매번 모든 학과 리스트를 가져오는데 수정하기 귀찮아서...
> 나중에 초기에 한번만 학과 리스트 가져오고 로컬 데이터에서 조회하는 방식으로 수정해야함.

## State

```swift
extension DepartmentSelection {
    struct State: Equatable {
        var selectedDepartment: Department?
        var searchText: String
        var searchedDepartments: [Department]
    }
}
```
선택한 학과, 검색어, 검색결과 를 State 에 정의

## Action

```swift
extension DepartmentSelection {
    enum Action {
        case search(String)
        case select(Department)
        case searchResult(TaskResult<[Department]>)
    }
}
```
검색, 학과 선택, 검색 결과 액션을 정의. 검색 결과의 경우 API 요청을 통한 응답을 사용하기 때문에 `TaskResult` 를 사용.

## Reducer

```swift
struct DepartmentSelection: ReducerProtocol {
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
```
### API 통신

검색의 경우 `kuringStatellite` 라는 API 클라이언트 객체를 통해서 `[Department]` 를 `data` 로 갖고 있는 `Response` 를 받아오게 되어있다.

```swift
var departments: [Department] {
    get async throws {
        let response: Response<[Department]> = try awaut fetchDepartments()
        return response.data
    }
}
```

1. `reduce(into:inout:action:)` 에서 `search(_:)` 액션이 들어오면 `.run` 이라는 effect를 반환한다.
2. `run` 은 클로져에서 `send(_:)` 를 호출하는데, 이때 파라미터로 `TaskResult` 를 사용하는 액션을 넣는다.
3. `TaskResult` 에는 기대하는 Result 값을 던져주는 API 통신 메소드를 구현해주면 된다.

## Store

```swift
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
```

### Binding 하기
`TextField` 의 `text` 에 `Binding<String>` 타입의 값을 사용하기 위해 `viewStore.binding(get:send:)` 를 사용했다.

`binding(get:send:)` 에서 
- `get` 파라미터에는 state의 변수값을 할당하고(`\.searchText`)
- `send` 에는 클로져 안에 액션을 전달한다(`{ .search($0) }`)

### 액션 전달하기
`onTapGesture` 에서 발생한 액션을 Reducer에 전달하기 위해 `viewStore.send(_:)` 에 액션을 담아 호출하면 된다.

