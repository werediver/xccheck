import struct Basic.AbsolutePath

enum Command {

    case list(ListKind, AbsolutePath)

    enum ListKind {

        case all
        case project
        case suspicious
    }
}

protocol CommandLineArgumentsParsing {

    func parse() -> Command?
}

protocol UsagePrinting {

    func printUsage()
}
