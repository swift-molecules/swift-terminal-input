extension Terminal.Input.Parser {

    static func parseControlCharacter(
        _ input: inout Byte.Input
    ) -> Terminal.Input.Event
    {
        let byte = consumeUnchecked(&input)

        let code = ASCII.Code(unchecked: byte)
        switch code {
        case .cr:
            return .key(Terminal.Input.Key(code: .enter))

        case .tab:
            return .key(Terminal.Input.Key(code: .tab))

        case .bs:
            return .key(Terminal.Input.Key(code: .backspace))

        case .nul:
            return .key(
                Terminal.Input.Key(
                    code: .character(Unicode.Scalar(ASCII.Code.space.underlying)),
                    modifiers: .control
                )
            )

        default:

            guard code <= .sub else {

                return .key(
                    Terminal.Input.Key(
                        code: .character(Unicode.Scalar(byte.underlying &+ 0x40)),
                        modifiers: .control
                    )
                )
            }

            return .key(
                Terminal.Input.Key(
                    code: .character(Unicode.Scalar(byte.underlying &+ 0x60)),
                    modifiers: .control
                )
            )
        }
    }
}
