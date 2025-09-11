import std::thread;
import std::io;

alias BufChan = channel::BufferedChannel{String};
alias Pool = ThreadPool{1};

// There has to be another variable to keep the conditional variable waiting since
// threads can be supriously woken by the OS.
struct Tmp
{
    BufChan chan;
    bool done;
    OutStream out;
}

fn void Tmp.write(&self, String msg)
{
    self.out.write(msg)!!;
}

struct PoolWrapper
{
    Pool pool;
    Tmp tmp;
}

fn PoolWrapper* PoolWrapper.init(&self, Allocator alloc, OutStream out)
{
    BufChan chan;
    chan.init(alloc)!!;
    Tmp tmp = { .chan = chan, .done = false, .out = out };

    self.tmp = tmp;
    self.pool.init()!!;
    self.pool.push((ThreadFn) &worker_thread, self)!!;
    return self;
}

fn void PoolWrapper.push(&self, String msg)
{
    self.tmp.chan.push(msg)!!;
}

fn void PoolWrapper.free(&self)
{
    self.tmp.done = true;
    self.tmp.chan.push("\n")!!;

    self.tmp.chan.close()!!;

    self.pool.destroy()!!;
}

fn void worker_thread(PoolWrapper* pool)
{
    io::printfn("Worker: waiting for signal");
    while (!pool.tmp.done)
    {
        String res = pool.tmp.chan.pop()!!;
        if (pool.tmp.done) return;

        pool.tmp.write(res);
    }
}

fn void main()
{
    Allocator alloc = allocator::heap();
    DString out = dstring::temp();

    PoolWrapper p;
    p.init(alloc, &out);
    defer p.free();

    p.push("foo");

    io::printfn("main: before last sleep");

    thread::sleep_ms(1000);
    io::printfn("main: after last sleep");

    io::printfn("DEBUG OUTPUT: %s", out.str_view());

}
