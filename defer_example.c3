import std::io;

// Optional result is returned, the defer try runs.
fn void? optional_result()
{
    defer try io::printfn("defer runs");
    return;
}

// Optional excuse is returned, defer try DOESN'T run because an excuse was returned.
fn void? optional_excuse()
{

    defer try io::printfn("defer doesn't run");
    return io::FILE_IS_PIPE?;
}

// defer catch is used to usually clean or free memory when an error has occurred.
fn void? defer_catch_err()
{
    char[] data = mem::new_array(char, 32);

    defer (catch err)
    {
        io::printfn("Excuse found: %s, running cleanup for data", err);
        (void)free(data);
    }


    char[] data2 = mem::new_array(char, 32);
    defer (catch err)
    {
        io::printfn("Excuse found: %s, running cleanup for data2", err);
        (void)free(data2);
    }


    return io::FILE_NOT_FOUND?;

    // NOTE: If no error was returned, then none of the defer catch are called.
    //return;
}

fn void main()
{
    optional_result()!!;
    io::printfn("====");

    if (catch err = optional_excuse())
    {
        io::printfn("optional_excuse shouldn't have printed");
    }
    io::printfn("====");

    defer_catch_err()!!;
}
