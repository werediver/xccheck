import Basic

final class GitFileListFactory: FileListProducing {

    func make(path: AbsolutePath) throws -> AnySequence<String> {

        var files = try Process
            .popen(args: "git", "ls-files", path.asString)
            .utf8Output()
            .split(separator: "\n")
            .map(String.init)

        let iterator = AnyIterator {
                files.isEmpty ? nil : files.removeLast()
            }

        return AnySequence(iterator)
    }
}
