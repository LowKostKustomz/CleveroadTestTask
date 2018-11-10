import Foundation

class UsersApi: Api {

    private let usersRequestBuilder: UsersRequestBuilder
    private let seed: String?

    override init(
        baseUrl: URL,
        //        seed: String,
        network: NetworkAdapter
        ) {

        self.usersRequestBuilder = UsersRequestBuilder(baseUrl: baseUrl)
        self.seed = nil

        super.init(
            baseUrl: baseUrl,
            network: network
        )
    }

    enum RequestUsersResult {
        case success(UsersModel)
        case error(APIErrorModel)
        case failure
    }
    func requestUsers(
        page: Int,
        resultsCount: Int,
        callback: @escaping (RequestUsersResult) -> Void
        ) {

        let request = self.usersRequestBuilder.buildUsersRequest(
            seed: self.seed,
            page: page,
            results: resultsCount
        )

        _ = self.network.request(
            target: request,
            successCallback: { (result: UsersModel) in
                callback(.success(result))
        },
            errorCallback: { (error) in
                callback(.error(error))
        }, failureCallback: {
            callback(.failure)
        })
    }
}
