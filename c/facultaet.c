#include <stdio.h>

int main() {

    double n = 4;

    double fakultaet(double n);
    {
        if (n < 1) return (1);
        else return (n * fakultaet(n-1));
    }
    
    printf("Fakultaet von %.1lf ist %.1lf", n, fakultaet(n));

    return 0;
}