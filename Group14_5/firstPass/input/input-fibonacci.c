float fib(int n) {
    if (n <= 2) {
        return 1;
    }
    float a = fib(n-1) + fib(n-2);
    print a;
    return a;
}

int main() {
   float f;
   int n;
   read n;
   f = fib(n);
   print f;
   return 0;
}