import struct Basic.AbsolutePath
import class Foundation.NSString

func main(
    command: Command?,
    usagePrinter: UsagePrinting,
    fileListFactory: FileListProducing,
    projectFileListFactory: FileListProducing
) throws {

    guard let command = command
    else {
        usagePrinter.printUsage()
        return
    }

    let filesOfInterest: [String]

    switch command {

    case let .list(.all, xcodeprojPath):

        filesOfInterest = try Array(fileListFactory.make(path: xcodeprojPath.parentDirectory))

    case let .list(.project, xcodeprojPath):

        filesOfInterest = try Array(Set(projectFileListFactory.make(path: xcodeprojPath)))

    case let .list(.suspicious, xcodeprojPath):

        let allFiles = try fileListFactory.make(path: xcodeprojPath.parentDirectory)
        let projectFiles = try Set(projectFileListFactory.make(path: xcodeprojPath))

        //filesOfInterest = allFiles.subtracting(projectFiles)
        
        var suspiciousFiles = [String]()

        for file in allFiles {
            if !projectFiles.contains(where: file.localizedCaseInsensitiveContains) {
                suspiciousFiles.append(file)
            }
        }

        filesOfInterest = suspiciousFiles
    }

    for path in filesOfInterest.sorted() {
        print(path)
    }
}

let commandLineArgumentsParser = CommandLineArgumentsParser()
let command = commandLineArgumentsParser.parse(arguments: CommandLine.arguments.dropFirst())
try main(
        command: command,
        usagePrinter: commandLineArgumentsParser,
        fileListFactory: GitFileListFactory(),
        projectFileListFactory: ProjectFileListFactory()
    )
