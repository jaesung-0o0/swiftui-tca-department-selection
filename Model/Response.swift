import Foundation

struct Response<DataType: Codable>: Decodable {
    let code: Int
    let message: String
    let data: DataType
} 

