import libc;
import std::net::os;
import std::os::win32;

fn void main()
{
    libc::printf("Hello, World\n");

    // Using libc to malloc and free.
    int *y = libc::malloc(10);
    libc::free(y);


    // os also has c ABI FFI
	os::SO_REUSEADDR;

    win32::Win32_SOCKADDR_STORAGE storage;
}
