import Foundation

class Api {

    let baseUrl: URL
    let network: NetworkAdapter

    init(
        baseUrl: URL,
        network: NetworkAdapter
        ) {

        self.baseUrl = baseUrl
        self.network = network
    }
}
