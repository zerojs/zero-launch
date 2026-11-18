import Foundation

enum UpdaterError: Error, CustomStringConvertible {
    case network(String)
    case assetNotFound(String)
    case archive(String)
    case install(String)
    case cancelled
    case unconfiguredRepository

    var description: String {
        switch self {
        case .network(let message):
            return message
        case .assetNotFound(let message):
            return message
        case .archive(let message):
            return message
        case .install(let message):
            return message
        case .cancelled:
            return "Operation cancelled"
        case .unconfiguredRepository:
            return "Update repository is not configured. Pass --repo owner/repo."
        }
    }
}
