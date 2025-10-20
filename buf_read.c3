import std::io;

fn void main()
{
    //example_0();
    //example_1();
    //example_2();
    example_3();
    example_4();
}

fn void read_chunk(String input)
{
    usz chunk_offset = 0;
    usz current_offset = chunk_offset;
    usz crlf_size = 2;

    while (true)
    {
        DString chunk_size_str = dstring::temp();
        while (input[current_offset] != '\r')
        {
            chunk_size_str.append_char(input[current_offset]);
            current_offset += 1;
        }
        ulong chunk_size = chunk_size_str.str_view().to_uint(base: 16)!!;

        if (chunk_size == 0) break;

        current_offset += crlf_size;

        DString chunk_buf = dstring::temp();
        usz j = 0;
        while (j < chunk_size)
        {
            char current = input[current_offset + j];
            chunk_buf.append_char(current);
            if (current != '\r' || current != '\n') j += 1;
        }

        io::printfn("chunk buf after reading the first chunk size: %s", chunk_buf.str_view());

        current_offset += chunk_size + crlf_size;
        io::printfn("next chunk size after offseting again: %c", input[current_offset]);
    }
}

// Check that the chunk size offsetting works until the start of the chunk.
fn void example_0()
{
    String example_0 = "4\r\nWiki";

    // Lets test the offsetting
    usz chunk_offset = 0;
    io::printfn("%c", example_0[chunk_offset]);

    chunk_offset += 3;
    io::printfn("chunk_offset after applying clrf offset: %c", example_0[chunk_offset]);
}

// Check that reading using the chunk size and by offest reads the chunk correctly.
fn void example_1()
{
    String example ="4\r\nWiki\r\n5\r\n";

    usz current_offset = 0;
    DString chunk_size_str = dstring::temp();
    char current_char = example[current_offset];
    while (current_char != '\r')
    {
        chunk_size_str.append_char(current_char);
        current_offset += 1;
        current_char = example[current_offset];
    }
    ulong chunk_size = chunk_size_str.str_view().to_uint(base: 16)!!;

    usz chunk_offset = 0;
    chunk_offset += 3;

    DString chunk_buf = dstring::temp();

    usz j = 0;
    while (j < chunk_size)
    {
        char current = example[chunk_offset + j];
        chunk_buf.append_char(current);
        if (current != '\r' || current != '\n')
        {
            j += 1;
        }
    }

    io::printfn("chunk buf after reading the first chunk size: %s", chunk_buf.str_view());
}

// Check the correct offset after reading the first chunk, to get to the next
// chunk size.
fn void example_2()
{
    String example ="4\r\nWiki\r\n5\r\n0\r\n";

    usz chunk_offset = 0;
    usz current_offset = chunk_offset;

    DString chunk_size_str = dstring::temp();
    char current_char = example[current_offset];
    while (current_char != '\r')
    {
        chunk_size_str.append_char(current_char);
        current_offset += 1;
        current_char = example[current_offset];
    }
    ulong chunk_size = chunk_size_str.str_view().to_uint(base: 16)!!;

    current_offset += 2;

    DString chunk_buf = dstring::temp();

    usz j = 0;
    while (j < chunk_size)
    {
        char current = example[current_offset + j];
        chunk_buf.append_char(current);
        if (current != '\r' || current != '\n')
        {
            j += 1;
        }
    }

    io::printfn("chunk buf after reading the first chunk size: %s", chunk_buf.str_view());

    current_offset += chunk_size + 2;
    io::printfn("next chunk size after offseting again: %c", example[current_offset]);
}

// Check the we loop until 0 is reached.
fn void example_3()
{
    String example ="4\r\nWiki\r\n5\r\npedia\r\n0\r\n";
    read_chunk(example);
}

// Check that we can parse it correctly when using a larger index e.g. 1a (26)
fn void example_4()
{
    String example = "18\r\n{\"key\": \"value\", \"i\": 1}\r\n0\r\n";
    read_chunk(example);
}
