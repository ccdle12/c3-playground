import std::io;
import std::encoding::hex;
import libc;

fn void main()
{
    char[] x = {'1', '4', '1'};

    //fn char[]? tdecode(char[] code) @inline => decode(tmem, code);
    //char[] bar = hex::tdecode(x)!!;


    CLong bar = libc::strtol(x, null, 16);
    io::printfn("%s", bar);
}
