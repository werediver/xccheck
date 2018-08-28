import var Basic.stderrStream
import class Utility.ArgumentParser
import class Utility.PositionalArgument
import struct Utility.PathArgument

final class CommandLineArgumentsParser: UsagePrinting {

    let main: ArgumentParser
    let listAll: ListParser
    let listProject: ListParser
    let listSuspicious: ListParser

    init() {

        self.main = ArgumentParser(usage: "<command> <arguments>", overview: "Xcode project utility")
        self.listAll = ListParser.add(kind: .all, to: main)
        self.listProject = ListParser.add(kind: .project, to: main)
        self.listSuspicious = ListParser.add(kind: .suspicious, to: main)
    }

    func parse<S: Sequence>(arguments: S) -> Command?
        where S.Element == String
    {

        let args = try? main.parse(Array(arguments))
        let subparser = args?.subparser(main)

        if  subparser == listAll.name,
            let xcodeprojPath = args?
                .get(listAll.xcodeproj)?
                .path
        {
            return .list(.all, xcodeprojPath)
        }

        if  subparser == listProject.name,
            let xcodeprojPath = args?
                .get(listProject.xcodeproj)?
                .path
        {
            return .list(.project, xcodeprojPath)
        }

        if  subparser == listSuspicious.name,
            let xcodeprojPath = args?
                .get(listSuspicious.xcodeproj)?
                .path
        {
            return .list(.suspicious, xcodeprojPath)
        }

        return nil
    }

    func printUsage() {
        main.printUsage(on: stderrStream)
    }

    final class ListParser {

        let kind: Command.ListKind
        var name: String { return ListParser.description(of: kind).name }
        let xcodeproj: PositionalArgument<PathArgument>

        private init(kind: Command.ListKind, xcodeproj: PositionalArgument<PathArgument>) {

            self.kind = kind
            self.xcodeproj = xcodeproj
        }

        static func add(kind: Command.ListKind, to parent: ArgumentParser) -> ListParser {

            let (name, overview) = description(of: kind)
            let parser = parent.add(subparser: name, overview: overview)
            let xcodeproj = parser.add(positional: "xcodeproj", kind: PathArgument.self, optional: false, usage: "Xcode project file")

            return ListParser(kind: kind, xcodeproj: xcodeproj)
        }

        private static func description(of kind: Command.ListKind) -> (name: String, overview: String) {

            switch kind {
            case .all:
                return ("list-all", "List files")
            case .project:
                return ("list-contents", "List project contents")
            case .suspicious:
                return ("list-suspicious", "List suspicious files")
            }
        }
    }
}
