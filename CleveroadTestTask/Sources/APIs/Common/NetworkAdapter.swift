import Foundation
import Moya

class NetworkAdapter {

    private let networkAdapterQueue: DispatchQueue = DispatchQueue(
        label: "networkAdapterQueue".queueLabel,
        qos: .utility,
        attributes: .concurrent
    )
    
    func request<T: TargetType, ResponseType: Decodable>(
        target: T,
        callbackQueue: DispatchQueue? = nil,
        successCallback: @escaping (ResponseType) -> Void,
        errorCallback: @escaping (APIErrorModel) -> Void,
        failureCallback: @escaping () -> Void
        ) -> Cancellable {

        let provider: MoyaProvider = self.provider(forType: T.self, debug: false)
        return provider.request(
            target,
            callbackQueue: callbackQueue,
            progress: nil,
            completion: { (result) in

                switch result {
                case .success(let response):
                    if 200..<400 ~= response.statusCode {
                        if let response = try? ResponseType.decode(from: response.data) {
                            successCallback(response)
                            return
                        }
                    }

                    if let error = try? APIErrorModel.decode(from: response.data) {
                        errorCallback(error)
                        return
                    }
                case .failure(let error):
                    if let error = try? APIErrorModel.decode(from: error.response?.data ?? Data()) {
                        errorCallback(error)
                        return
                    }

                    if let description = error.errorDescription {
                        errorCallback(APIErrorModel(error: description))
                        return
                    }
                }

                failureCallback()
        })
    }
    
    private func provider<T: TargetType>(
        forType type: T.Type,
        debug: Bool
        ) -> MoyaProvider<T> {

        if debug {
            let networkLoggerPlugin = NetworkLoggerPlugin(
                verbose: true,
                cURL: true,
                output: nil,
                requestDataFormatter: nil,
                responseDataFormatter: nil
            )
            return MoyaProvider<T>(plugins: [networkLoggerPlugin])
        } else {
            return MoyaProvider<T>()
        }
    }
}
