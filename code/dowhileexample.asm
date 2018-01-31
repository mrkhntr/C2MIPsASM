#int main () {                       
#
#   /* local variable definition */  
#   int a = 10;                      
#
#   /* do loop execution */          
#   do {                             
#      printf("value of a: %d\n", a);
#      a = a + 1;                    
#   }while( a < 20 );                
#
#   return 0;                       
#}

# mapping of high-level variables to MIPs registers.
# a -> $s0

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
  

