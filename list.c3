import std::io;
import std::collections;

fn void main()
{
    char[] x = { '\r', '\n', '\r', '\n', '0', '\r', '\n', '\r', '5' };

    List{char} buf;
    buf.tinit_with_array(x);

    for (int i = 5; i < buf.len(); i++)
    {
        io::printfn("%s", buf[i]);
    }

}
