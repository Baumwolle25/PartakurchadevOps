#include <stdio.h>
#include <stdbool.h>

int halfOfCurrentRange(int start, int end)
{
    int a;
    a = end - start;
    a = a / 2;
    return start + a;
}

int main()
{
    // this is our range
    int start = 1, end = 100;

    // center of the range
    int middle;

    // we repeat until we are correct
    bool guessing = true;
    while (guessing)
    {
        // "guess" the number
        middle = halfOfCurrentRange(start, end);
        printf("Was your number: %d ", middle);

        // collect user feedback
        int input;
        scanf("%d", &input);
        printf("Input: %d ", input);
        // decide what to do now
        switch (input)
        {
        // we guessed correctly
        case 0:
            printf("Took you long enough.");
            guessing = false;
            break;
        // we guessed to high
        case 1:
            end = middle;
            break;
        // we guessed to low
        case 2:
            start = middle;
            break;
        // this will happen eventually
        default:
            printf("Wrong Input.");
            break;
        }
    }

    return 0;
}