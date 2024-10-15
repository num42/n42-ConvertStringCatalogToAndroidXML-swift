import Foundation

extension XMLDocument {
  public var prettyPrinted: String {
    xmlString(options: .nodePrettyPrint) + "\n"
  }
}
