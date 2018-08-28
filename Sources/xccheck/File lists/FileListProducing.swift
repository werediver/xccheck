import struct Basic.AbsolutePath

protocol FileListProducing {

    func make(path: AbsolutePath) throws -> AnySequence<String>
}
