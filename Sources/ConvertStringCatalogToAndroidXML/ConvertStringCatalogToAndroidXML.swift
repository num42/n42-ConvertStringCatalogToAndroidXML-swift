import ArgumentParser
import Foundation
import StringCatalog
import StringCatalogConverterLibrary

@main
struct ConvertStringCatalogToAndroidXML: ParsableCommand {
  @Option(help: "Specify the path to the xcstrings file")
  public var xcstringsPath: String

  @Option(help: "Base language")
  public var baseLanguage: String

  @Option(help: "Output path for the generated Android XML file")
  public var outputPath: String

    public func run() throws {
        guard let catalog = StringCatalog(contentsOfFile: xcstringsPath) else {
            print("Could not parse file at \(xcstringsPath)")
            throw ExitCode.failure
        }
        
        let baseLanguage = StringLanguage(rawValue: baseLanguage)
        
        for outputLanguage in catalog.languages {
            let xmlDocument = catalog.converted(to: outputLanguage)
            
            var finalXmlString = xmlDocument.prettyPrinted
            
            finalXmlString = finalXmlString.replacingOccurrences(of: "&amp;#", with: "&#")
            
            let url = (outputLanguage == baseLanguage)
            ? URL(fileURLWithPath: outputPath + "/values/")
            : URL(fileURLWithPath: outputPath + "/values-\(outputLanguage.rawValue)/")
            
            try! FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
            
            try! finalXmlString
                .write(
                    toFile: url.path() + "/strings.xml",
                    atomically: true,
                    encoding: .utf8
                )
        }
    }
}
