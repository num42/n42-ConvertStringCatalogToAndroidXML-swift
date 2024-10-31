import Foundation
import StringCatalog

public extension StringCatalog {
    var languages: Set<StringLanguage> {
        Set(
            strings.values
                .map(\.localizations)
                .compactMap(\.?.keys)
                .flatMap{ $0 }
        )
    }
}
