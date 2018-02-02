# C code with for
# int main()
# {
#   short int v[] = {5, 7, 1, 4, 3};
#     for (int i = 0, i < 5; i++ )
#     {
#      std::cout << v[i] << '\n';
#     }
#   return 0;
# }

# first we translate our `for` loop to a `while` loop and take apart the more complicated
# steps

# int main()
# {
#   short int v[] = {5, 7, 1, 4, 3};    // data that will need to be init on .data
#   int i = 0;                          // initialize data
#   while (i < 5)                       // conditional for loop
#   {
#     int out = v[i];                   // body: we spilt up the steps
#     std::cout << v[i];
#     std::cout << '\n';
#     i = i + 1;                        // incrementation
#   }                                   // endloop
#   return 0;                           // exit
# }

# Mapping of high-level variables
## v[]* => $s0 // we store the address to the begining of the array
## i    => $s1 // the counter
## out  => $s2 // the value at a point of the register

.gobl main                 # needed for real MIPS machines not for simulations

.data

	v: .half 5, 7, 1, 4, 3   # short int v[] = {5, 7, 1, 4, 3}
	newline: .asciiz "\n"    # new line character

.text
	init: li $s1, 0          # $s1 = 0 to initialize the counter of loop

	cond:
	li $t1, 5                # $t1 = 5 hold the constant in a temporay register
	bge	$s1, $t1, endloop    # if $s1 >=  $t1 then escape loop

	body:
	la $s0, v                # load base address of array into $s0
	sll $t2, $s1, 1          # $t2 = i * 2 bytes (every shift left is a multiplication of a power of 2)
  # we could also use pesudo instruction 'mul $t2, $s1, 2' instead
	add $t4, $s0, $t2        # $t4 = *v[i] , $t4 = base address + offset
	lh $s2, 0($t4)           # we did the offset calculation above $s2 = v[i]

  li $v0, 1                # $v0 = 1 <print_int>
	move $a0, $s2            # $a0 = load the int we want to print
	syscall                  # print

	li $v0, 4                # $v0 = 4 <print string>
	la $a0, newline	         # load the new line character
	syscall                  # print

	addi $s1, $s1, 1         # $s1 = $s1 + 1 , i = i + 1

	j cond                   # loop back to conditional

	endloop:                 # end of loop

  # return 0
  li $v0, 10               #$v0 = 10 <exit>
	syscall                  # exit

# About $tX
## These are temporay registers
## Useful to hold values that will be used sortly after writing to them
## Are genrally NOT saved acrossed function calls (jal ...)
