import ArgumentParser
import Foundation
import StringCatalog
import StringCatalogConverterLibrary

@main
struct ConvertStringCatalogToAndroidXML: ParsableCommand {
  @Option(help: "Specify the path to the xcstrings file")
  public var xcstringsPath: String

  @Option(help: "Output language")
  public var outputLanguage: String

  @Option(help: "Output path for the generated Android XML file")
  public var outputPath: String

  public func run() throws {
    guard let catalog = StringCatalog(contentsOfFile: xcstringsPath) else {
      print("Could not parse file at \(xcstringsPath)")
      throw ExitCode.failure
    }

    let outputLanguage = StringLanguage(rawValue: outputLanguage)

    let xmlDocument = catalog.converted(to: outputLanguage)

    let url = URL(fileURLWithPath: outputPath + "/values-\(outputLanguage.rawValue)/")

    try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

    try! xmlDocument.prettyPrinted
      .write(
        toFile: url.path() + "/strings.xml",
        atomically: true,
        encoding: .utf8
      )
  }
}
