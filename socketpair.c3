import std::net::tcp;
import std::net::os;
import std::io, libc, std::os;
import std::collections;

fn void main()
{
    //socket_pair()!!;
    using_tcp_pair()!!;
}

// NOTE: This is using my own fork of the std::lib/compiler that contains socketpair.
//fn void? socket_pair()
//{
//    CInt[2] sockets;
//
//    if (libc::socketpair((CInt) os::AF_UNIX, (CInt) os::SOCK_STREAM, 0, &sockets) == -1)
//    {
//        libc::perror("socket pair error");
//    }
//
//    char[] buf = "Hello from socket 0!";
//
//    Socket send_sock = { .sock = (NativeSocket) sockets[0] };
//    usz bytes_read = send_sock.write(buf)!!;
//
//    Socket read_sock = { .sock = (NativeSocket) sockets[1] };
//
//    char[50] recv_buf;
//    bytes_read = read_sock.read(&recv_buf)!!;
//    recv_buf[bytes_read] = '\0';
//    io::printfn("%s", (String) &recv_buf);
//}

fn void? using_tcp_pair()
{
    TcpSocket send; TcpSocket recv;
    defer send.close()!!;
    defer recv.close()!!;

    tcp::socket_pair()!!.unpack(&send, &recv);

    char[] buf = "Hello from tcp pair!";
    usz bytes_read = send.write(buf)!!;

    char[50] recv_buf;
    bytes_read = recv.read(&recv_buf)!!;
    io::printfn("%s", (String) &recv_buf);
}
