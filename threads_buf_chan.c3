import std::thread;
import std::io;

alias BufChan = channel::BufferedChannel{String};

// There has to be another variable to keep the conditional variable waiting since
// threads can be supriously woken by the OS.
struct Tmp
{
    BufChan* chan;
    bool done;
}

fn void worker_thread(Tmp* tmp)
{
    io::printfn("Worker: waiting for signal");
    while (!tmp.done)
    {
        String res = tmp.chan.pop()!!;
        if (tmp.done) return;

        io::printfn("worker_thread: poped(): %s", res);
    }
}

fn void shutdown(Tmp* tmp, Thread* thread)
{

    tmp.done = true;
    tmp.chan.push("\n")!!;

    tmp.chan.close()!!;
    thread.join()!!;

    io::printfn("shutdown finished");
}

fn void main()
{

    Allocator alloc = allocator::heap();
    BufChan chan;
    chan.init(alloc)!!;

    Tmp tmp = { .done = false, .chan = &chan };

    Thread log_thread;
    log_thread.create((ThreadFn) &worker_thread, &tmp)!!;

    chan.push("foo")!!;

    io::printfn("main: before last sleep");
    thread::sleep_ms(1000);
    io::printfn("main: after last sleep");

    shutdown(&tmp, &log_thread);
}
