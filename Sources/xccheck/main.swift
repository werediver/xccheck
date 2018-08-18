import struct Foundation.Data
import func Foundation.exit
import Basic
import Utility
import xcodeproj

func listFiles(path: String) throws -> Set<String> {
    let result = try Process.popen(args: "git", "ls-files", "-z", path)
    let data = try result.output.dematerialize()
    let text = String(data: Data(bytes: data.map(UInt8.init)), encoding: .utf8)

    let lines = text?.split(separator: "\u{0}").map(String.init) ?? []

    return Set(lines)
}

func listProjectFiles(projectFilePath: String) throws -> Set<String> {
    let proj = try XcodeProj(path: AbsolutePath(projectFilePath, relativeTo: currentWorkingDirectory))

    let paths = proj.pbxproj.objects.fileReferences.values.compactMap { $0.path }

    return Set(paths)
}

let argumentParser = ArgumentParser(usage: "<command> <arguments>", overview: "Xcode project utility")
let listArgumentParser = argumentParser.add(subparser: "list", overview: "List files belonging to a project")
let xcodeproj = listArgumentParser.add(positional: "xcodeproj", kind: String.self, optional: false, usage: "Xcode project file")
let root = listArgumentParser.add(positional: "root", kind: String.self, optional: false, usage: "Project root")

let arguments = Array(CommandLine.arguments.dropFirst())
let parsedArguments = try? argumentParser.parse(arguments)
let subparser = parsedArguments?.subparser(argumentParser)

if  subparser == "list",
    let xcodeprojPath = parsedArguments?.get(xcodeproj),
    let rootPath = parsedArguments?.get(root)
{
    let allFiles = try listFiles(path: rootPath)
    let projectFiles = try listProjectFiles(projectFilePath: xcodeprojPath)

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
