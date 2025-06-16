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
    
  @Option(help: "Specify if target project is KMP with moko")
  public var isKMPWithMoko: Bool = false
  
  public func run() throws {
    guard let catalog = StringCatalog(contentsOfFile: xcstringsPath) else {
      print("Could not parse file at \(xcstringsPath)")
      throw ExitCode.failure
    }
    
    let baseLanguage = StringLanguage(rawValue: baseLanguage)
    
    for outputLanguage in catalog.languages {
      let xmlDocument = catalog.converted(to: outputLanguage)
      
        
      let isBaseLanguage = (outputLanguage == baseLanguage)

      // In case of Moko the folders are base or the language rather than values and the language
      
      let folderName = isKMPWithMoko
            ? (isBaseLanguage ? "/base/" : "/\(outputLanguage.rawValue)/")
            : (isBaseLanguage ? "/values/" : "/values-\(outputLanguage.rawValue)/")

      let url = URL(fileURLWithPath: outputPath+folderName)
      
      try! FileManager.default.createDirectory(
        at: url,
        withIntermediateDirectories: true
      )
      
      try! xmlDocument.prettyPrinted
        .write(
          toFile: url.path() + "/strings.xml",
          atomically: true,
          encoding: .utf8
        )
    }
  }
}
