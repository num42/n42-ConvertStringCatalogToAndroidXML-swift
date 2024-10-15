import Foundation
import StringCatalog

extension StringCatalog {
  public init?(contentsOfFile path: String) {
    try? self.init(contentsOf: URL(filePath: path))
  }
}
