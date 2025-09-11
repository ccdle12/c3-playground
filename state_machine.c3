import std::io;

enum State
{
    START,
    CR,
    CRLF,
    CRLF_CR,
    END,
}

fn void main()
{
    char[] x = { '\r', '\n','\n'};

    State state = START;

    foreach (&c : x)
    {
        if (*c == '\r') io::printfn("found \r");
        io::printfn("%s", *c);

        switch(state)
        {
            case START:
                if (*c == '\r') state = CR;
                break;
            case CR:
                state = (*c == '\n') ? CRLF : START;
                break;
            case CRLF:
                state = (*c == '\r') ? CRLF_CR : START;
                break;
            case CRLF_CR:
                state = (*c == '\n') ? state = END : START;
                break;
            case END:
                break;
        }

        if (state == END) break;
    }

    io::printfn("STATE: %s", state);
    assert(state == END);
    if (state == END) io::printfn("end state");
}
