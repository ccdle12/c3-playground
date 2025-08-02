import std::thread;
import std::io;

// There has to be another variable to keep the conditional variable waiting since
// threads can be supriously woken by the OS.
struct Tmp
{
    Mutex* mtx;
    ConditionVariable* cond;
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
    thread.join()!!;
    io::printfn("shutdown finished");
}

fn void main()
{
    Mutex mtx;
    mtx.init()!!;

    ConditionVariable cond;
    cond.init()!!;

    Tmp tmp = { .mtx = &mtx, .cond = &cond, .ready = 0, .done = false };

    Thread log_thread;
    log_thread.create((ThreadFn) &worker_thread, &tmp)!!;

    mtx.@in_lock()
    {
        thread::sleep_ms(1000);
        tmp.ready = 1;
        tmp.cond.signal()!!;
    };

    io::printfn("main: before last sleep");
    thread::sleep_ms(1000);
    io::printfn("main: after last sleep");

    shutdown(&tmp, &log_thread);
}
