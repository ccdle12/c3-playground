import std::thread;
import std::io;


alias BufChan = channel::BufferedChannel{String};

// There has to be another variable to keep the conditional variable waiting since
// threads can be supriously woken by the OS.
struct Tmp
{
    Allocator alloc;
    BufChan chan;
    bool done;
    Thread thread;

    Logger logger;
}

fn Tmp* Tmp.init(&self, Allocator alloc, Logger logger)
{
    *self = { .alloc = alloc, .logger = logger, .done = false };

    self.chan.init(self.alloc)!!;
    self.thread.create((ThreadFn) &worker_thread, &self)!!;

    return self;
}

fn void Tmp.push(&self, String msg)
{
    self.chan.push(msg)!!;
}

fn void Tmp.free(&self)
{

    self.done = true;
    self.chan.push("\n")!!;

    self.chan.close()!!;
    self.thread.join()!!;

    io::printfn("shutdown finished");
}

struct Logger
{
   OutStream out;
}

fn Logger* Logger.init(&self, OutStream out)
{
    *self = { .out = out };
    return self;
}

fn void worker_thread(Tmp* tmp)
{
    @pool_init(tmp.alloc, 1024)
    {
        io::printfn("Worker: waiting for signal");
        while (!tmp.done)
        {
            String res = tmp.chan.pop()!!;
            if (tmp.done) return;

            tmp.logger.out.write(res)!!;
        }
    };
}


fn void main()
{

    Allocator alloc = allocator::heap();

    DString out;
    out.init(alloc);

    Logger logger;
    logger.init(&out);

    Tmp tmp;
    tmp.init(alloc, logger);
    defer tmp.free();
    tmp.push("foo");

    io::printfn("main: before last sleep");
    thread::sleep_ms(1000);
    io::printfn("main: after last sleep");

    io::printfn("out has the value: %s", out);
}
