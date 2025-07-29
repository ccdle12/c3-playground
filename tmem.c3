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
    int* d;

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
        io::printfn("c outside of foo() called in scope: %d", *c);
    }
    io::printfn("c outside of foo(), outside of pool: %d", *c);

    // Calling D, which was already released in pool within the function - dangling poiner.
    d = bar();
    io::printfn("d outside of bar(): %d", *d);

    // b is not freed yet, since its using the global temporary allocator.
    io::printfn("y (a) outside of @pool: %d", *y);
    io::printfn("z (b) outside of @pool: %d", *z);

} // b and the temporary allocator is freed here (when main exits).

// I'm showing that using tmem (global temp), its allocated, but won't be dropped
// until main exits or this function is called from with @pool.
fn int* foo() {
    int* c = mem::tnew(int); // same as saying allocator::new(tmem, int);
    *c = 10;

    return c;
}

// This function shows that you can allocate tmem in a @pool (creating a temporarily scoped alloc in tmem) and return the pointer, this will be a dangling pointer, since the memory will already be freed.
fn int* bar() {
    @pool()
    {
        int* d = mem::tnew(int);
        *d = 10;
        io::printfn("d inside of bar(): %d", *d);

        return d;
    };
}
