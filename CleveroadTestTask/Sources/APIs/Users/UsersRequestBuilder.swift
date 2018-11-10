import Foundation
import Moya

class UsersRequestBuilder: RequestBuilder {
    func buildUsersRequest(
        seed: String?,
        page: Int,
        results: Int
        ) -> TargetTypeModel {

        var parameters: [String: Any] = [
            "page": page,
            "results": results,
            "inc": "name, email, phone, id, picture"
        ]
        if let seed = seed {
            parameters["seed"] = seed
        }

        let request = TargetTypeModel(
            baseURL: self.baseUrl,
            path: "api/1.2",
            method: .get,
            sampleData: Data(),
            task: .requestParameters(parameters: parameters, encoding: URLEncoding()),
            headers: nil
        )
        return request
    }
}
