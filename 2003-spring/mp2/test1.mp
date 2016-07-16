
====== ECE291 Intensive RPN Calculator =======
Enter Numbers with space between each    -and-
   Operation (+ - * / ^)                      
=============== Spring 2003 ==================

> 4 15 15 5 5 10 - / * + /

Calculate: OVERFLOW

ProcessOperations: Calculation Error detected
> 15 9 30000 10000 2 5 - / / + *

Result: 0

> 0 15 /

Result: 0

> 16384 3 2 / +

Calculate: OVERFLOW

ProcessOperations: Calculation Error detected
> 16384 3 1 3 - / +

Calculate: OVERFLOW

ProcessOperations: Calculation Error detected
> 16385 3 2 / /

Calculate: OVERFLOW

ProcessOperations: Calculation Error detected
> 32767 1 32767 / /

Calculate: OVERFLOW

ProcessOperations: Calculation Error detected
> 30000 7 30 / *

Result: 7000

> 4 8 ^

Error! Exponent overflow

ProcessOperations: Calculation Error detected
> 2 15 ^

Error! Exponent overflow

ProcessOperations: Calculation Error detected
> 34 19 3 / ^

Error! Exponent can not be a fraction

ProcessOperations: Calculation Error detected
> 2 1 3 - ^

Result: 1/4

> 0 0 16 7 89 2 3 6 3 0 ^ * ^ - / + + + -

Result: -22 638/727

> 
GetString: AX returns 0; Need Input
> 