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
      .replacingOccurrences(of: "%@", with: "%1$s")
      .replacingOccurrences(of: "%d", with: "%2$d")
    //.replacingOccurrences(of: "%%", with: "&#x0025;")
    //.replacingOccurrences(of: "«", with: "&#x00AB;")
    //.replacingOccurrences(of: "»", with: "&#x00BB;")
    //.replacingOccurrences(of: "á", with: "&#x00E1;")
    //.replacingOccurrences(of: "é", with: "&#x00E9;")
  }
  
  public func converted(
    to language: StringLanguage
  ) -> XMLDocument {
    let resources = XMLElement(name: "resources")
    
    for string in strings.sorted(by: { lhs, rhs in
      lhs.key < rhs.key
    }) {
      guard let value = string.value.localizations![language]?.stringUnit?.value else {
        continue
      }
      
      let element = XMLElement(name: "string")
      let cleaned = Self.cleanupValueForAndroid(value)
      let textNode = XMLNode(kind: .text)
      textNode.stringValue = cleaned
      element.addChild(textNode)
      
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
