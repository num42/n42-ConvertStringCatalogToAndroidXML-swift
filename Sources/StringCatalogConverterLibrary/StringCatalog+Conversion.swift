import Foundation
import StringCatalog

extension StringCatalog {
  static func cleanupKeyForAndroid(_ key: String) -> String {
    key
      .replacingOccurrences(of: ".", with: "_")
      .replacingOccurrences(of: "-", with: "_")
  }
  
  static func cleanupValueForAndroid(_ value: String) -> String {
    value
      .replacingOccurrences(of: "\n", with: "\\n")
      .replacingOccurrences(of: "\t", with: "\\t")
      .replacingOccurrences(of: "'", with: "\\'")
      .replacing(/%/, with: "\\%")
      // We assume that all formatted values have a position!
      .replacingOccurrences(of: "\\\\%([1-9])\\$@", with: "%$1\\$s", options: .regularExpression)
      .replacingOccurrences(of: "\\\\%([1-9])\\$d", with: "%$1\\$d", options: .regularExpression)
      .replacingOccurrences(of: "\\\\%([1-9])\\$.([1-9])f", with: "%$1\\$.$2f", options: .regularExpression)
  }
  
  public func converted(
    to language: StringLanguage
  ) -> XMLDocument {
    let resources = XMLElement(name: "resources")
      
      resources.addAttribute(
        XMLNode.attribute(
            withName: "xmlns:tools",
            stringValue: "http://schemas.android.com/tools"
        ) as! XMLNode
      )
      
      resources.addAttribute(
        XMLNode.attribute(
            withName: "tools:locale",
            stringValue: language.rawValue
        ) as! XMLNode
      )

    for string in strings.sorted(by: { lhs, rhs in
      lhs.key < rhs.key
    }) {
        guard let value = string.value.localizations![language]?.stringUnit?.value else {
            continue
        }
        
      let element = XMLElement(
        name: "string", stringValue: Self.cleanupValueForAndroid(value))

      // TODO: implement plurals

      element.addAttribute(
        XMLNode.attribute(
          withName: "name",
          stringValue: Self.cleanupKeyForAndroid(string.key)
        ) as! XMLNode
      )

      resources.addChild(element)
    }

    return XMLDocument(rootElement: resources)
  }
}
