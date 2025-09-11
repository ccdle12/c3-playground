import std::net::tcp;
import libc;
import std::net::os;
import std::net;
import std::io;
import std::time;
import std::thread;

extern fn CInt getsockname(NativeSocket socket, SockAddrPtr address, Socklen_t* address_len);

fn void main()
{
    bar();
    //foo();
}

fn void bar()
{
    // TODO: I can use 0 to randomly assign an available port, but then I need to get that port
    TcpServerSocket listen_socket = tcp::listen("127.0.0.1", 0, 0)!!;
    defer listen_socket.close()!!;

	TcpSocket socket;
	socket.ai_addrlen = listen_socket.ai_addr_storage.len;

    // TODO: THIS ACTUALLY WORKS AND GETS THE PORT SET BY 0.
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

fn void foo()
{
    // Create the non-blocking socket initially.
	AddrInfo* ai = net::addrinfo("127.0.0.1", 3035, os::AF_UNSPEC, os::SOCK_STREAM)!!;
	defer os::freeaddrinfo(ai);

    // TODO: Maybe replace with
    //macro void @loop_over_ai(AddrInfo* ai; @body(NativeSocket fd, AddrInfo* ai))
	while (ai)
	{
		NativeSocket sockfd = os::socket(ai.ai_family, ai.ai_socktype, ai.ai_protocol);
		if (sockfd.is_valid())
		{
            //io::printfn("ai_addr in foo: %s", sockfd.ai_addr_storage);

            int err_bind = os::bind(sockfd, ai.ai_addr, ai.ai_addrlen);
            libc::perror("error code");

            int err_listen = os::listen(sockfd, 10);
            libc::perror("error code");


            // Connect the non-blocking socket
            NativeSocket connect_sock = os::socket(ai.ai_family, ai.ai_socktype, ai.ai_protocol);
            connect_sock.set_non_blocking(true)!!;

            // TODO: I tihnk this is wrong, we shld be connecting to sockfd?
            int err_connect = os::connect(connect_sock, ai.ai_addr, ai.ai_addrlen);
            libc::perror("error code");
            connect_sock.set_non_blocking(false)!!;

            io::printfn("here before accept");
	        int new_sockfd = os::accept(sockfd, null, null);
            io::printfn("here after accept");
            break;
		}
		ai = ai.ai_next;
	}

    //



    // Set socket to non_blocking again.
    //connect_sock.set_non_blocking(false)!!;

    //io::printfn("here before accept");
    //TcpSocket foo = tcp::accept(&listen_socket)!!;
	//listen_sock = os::accept(listen_sock, null, null);
    //io::printfn("here after accept");

}
