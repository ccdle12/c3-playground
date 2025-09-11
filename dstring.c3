import std::io;
import std::core::dstring;
import std::core::mem;

fn void main() {
    DString out;

    @pool() {
        DString temp = foo();
        out = temp;
        io::printfn("out assigned: %s", out.str_view());
    };

    // NOTE: DString is freed in @pool, the statement below causes a crash.
    //io::printfn("out after pool: %s", out.str_view());

    // TODO: Create a DString with a certain allocator?
    String* z = mem::new(String);
    io::printfn("DEBUG: before free: %s", *z);
    defer mem::free(z);
    io::printfn("DEBUG: after free: %s", *z);

    io::printfn("%s", append_char());
}

fn DString foo() {
    DString temp;
    temp = dstring::temp();

    temp.appendf("foo");

    return temp;
}

fn DString append_char()
{
    DString tmp = dstring::temp();

    tmp.append_char('c');
    return tmp;
}
