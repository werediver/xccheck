import Basic
import xcodeproj

final class ProjectFileListFactory: FileListProducing {

    func make(path: AbsolutePath) throws -> AnySequence<String> {

        var files = try XcodeProj(path: path)
            .pbxproj
            .objects
            .fileReferences
            .values
            .compactMap { $0.path }

        let iterator = AnyIterator {
                files.isEmpty ? nil : files.removeLast()
            }

        return AnySequence(iterator)
    }
}
