import Foundation

struct Department: Codable, Identifiable, Equatable {
    var id: String { hostPrefix }
    let name: String
    let hostPrefix: String
    let korName: String
}
