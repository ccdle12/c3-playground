import std::io;

<*
 Here are some docs.

 @param num_foo: `The number of foos.`
 @require num_foo > 4

*>
fn void pre_cond(int num_foo)
{
    io::printfn("%d", num_foo);
}

<*
 Post conditions.

 @require foo != null
 @ensure return > foo.x
*>
fn uint post_cond(Foo* foo)
{
    uint y = foo.x + 1;
    return y * foo.x;
}

struct Foo
{
    uint x;
}

<*
 Parameter annotations.

 @param [&in] foo: `Foo as a readonly input and using & means cannot be null`
 @param [out] buf: `The output buffer that is write-only`
*>
fn void param_anno(Foo* foo, DString  buf)
{
    buf.appendf("%d", foo.x);
}

fn void main()
{
    // Pre Condition enforcement
    //pre_cond(3);

    // Post Condition enforcement
    Foo foo;
    foo.x = 5;

    uint res = post_cond(&foo);
    io::printfn("post condition: %d", res);

    // Parameter annotations
    DString dstring = dstring::temp();

    // Compile time error since passing null
    //param_anno(null, dstring);

    param_anno(&foo, dstring);
    io::printfn("%s", dstring.str_view());
}
