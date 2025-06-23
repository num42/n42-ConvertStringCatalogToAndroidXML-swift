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
    
    @Option(help: "Languages that are skipped")
    public var skippedLanguages: [String] = []
    
    @Flag(help: "Specify if target project is KMP with moko")
    public var isKMPWithMoko: Bool = false
    
    public func run() throws {
        guard let catalog = StringCatalog(contentsOfFile: xcstringsPath) else {
            print("Could not parse file at \(xcstringsPath)")
            throw ExitCode.failure
        }
        
        for outputLanguage in catalog.languages {
            let url = outputURL(for: outputLanguage)
            
            print("Removing \(url)")
            try? FileManager.default.removeItem(at: url)
            
            guard !skippedLanguages.contains(outputLanguage.rawValue) else {
                print("Not writing \(url) as it is skipped.")
                
                return
            }
            
            let xmlDocument = catalog.converted(to: outputLanguage)
            
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
    
    func outputURL(for outputLanguage: StringLanguage) -> URL {
        let isBaseLanguage = outputLanguage.rawValue == baseLanguage
        
        let folderName = if isBaseLanguage, isKMPWithMoko {
            "base/"
        } else if isBaseLanguage, !isKMPWithMoko {
             "values/"
        } else if !isBaseLanguage, isKMPWithMoko {
             "\(outputLanguage.rawValue)/"
        } else {
            "values-\(outputLanguage.rawValue)/"
        }
        
        return URL(fileURLWithPath: outputPath).appending(path: folderName)
    }
}
