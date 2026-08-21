extension Terminal.Input.Parser {

    public enum Error: Swift.Error, Sendable, Equatable {

        case emptyInput

        case incompleteSequence

        case unrecognizedSequence

        case invalidUTF8
    }
}
