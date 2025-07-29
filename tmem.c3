import std::io;
import std::core::mem;

fn void main() {
    Allocator alloc = tmem;

    // Pointers to the memory in the pool.
    // y -> a
    // z -> b
    int* y;
    int* z;
    int* c;

    @pool()
    {
        int* a = mem::tnew(int); // same as saying allocator::new(tmem, int);
        int* b = allocator::new(alloc, int);

        *a = 10;
        *b = 10;

        io::printfn("a in @pool: %d", *a);
        io::printfn("b in @pool: %d", *b);

        y = a;
        z = b;

    }; // a and inner temporary allocator is released.

    // Tmem must be global, an arena allocator that bumps memory and only dropped
    // when maine exits.
    {
        c = foo();
        io::printfn("c outside of foo called in pool: %d", *c);
    }
    io::printfn("c outside of foo, outside of pool: %d", *c);

    // b is not freed yet, since its using the global temporary allocator.
    io::printfn("y (a) outside of @pool: %d", *y);
    io::printfn("z (b) outside of @pool: %d", *z);

} // b and the temporary allocator is freed here (when main exits).

// I'm showing that using tmem (global temp) the liftime is dropped in a pool scope
// or waits until main exits.
fn int* foo()  {
    int* c = mem::tnew(int); // same as saying allocator::new(tmem, int);
    *c = 10;

    return c;
}
