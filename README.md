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
int i = 0; // initialize counter
do { // executed the body at least once
  i = i + 1; //body of the loop
} while( i < 10 ); // conditional
// end of loop
```
### Translation to Assembly
1. Map high level variables to assembly registers
```assembly
 # Maping
 ## i => $s0

```
2. Write labels forming the outline of the loop. Note the four parts of a loop: *Initialize, Body, Condition, End*.

```assembly
init: # initialize variables
do_loop:   
            # body
condition:  # where the loop condition will go
endloop:    # address where the end of the loop
```
3. Fill in the incrimination steps and condition logic. Initialize any counting variables.
```assembly
init: li $s0, 0 #$s0 = 0
do_loop:
  addi $s0, $s0, 1  #$s0 = $s0 + 1
condition: blt $s0, 10, do_loop #if $s0 <i> < 10  then jump to do_loop label
endloop:
```
4. Fill in the rest of the do loop.
This basic example doesn't have interesting task inside loop. Our finished verision looks like the following.
```assembly
init: li $s0, 0 #$s0 = 0
do_loop:
  #here is where any other loop tasks will be executed.
  addi $s0, $s0, 1  #$s0 = $s0 + 1
condition: blt $s0, 10, do_loop #if $s0 <i> < 10  then jump to do_loop label
endloop:
```
>**Note:** Even though the *endloop*  and *init* labels are not used it is best to keep it as it is a reference to the end of the loop and it makes it easier to read by a human.

### `while`
While loops are a bit tricky as they require inverse logic (see conditionals section for inverse logic). While loop are like `do while` except they *first evaluate the condition*.
#### C `while`
```c
int i = 0; // counter
while(i < 10) { // condition
   i = i + 1; // body
}
// end of loop
```
### Translation to Assembly
1. Map high level variables to assembly registers
```assembly
 # Maping
 ## i => $s0

```
2. Write labels and the unconditional jump to the condition forming the outline of the loop. Note the four parts of a loop: *Initialize, Body, Condition, End*.

```assembly
init:          # initialize variables
while_cond:    # condition
               # body
j while_cond   # jump back to conditional
end_loop:      # end of the loop

```
> **Why `j while_cond`?** Think about how an Assembly program runs -- linearly! So we must unconditional jump back to the condition to keep our loop structure! If did not have the jump our program would go through the loop once, that doesn't sound much like a loop!
3. Fill in the incrimination steps and condition logic. Initialize any counting registers. Note the **inverse logic** for the conditional!
```assembly
init: li $s0, 0 #$s0 = 0
while_cond:
  bgt $s0, 9, end_loop  # if $s0 > 9 then jump to end_loop   
                        # Note !(i < 10) == (i >= 10) === (i > 9) for integers
  addi $s0, $s0, 1  #$s0 = $s0 + 1
j while_cond    # jump back to conditional
end_loop:       # end of the loop
```
> If you are confused with inverse logic see conditionals section.

4. Fill in the rest of the `while` loop.
This basic example doesn't have interesting task inside loop. Our finished version looks like the following.
```assembly
init: li $s0, 0 #$s0 = 0
while_cond:
  bgt $s0, 9, end_loop  # if $s0 > 9 then jump to end_loop   
  # here other code for loop
  addi $s0, $s0, 1  #$s0 = $s0 + 1
j while_cond    # jump back to conditional
end_loop:       # end of the loop
```
>**Note:** As before with `do while` Even though the *endloop*  and *init* labels are not used it is best to keep it as it is a reference to the end of the loop and it makes it easier to read by a human.

### `for`
A `for` loop is nothing more than an *abstracted while*. Therefore, it is best just to translate your *for* loop to a `while` loop and then follow the procedure for the `while` loop.
#### C `for`
```c
for ( init; condition; increment ) {
   \\body
} \\ end of loop
```
#### Translating to C `for` to C `while`
It is a simple matter of shifting to translate a `for` loop to a `while` loop.
1. Change `for` to `while`.
2. Place `init` on the outside of the loop. This belongs here as it is executed first and only once.
3. `condition` stays within the statement of the `while`.
4. Place `increment` at the end of the loop before the closing brace '}'.
```c
init                        \\ such as int i = 0;
while (condition) {         \\ such as i < 10;
                            \\body
    increment               \\ such as i = i + 1;
}                           \\end of loop
```
