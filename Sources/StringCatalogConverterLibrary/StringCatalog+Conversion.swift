import Foundation
import StringCatalog

extension String {
//    Use the regex %([0-9])\$(\.?[0-9]?[a-zA-Z])
//    to get replacements like:
//
//    %1$s -> $1%s
//    %1$.1f -> $1%.1f
    var transformPositionals: String {
        let regexPattern = "%([0-9])\\$([.?[0-9]?[a-zA-Z]])"
        // The replacement template:
        // $1 refers to the content of the first capturing group ([0-9])
        // $2 refers to the content of the second capturing group ([.?[0-9]?[a-zA-Z]])
        let replacementTemplate = "$$1%$2"

        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
            let range = NSRange(self.startIndex..<self.endIndex, in: self)

            let modifiedString = regex.stringByReplacingMatches(
                in: self,
                                                                options: [],
                                                                range: range,
                                                                withTemplate: replacementTemplate
            )
            return modifiedString
        } catch {
            print("Error creating regex: \(error)")
            return self // Return original string in case of regex error
        }
    }
}

extension StringCatalog {
  static func cleanupKeyForAndroid(_ key: String) -> String {
    key
      .replacingOccurrences(of: ".", with: "_")
      .replacingOccurrences(of: "-", with: "_")
  }
    
  static func cleanupValueForAndroid(_ value: String) -> String {
    
    // Mapping taken from https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
      // another good source is https://www.applanga.com/docs/advanced-features/placeholder-conversion
      
      value
      // Escaping
      .replacingOccurrences(of: "\n", with: "\\n")
      .replacingOccurrences(of: "\t", with: "\\t")
      .replacingOccurrences(of: "'", with: "\\'")
      .replacingOccurrences(of: "%%", with: "\\%") // https://stackoverflow.com/a/74864023
      // Conversion
      // All Instances of %@ will be convert to %s
      .replacingOccurrences(of: "%@", with: "%s")
      .replacingOccurrences(of: "$@", with: "$s")
      // Objective C integer types like %i, %u and %U are converted to %d
      .replacingOccurrences(of: "%i", with: "%d")
      .replacingOccurrences(of: "%u", with: "%d")
      .replacingOccurrences(of: "%U", with: "%d")
      // Floating point numbers %F will be converted to %f
      .replacingOccurrences(of: "%F", with: "%f")
      // %p iOS Pointer will be converted to Android integer %d
      .replacingOccurrences(of: "%p", with: "%d")
      // %O Octal integer is converted to %o
      .replacingOccurrences(of: "%O", with: "%o")
      // %D is converted to %d
      .replacingOccurrences(of: "%D", with: "%d")
      .transformPositionals
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
