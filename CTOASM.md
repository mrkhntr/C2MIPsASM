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
int main () {                       

   /* local variable definition */  
   int a = 10;                      

   /* do loop execution */          
   do {                             
      printf("value of a: %d\n", a);
      a = a + 1;                    
   }while( a < 20 );                

   return 0;                       
}
```
### Translation to Assembly
```assembly
.gobl main 			#this tag tells our assembler where to start assembling

.data				#where we allocate space for our data tbat wont fit in a register

	#asciiz means null terminated string, you almost *always* want to use this type of string in your code
	strValue: 	.asciiz	 "value of a: " 	#we need to print out this text also
	newline:	.asciiz  "\n"	#we need to print out the new line character

.text				#tells our assembler where the code for our program begins

main: 				# label addressing the start of our main program

	li 	$s0, 10	#$s0 <a> = 10
	li	$t0, 20 	# $t0 = 20 we need this constant to do the loop comparision  

do_loop:			#label where the start of our loop is so we can jump back to it

	#prints the string before the value
	la	$a0, strValue	# loads the based address of the string to print
	li	$v0, 4			# $v0 = 4 <print_string>
	syscall 			# prints the string

	#prints the value <int> for a
	move	$a0, $s0	# $a0 = $s0 copys over the value to print to the argument register
	li	$v0, 1		# $v0 = 1 <print_int> telling what type of system call
	syscall		# prints the interger in $a0

	#prints the newline string
	la	$a0, newline	# loads the based address of the string to print
	li	$v0, 4			# $v0 = 4 <print_string>
	syscall 			# prints the string


	addi	$s0, $s0, 1	# a = a + 1

	blt 	$s0, $t0, do_loop	# condition to keep looping if a < 20
do_end:			#convience lable showing where the loop logic ends this is helpful for hummans

 	li $v0, 10		# $v0 = 10 <exit>
 	syscall		# exits the program (like return 0)

 #end of main
```


### `while`

### `for`
