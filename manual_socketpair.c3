import std::net::tcp;
import libc;
import std::net::os;
import std::net;
import std::io;
import std::time;
import std::thread;
import std::os::win32;

extern fn CInt getsockname(NativeSocket socket, SockAddrPtr address, Socklen_t* address_len);

fn void main()
{
    bar();
}

fn void bar()
{
    $if env::WIN32:
        Win32_WORD version = 0x0202;

        char[408] wsa_data;
        CInt wsa_error = win32::wsaStartup(version, &wsa_data);
        defer win32::wsaCleanup();
    $endif

    TcpServerSocket listen_socket = tcp::listen("127.0.0.1", 0, 0)!!;
    defer listen_socket.close()!!;

	TcpSocket socket;
	socket.ai_addrlen = listen_socket.ai_addr_storage.len;

    int result = getsockname(listen_socket.sock, (SockAddrPtr) &socket.ai_addr_storage, &socket.ai_addrlen);
    libc::perror("error code");

    // NOTE:
    // lport_view[0] is the most significant byte
    // lport_view[1] is the least most significant byte
    char[] lport_view = socket.ai_addr_storage[2:2];
    int lport = (lport_view[0] << 8) + lport_view[1];
    io::printfn("socket bit shifted lport: %s", lport);

    TcpSocket connect_socket = tcp::connect_async("127.0.0.1", lport)!!;
    defer connect_socket.close()!!;

    thread::sleep_ms(1000);

    io::printfn("before accept");
    TcpSocket soc = tcp::accept(&listen_socket)!!;
    defer soc.close()!!;
    io::printfn("after accept");

    thread::sleep_ms(1000);

    connect_socket.write("hello, world!")!!;

    char[8192] buf;
    soc.read(&buf)!!;

    String final_result = (String) &buf;
    io::printfn("final_result: %s", final_result);

}
