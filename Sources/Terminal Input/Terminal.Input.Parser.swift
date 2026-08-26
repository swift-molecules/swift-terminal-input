extension Terminal.Input {

    public struct Parser: Sendable {

        public init() {}
    }
}

extension Terminal.Input.Parser {

    public static func parse<Storage>(
        _ input: inout Input.Buffer<Storage>
    ) throws(Self.Error) -> Terminal.Input.Event
    where
        Storage: RandomAccessCollection & Sendable,
        Storage.Element == Byte,
        Storage.Index: Sendable & Hashable
    {
        guard let byte = input.first else {
            throw .emptyInput
        }

        let code: ASCII.Code
        do {
            code = try ASCII.Code(byte)
        } catch {

            let saved = input.checkpoint
            do {
                return try parseUTF8(&input)
            } catch let utf8Err {
                if utf8Err == .incompleteSequence {
                    input.seek(to: saved)
                }
                throw utf8Err
            }
        }

        switch code {
        case .esc:
            let saved = input.checkpoint
            do {
                return try parseEscapeSequence(&input)
            } catch {
                if error == .incompleteSequence {
                    input.seek(to: saved)
                }
                throw error
            }

        case .del:
            consumeUnchecked(&input)
            return .key(Terminal.Input.Key(code: .backspace))

        case .nul...ASCII.Code.us:
            return parseControlCharacter(&input)

        case .space...ASCII.Code.tilde:
            let b = consumeUnchecked(&input)
            return .key(Terminal.Input.Key(code: .character(Unicode.Scalar(b))))

        default:

            throw .unrecognizedSequence
        }
    }
}

extension Terminal.Input.Parser {

    static func parseEscapeSequence<Storage>(
        _ input: inout Input.Buffer<Storage>
    ) throws(Self.Error) -> Terminal.Input.Event
    where
        Storage: RandomAccessCollection & Sendable,
        Storage.Element == Byte,
        Storage.Index: Sendable & Hashable
    {

        consumeUnchecked(&input)

        guard let next = input.first else {
            throw .incompleteSequence
        }

        let code: ASCII.Code
        do {
            code = try ASCII.Code(next)
        } catch {
            throw .unrecognizedSequence
        }

        switch code {
        case .leftBracket:
            consumeUnchecked(&input)
            return try parseCSI(&input)

        case .O:
            consumeUnchecked(&input)
            return try parseSS3(&input)

        case .space...ASCII.Code.tilde:
            consumeUnchecked(&input)
            return .key(
                Terminal.Input.Key(
                    code: .character(Unicode.Scalar(next)),
                    modifiers: .alt
                )
            )

        default:
            throw .unrecognizedSequence
        }
    }
}

extension Terminal.Input.Parser {

    @inline(always)
    static func consume<Storage>(
        _ input: inout Input.Buffer<Storage>
    ) throws(Self.Error) -> Byte
    where
        Storage: RandomAccessCollection & Sendable,
        Storage.Element == Byte,
        Storage.Index: Sendable & Hashable
    {
        do {
            return try input.advance()
        } catch {
            throw .incompleteSequence
        }
    }

    @inline(always)
    @discardableResult
    static func consumeUnchecked<Storage>(
        _ input: inout Input.Buffer<Storage>
    ) -> Byte
    where
        Storage: RandomAccessCollection & Sendable,
        Storage.Element == Byte,
        Storage.Index: Sendable & Hashable
    {
        do {
            return try input.advance()
        } catch {
            preconditionFailure(
                "consumeUnchecked requires a non-empty buffer; the caller violated the !input.isEmpty precondition"
            )
        }
    }
}
