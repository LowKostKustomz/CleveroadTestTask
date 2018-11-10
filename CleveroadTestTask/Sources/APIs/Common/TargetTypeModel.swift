import Foundation
import Moya

struct TargetTypeModel: TargetType {
    let baseURL: URL
    let path: String
    let method: Moya.Method
    let sampleData: Data
    let task: Task
    let headers: [String : String]?
}
