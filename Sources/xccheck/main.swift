import struct Basic.AbsolutePath
import var Basic.currentWorkingDirectory
import var Basic.stdoutStream
import class Utility.ArgumentParser
import class Foundation.NSString

let argumentParser = ArgumentParser(usage: "<command> <arguments>", overview: "Xcode project utility")
let listArgumentParser = argumentParser.add(subparser: "list", overview: "List files belonging to a project")
let xcodeproj = listArgumentParser.add(positional: "xcodeproj", kind: String.self, optional: false, usage: "Xcode project file")

let arguments = Array(CommandLine.arguments.dropFirst())
let parsedArguments = try? argumentParser.parse(arguments)
let subparser = parsedArguments?.subparser(argumentParser)

if  subparser == "list",
    let xcodeprojPath = parsedArguments?
        .get(xcodeproj)
        .map({ AbsolutePath($0, relativeTo: currentWorkingDirectory) })
{
    let allFiles = try GitFileListFactory().make(path: xcodeprojPath.parentDirectory)
    let projectFiles = try Set(ProjectFileListFactory().make(path: xcodeprojPath))

    //let suspiciousFiles = allFiles.subtracting(projectFiles)
    var suspiciousFiles = [String]()
    for file in allFiles {
        if !projectFiles.contains(where: file.localizedCaseInsensitiveContains) {
            suspiciousFiles.append(file)
        }
    }

    for path in suspiciousFiles.sorted() {
        print(path)
    }
} else {
    argumentParser.printUsage(on: stdoutStream)
}
