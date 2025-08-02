import std::thread;
import std::io;


alias BufChan = channel::BufferedChannel{String};

// There has to be another variable to keep the conditional variable waiting since
// threads can be supriously woken by the OS.
struct Tmp
{
    Mutex* mtx;
    ConditionVariable* cond;
    BufChan* chan;
    int ready;
    bool done;
}

fn void worker_thread(Tmp* tmp)
{
    io::printfn("Worker: waiting for signal");
    while (!tmp.done)
    {

        tmp.mtx.@in_lock()
        {
            while (tmp.ready < 1 && !tmp.done) {
                io::printfn("Worker: waiting in while loop");
                tmp.cond.wait(tmp.mtx)!!;
            }

            if (tmp.done) return;

            String res = tmp.chan.pop()!!;
            io::printfn("Worker: poped: %s", res);

            io::printfn("Worker: outside of read < 1 loop");
            io::printfn("Worker: got the signal: %d", tmp.ready);

            tmp.ready = 0;
        };
    }
}

fn void shutdown(Tmp* tmp, Thread* thread)
{

    tmp.done = true;
    tmp.cond.signal()!!;
    tmp.chan.destroy()!!;
    thread.join()!!;
    io::printfn("shutdown finished");
}

fn void main()
{
    Mutex mtx;
    mtx.init()!!;

    ConditionVariable cond;
    cond.init()!!;


    Allocator alloc = allocator::heap();
    BufChan chan;
    chan.init(alloc)!!;

    Tmp tmp = { .mtx = &mtx, .cond = &cond, .ready = 0, .done = false, .chan = &chan };

    Thread log_thread;
    log_thread.create((ThreadFn) &worker_thread, &tmp)!!;

    mtx.@in_lock()
    {
        thread::sleep_ms(1000);
        chan.push("foo")!!;
        tmp.ready = 1;
        tmp.cond.signal()!!;
    };

    io::printfn("main: before last sleep");
    thread::sleep_ms(1000);
    io::printfn("main: after last sleep");

    shutdown(&tmp, &log_thread);
}
