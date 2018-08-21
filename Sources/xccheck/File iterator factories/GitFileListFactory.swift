import Basic

final class GitFileListFactory: FileListProducing {

    func make(path: AbsolutePath) throws -> AnySequence<String> {

        let processResult = try Process
            .popen(args: "git", "ls-files", "-z", path.asString)

        let data = try processResult.output.dematerialize()
        var files = try stringList(data)

        let iterator = AnyIterator {
                files.isEmpty ? nil : files.removeLast()
            }

        return AnySequence(iterator)
    }

    func stringList(_ utf8data: [Int8]) throws -> [String] {

        var offset = 0
        var list = [String]()

        while offset < utf8data.count {
            let string = try self.string(utf8data.suffix(from: offset))
            list.append(string)
            offset += string.lengthOfBytes(using: .utf8) + 1
        }

        return list
    }

    func string<S: Sequence>(_ utf8data: S) throws -> String
        where S.Element == Int8
    {
        guard let string = String(validatingUTF8: Array(utf8data))
        else { throw Failure.illegalUTF8Sequence }

        return string
    }

    private enum Failure: Error {
        case illegalUTF8Sequence
    }
}
