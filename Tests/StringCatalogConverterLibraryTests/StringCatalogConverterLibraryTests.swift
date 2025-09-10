import Foundation
import StringCatalog
import StringCatalogConverterLibrary
import Testing

@Test(
  "Conversion",
  arguments: [
    "SimpleTest"
  ],
  [
    StringLanguage.english,
    .german,
  ]
)
func conversion(testname: String, language: StringLanguage) {
  let inputURL = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .appendingPathComponent("Resources")
    .appendingPathComponent(testname)
    .appendingPathComponent("Input.xcstrings")

  let generatedXML = try! StringCatalog(
    contentsOf: inputURL
  )
  .converted(to: language)
  .prettyPrinted
  .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

  let outputURL = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .appendingPathComponent("Resources")
    .appendingPathComponent(testname)
    .appendingPathComponent("Output.\(language.rawValue).xml")

  let expectedXML = try! String(
    contentsOf: outputURL,
    encoding: .utf8
  ).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

  #expect(generatedXML == expectedXML)
}
