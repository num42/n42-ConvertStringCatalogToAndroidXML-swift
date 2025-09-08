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
      .replacingOccurrences(
        of: "\\\\%([1-9])\\$.([1-9])f", with: "%$1\\$.$2f", options: .regularExpression)
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

    for stringDictionary
      in strings
      .filter({ (key: String, value: StringEntry) in
        !key.isArrayKey
      })
      .sorted(by: { lhs, rhs in
        lhs.key < rhs.key
      })
    {
      let element: XMLElement

      if let singularValue = stringDictionary.value.localizations![language]?.stringUnit?.value {
        element = singleStringElement(
          key: Self.cleanupKeyForAndroid(stringDictionary.key),
          content: Self.cleanupValueForAndroid(singularValue)
        )
      } else {
        element = pluralElement(
          key: Self.cleanupKeyForAndroid(stringDictionary.key),
          content: stringDictionary.value.localizations![language]?.variations?.plural
        )
      }

      resources.addChild(element)
    }

    // TODO: Generate Arrays

    return XMLDocument(rootElement: resources)
  }
}

extension String {
  var isArrayKey: Bool {
    firstMatch(of: /^.*_[0-9]+$/) != nil
  }
}

func singleStringElement(key: String, content: String) -> XMLElement {
  let element = XMLElement(
    name: "string",
    stringValue: content
  )

  element.addAttribute(
    XMLNode.attribute(
      withName: "name",
      stringValue: key
    ) as! XMLNode
  )

  return element
}

func pluralElement(key: String, content: [StringVariations.PluralKey: StringVariation]?)
  -> XMLElement
{
  let element = XMLElement(
    name: "plurals",
    stringValue: nil
  )

  element.addAttribute(
    XMLNode.attribute(
      withName: "name",
      stringValue: key
    ) as! XMLNode
  )

  content?
    .sorted { lhs, rhs in
      lhs.key.rawValue > rhs.key.rawValue
    }
    .forEach { key, value in
      let item = XMLElement(
        name: "item",
        stringValue: value.stringUnit.value
      )

      item.addAttribute(
        XMLNode.attribute(
          withName: "quantity",
          stringValue: key.rawValue
        ) as! XMLNode
      )

      element.addChild(item)
    }

  return element
}
