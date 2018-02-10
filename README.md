<h1><center>Introductory Design Patterns to Translating High Level C-Code to MIPS Assembly </center></h1>

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
* [The Design Process](#the-design-process)
	- [Why Design?](#why-design)
	- [Design Steps](#design-steps)
* [Conditionals](#conditionals)
  - [Important Note: Inverse Logic](#important-note-inverse-logic)
  - [`if-then-else`](#if-then-else)
  - [Extended Example with `else-if`](#if-then-else-if-else)
* [Loops](#loops)
	- [`do while`](#do-while)
	- [`while`](#while)
	- [`for`](#for)
********************************************************************************
## The Design Process
### Why Design?
Because translating a thought to direct assembly code can be challenging. Following a strict set of rules can make the process less error prone.
### Design Steps
#### 1. Express the solution to the coding problem as you would in C language. The C language has direct parallels to assembly instructions which is discussed in the rest of the document.
It may help by separating as many steps of your C code as possible. For example, see the following:
```c
arrA[0] = arr[10];
// instead do \/
A = arrA[0];
arr[10] = A;
```
Most of the time this type of translation will be easier to understand if you take the second route over the first.

#### 2. Assign $sX registers for all int or char type variables you see. Try not to reuse registers as doing so may lead to confusion and errors.
If you need to store more than the 4 bytes that a MIPS register holds (e.g. for arrays or strings) you will need to a place pointer address to memory in the register. Address can be in the *.data* section or be dynamical given via `sysbrk` or via the stack frame.
#### 3.  Write your assembly in a [MIPS editor](http://courses.missouristate.edu/KenVollmar/mars/). Using the C pseudo code and *this design guide*!
> **Note:**
> it is best practice that almost every instruction line of Assembly has a comment `#`. This way debugging is easier and it slows you down to think about what each line does! Further every function should have a signature comment. Doing this will make navigating your code possible to others!
********************************************************************************
## Conditionals
### Important Note: Inverse Logic
The key to translating `if-then-else` and [looping](#loops) control flow is understanding the need to use inverse logic. The reasons we need to apply inverse logic to our conditionals from C to Assembly is because assembly instructions are executed linearly in order. Therefore, we want to see if we need to skip a section of our code (the body of the `if` or loop statement) otherwise execute the next instruction(s). *When the statement in our condition is false we do not execute the next line(s)* we either jump to the next condition or exit the control flow statement. This may sound confusing, but with practice and through looping through the provided example it should become clear why it is necessary.

********************************************************************************
### `if-then-else`
Using the knowledge of inverse logic we are ready to start with our first design pattern, `if-then-else` control flow!   
#### Example C `if-then-else`
```c
int a = 10;
int b = 20;

if( a == b )         \\ condition
{                    \\ then if condition is true
  a = a + 1;         
} else               \\ else if all conditions are false
{
  b = a;
}                    \\ end of if statement
```
> **Note:** A nuanced feature that we will have to consider in translation with the C `if` is that once an
`if` is taken the other branches do *not* get considered, we either just go to the
code at the end of the `if` statement or we returned within the `if`.
#### Translation to Assembly
1. Map high level variables to assembly registers.
```assembly
# Mapping
## a => $s0
## b => $s2
```
2. Write the structure of the conditional with labels. Include any jumping to end the if-statement.  
```assembly
conditional:           # if-condition

then:                  # start of the then logic
  j end_if             # jump unconditionally to the end (only one if statement can be taken)

else:                  # else condition and logic
                       # here we could put j end_if but that would be redundant as the next line is just that!

end_if:                # the end of the if statement logic your other code goes after this
```
> **Why `j end_if`?** Think about how an Assembly program runs -- linearly! Here we do not want the else block to be executed if an `if` condition is already taken.
3. Fill in logic for the conditional. **Remember [inverse logic](#important-note-inverse-logic)**.
```assembly
conditional: bne $s0, $s2, else    # if $s0 <a> != $s1 <b> jump to else
then:                              # this will be the next line if branch above not true
  j end_if
else:
end_if:
```
4. Add other computation to the loop and initialize registers.
```assembly
  li $s0, 10          # $s0 <a> = 10
  li $s1, 20          # $s1 <b> = 20

conditional: bne $s0, $s2, else    # if $s0 <a> != $s1 <b> jump to else
then:
  addi $s0, $s0, 1    # $s0 = $s0 + 1
  j end_if
else:
  move $s1, $s0       # $s1 = $s0 (copies over value)
end_if:               # any other code
```

#### **Have else if?** *Just add more labels in step 2.*
**********************************************
### `if-then-else-if-else`
This is nothing more than an extension of the steps for the `if-then-else` basic example above.
#### Extended Example C `if-then-else if-else` (More Elaborate Example from Above)
```c
if( a == b )         \\ condition1
{                    \\ then if condition1 is true
  a = a + 1;         
} else if ( a > b)   \\ !!!NEW!!! condition2                   !!!NEW!!!
{                    \\ then if condition2 is true and condition1 was not
  b = a + 1;
}
 else                \\ else if all conditions are false
{
  b = a;
}                    \\ end of if statement
```


#### Assembly Translation
Here is the structure with the extra condition as shown in the [extended C example](#extended-example-c-if-then-else-if-else-more-elaborate-example-from-above). The bodies of the `if` statements are omitted for clarity. The changes we made are:
1. Change the jumping logic for the first `if` branch so we jump to the second (else-if) branch if the first `if` branch is not executed.   
2. Add the logic for the second `if` branch in a similar fashion we did to the first `if` branch.
```assembly
conditional1:           # if-condition
  bne $s0, $s2, conditional2    # if $s0 <a> != $s1 <b> jump to conditional2, inverse logic of == ## NEW LOGIC!!!
then1:                  # start of the then logic
     # body (omitted)
  j end_if              # jump unconditionally to the end (only one if statement can be taken)

## NEW SECTION
conditional2:           # here we need two lines for inverse logic as !(a > b) == (a <= b) == ((a == b) || (a < b))
  beq $s0, $s1, else    # if $s0 == $s1 then jump to else (note this is redundant but here for clarity of design)
  blt $s0, $s1, else    # if $s0 < $s1 then jump to else
then2:
    # body (omitted)
  j end_if             # jump unconditionally to the end (only one if statement can be taken)
## END OF NEW SECTION

else:                  # else condition
    # body (omitted)  
                       # here we could put j end_if but that would be redundant as the next line is just that!

end_if:                # the end of the if statement logic your other code goes after this
```
> **Big Idea:** See how this can be extend for any amount of `else-if`s. The conditional section always points to the next else-if or else (at the last else if) and before any conditional we must have a `j end_if` to exit the `if` if a condition was taken as *only one*  if condition can be taken in an `if` statement in C.
********************************************************************************
## Loops
### `do while`
The easiest loop to translate from C to Assembly is the classic `do while` loop. This is the easiest as we execute the loop at least once and then evaluate the logic.

#### [Example of `do while` in the Wild](../master/code/dowhileexample.asm)  

#### C `do while`
```c
int i = 0;               // initialize counter
do {                     // executed the body *at least* once
  i = i + 1;             // body of the loop
} while( i < 10 );       // conditional
...                      // end of loop
```
#### Translation to Assembly
1. Map high level variables to assembly registers.
```assembly
 # Mapping
 ## i => $s0

```
2. Write labels forming the outline of the loop. Note the four parts of a loop: *Initialize, Body, Condition, End*.

```assembly
init:                     # initialize variables such as a counter
do_loop:                  # address where the loop begins
                          # body
condition:                # where the loop condition will go
endloop:                  # address where the end of the loop
```
3. Fill in the incrimination steps and condition logic. Initialize any counting variables.
```assembly
init: li $s0, 0                          # $s0 = 0, init counter
do_loop:  
  addi $s0, $s0, 1                       # $s0 = $s0 + 1 incrimination
condition: blt $s0, 10, do_loop          # if $s0 <i> < 10  then jump to do_loop label
endloop:
```
4. Fill in the rest of the `do loop`.
This basic example doesn't have interesting task inside loop. Our finished version looks like the following.
```assembly
init: li $s0, 0                     #$s0 = 0
do_loop:
  ...                               # here is where any other loop tasks will be executed.
  addi $s0, $s0, 1                  # $s0 = $s0 + 1

condition: blt $s0, 10, do_loop     # if $s0 <i> < 10  then jump to do_loop label

endloop:
```
>**Note:** Even though the *endloop*  and *init* labels are not used it is best to keep it as it is a reference to the end of the loop and initialization of data. This is useful for a human reading your code.
********************************************************************************
### `while`
While loops are a bit tricky as they require [inverse logic](#important-note-inverse-logic). While loop are like `do while` except they *first evaluate the condition*.

#### [Example of `while` in the Wild](../master/code/for_and_while_example.asm)
>**Note:** this example first [translates a C `for`](#for) loop to a `while loop`
>  and then translates that to the Assembly

#### C `while`
```c
int i = 0;                  // counter
while(i < 10)               // condition
{                           // body
   i = i + 1;               
}
...                         // end of loop
```
#### Translation to Assembly
1. Map high level variables to assembly registers.
```assembly
 # Mapping
 ## i => $s0

```
2. Write labels and the unconditional jump to the condition forming the outline of the loop. Note the four parts of a loop: *Initialize, Body, Condition, End*.

```assembly
init:          # initialize variables such as a counter
while_cond:    # condition
               # body
j while_cond   # jump back to conditional
end_loop:      # end of the loop

```
> **Why `j while_cond`?** Think about how an Assembly program runs -- linearly! So we must unconditional jump back to the condition to keep our loop structure! If did not have the jump our program would go through the loop once, that doesn't sound much like a loop!
3. Fill in the incrimination steps and condition logic. Initialize any counting registers. Note the **[inverse logic](#important-note-inverse-logic)** for the conditional!
```assembly
init: li $s0, 0                     # $s0 = 0, init counter

while_cond:
  bgt $s0, 9, end_loop              # if $s0 > 9 then jump to end_loop   
                                    # *NOTE* !(i < 10) == (i >= 10) === (i > 9) for integers
  addi $s0, $s0, 1                  # $s0 = $s0 + 1 incrimination
j while_cond                        # jump back to conditional
end_loop:                           # end of the loop
```
> If you are confused with [inverse logic](#important-note-inverse-logic) see conditionals section.

4. Fill in the rest of the `while` loop.
This basic example doesn't have interesting task inside loop. Our finished version looks like the following.
```assembly
init: li $s0, 0 #$s0 = 0

while_cond:
  bgt $s0, 9, end_loop              # if $s0 > 9 then jump to end_loop   
  ...                               # here other code for loop can go if we had any
  addi $s0, $s0, 1  #$s0 = $s0 + 1

j while_cond                        # jump back to conditional

end_loop:                           # end of the loop
```
>**Note:** As before with `do while` Even though the *init* label is not used it is best to keep it as it is a reference to initialize part of the loop and make it more readable to a human.

********************************************************************************
### `for`
A `for` loop is nothing more than an *abstracted while*. Therefore, it is best just to translate your `for` loop to a `while` loop and then follow the procedure for the `while` loop. Through looking at the following example this should become clear.

#### [Example of `for` to `while` in the Wild](../master/code/for_and_while_example.asm)

#### C `for` Example

```c
for ( init; condition; increment )     
{                                     \\ body
    ...                                  
}                                     \\ end of loop
```
#### Translating to C `for` to C `while`
It is a simple matter of shifting to translate a `for` loop to a `while` loop.
##### C `for` Translated
```c
init                        \\ such as int i = 0;
while (condition)           \\ such as i < 10;
{                           \\ body
  ...                      
  increment                 \\ such as i = i + 1;
}                           \\end of loop
```
##### `for` -> `while` Steps
1. Change `for` to `while`.
2. Place `init` on the outside of the loop. This belongs here as it is executed first and only once.
3. `condition` stays within the statement of the `while`.
4. Place `increment` at the end of the loop before the closing brace `}`.
5. Follow the steps to translate `while` loops to Assembly.

********************************************************************************
<center> Written by Mark Hunter -- Updated: February 2018 </center>
