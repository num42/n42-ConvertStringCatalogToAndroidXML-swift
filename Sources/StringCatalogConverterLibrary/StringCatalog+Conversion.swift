import Foundation
import StringCatalog

extension StringCatalog {
  public func converted(to language: StringLanguage) -> XMLDocument {
    let resources = XMLElement(name: "resources")

    for string in strings.sorted(by: { lhs, rhs in
      lhs.key < rhs.key
    }) {
      let element = XMLElement(
        name: "string", stringValue: string.value.localizations![language]?.stringUnit?.value ?? "")

      // TODO: implement plurals

      element.addAttribute(
        XMLNode.attribute(
          withName: "name",
          stringValue: string.key.replacingOccurrences(of: ".", with: "_")
        ) as! XMLNode
      )

      resources.addChild(element)
    }

    return XMLDocument(rootElement: resources)
  }
}
