# Design Patterns to Translating High Level C-Code to MIPs Assembly

<!--
Design Guide to Translating C-code to assembly code
Outline:
  Title
  Table Contents
  Loops
    while
    for
    do while
  conditionals
    if statements
    switch statements

  functions
-->
## Table of Contents

## The Design Process
### Why Design?
Because translating a thought to direct assembly code can be challenging. Following a strict set of rules can make the process less error prone.
### Design Process
#### 1. Write your code as you would in C language. The C language has direct parallels to assembly instructions which is discussed in the rest of the document.
To do this part effectively you must break up your instruction into smallest steps as possible.
#### 2. Assign $sX registers for all int or char type variables you see. Try not to reuse registers as doing so may lead to confusion and errors.
If you need to store more than the 4 bytes of register place pointer address to the register. Address can be in the *.data* section as a label of the program or be dynamical given via sysbrk (you will need to do this for strings and arrays!).
#### 3.  Write your assembly in a MIPs editor. Using the C pseudo code and *this design guide*!
> **Note**
> it is best practice that *ever* line of Assembly has a comment '#' this way debugging is easier and it slows you down to think about what each line does! Further every function should have a signature comment. Doing this will make navigating your code possible to others!

## Loops
### `do while`
The easiest to translate from C to Assembly is the classic `do while` loop.
#### C `do while`
```c
int i = 0;
do {
  i = i + 1;
} while( i < 10 );
```
### Translation to Assembly
1. Map high level variables to assembly registers
```assembly
 # Maping
 ## i => $s0

```
2. Write labels forming the outline of the loop

```assembly
do_loop:

condition:
endloop:
```
3. Fill in the incrimination steps and condition logic
```assembly
do_loop:
  addi $s0, $s0, 1  #$s0 = $s0 + 1
condition: blt $s0, 10, do_loop #if $s0 <i> < 10  then jump to do_loop label
endloop:
```
4. Fill in the rest of the doe
```assembly
do_loop:
  #here is where any other loop tasks will be executed.
  addi $s0, $s0, 1  #$s0 = $s0 + 1
condition: blt $s0, 10, do_loop #if $s0 <i> < 10  then jump to do_loop label
endloop:
```



### `while`

### `for`
