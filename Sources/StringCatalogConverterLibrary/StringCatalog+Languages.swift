import Foundation
import StringCatalog

extension StringCatalog {
  public var languages: Set<StringLanguage> {
    Set(
      strings.values
        .map(\.localizations)
        .compactMap(\.?.keys)
        .flatMap { $0 }
    )
  }
}
