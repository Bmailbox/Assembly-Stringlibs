.global strfix
.global strcat
.global strcmp
.global strcpy
.global strlen
.global strlwr
.global strupr
.global strim
.global strprint
.global equal @Will be transfered to a seperate lib 
.global notequal @Will be transfered to a seperate lib
.global termnull @function to terminate string with null will be transfered to a seperate lib




@Strfix is a function that will take a /n terminated string and null terminate it, each line is commented for further detail

strfix:
loop:
	LDRB	r0, [r1] @load the first byte of the string into register zero 
	CMP		r0, #10  @compare to see if current pointed bit is equivalent to the ascii value of /n
	
	ADDNE 	r1, r1, #1 @if not equal, move address to the next character
	BNE		loop @if the not the /n character, jump to the loop label and restart process 
	
	MOV		r3, #0 @put null in register 3
	STRB	r3, [r1] @put the null where the pointed char is
	
	
	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one



@ strcat is a function that will take two existing strings and concatonate them together, each line is commented for further detail
strcat:
loopcatfirstseg:
@prelimary setup, this code block will be used to find the location of null to know when to start appending 
	LDRB	r0, [r1] @load the first byte of the string into register zero 
	CMP		r0, #0  @compare to see if current pointed bit is equivalent to the ascii value of null
	STRB	r0, [r6]
	ADDNE 	r1, r1, #1 @if not equal, move address to the next character
	ADDNE	r6, r6, #1 @if not equal move to the next positon of the blank string
	BNE		loopcatfirstseg @if the not the null character, jump to the loop label and restart process 
	
	@fixes a problem if a string has a newline terminated char 
	SUB		r6, r6, #1 @step back one position in the string
	LDREQB	r0, [r6] @load null in r0 if condition is met
	CMP		r0, #10 @check to see if the position is the newline char
	STREQB	r0, [r6]@store null in r0 if condition is meta

@same functionality as the previous loop but for the second string
loopcatsecondseg:
	
	
	
	LDRB	r0, [r3]
	CMP		r0, #0
	STRB	r0, [r6]
	ADDNE	r3, r3, #1
	ADDNE	r6, r6, #1
	BNE		loopcatsecondseg

	
	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one
	

@strcmp is a function that will comapre two strings and set a flag to determine whether they are equal or not
strcmp:

cmploop:

	LDRB	r0, [r3]
	LDRB	r2, [r10]
	CMP		r0, r2  @compare the contents of r0 with the loaded bit at r10, which is being stored in r2
	ADDEQ	r3, r3, #1 @increment the counter for r1
	ADDEQ	r10, r10, #1 @increment the counter for r10
	

	BEQ 	cmploop  @if not equal go to the next part where it will compare if the last bits are null and determine whether its equal or not 
	
	SUB		r3, r3, #1 @subtract the bit postion of r3 to see if it will be null, if null then its equal
	SUB		r10, r10, #1@subtract the bit postion of r10 to see if it will be null, if null then its equal
	
	LDRB	r0, [r3] @load the current bit of r3 into register 0
	LDRB	r2, [r10] @load the current bit of r10 into register 2
	
	CMP		r0, #0 @compare to see r0 is null
	
	CMPEQ   r2, #0  @if r0 had a null, compare r2 to see if it also has a null
	
	
	MOV 	PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one
	

@strcpy is a subroutine that will copy an existing string into another memory address 
strcpy:
cpyloop:

	LDRB	r0, [r1]@load the current pointed bit of r1 into r0 
	CMP		r0, #0 @check to see if null is the current bit
	STRB	r0, [r8] @store the bit into the current postion of r8
	ADDNE	r1, r1, #1 @increment the position of r1
	ADDNE 	r8, r8, #1 @increment the postition of r8
	BNE		cpyloop @if pointed bit is not null then restart loop process 
	
	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one
	
	
@strlen is a function that will determine the length of a string, it is called by the string print subroutien to determine the size of the string to print
strlen:
	@POP		{r1} @pop r1 containing the string off of the stack
looplen:
	
	LDRB	r0, [r1] @load the first byte of the string into register zero 
	ADD		r9, r9, #1 @increment counter
	CMP		r9, #21

	
	CMP		r0, #0  @compare to see if current pointed bit is equivalent to the ascii value of null
	
	ADDNE 	r1, r1, #1 @if not equal, move address to the next character
	
	BNE		looplen @if the not the null character, jump to the loop label and restart process 
	
	
	SUB		r9, r9, #1  @since the /null character is counted as well we will subtract one so that it isnt counted 
	
	@MOV		r0,r9	@prepare for output on shell
	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one
	
@ strlwr is a subroutine that will covnert any uppercase chars in a string to lower case
strlwr:

lowerloop:
	LDRB	r0, [r5] @load the first byte of the string into register zero
	CMP		r0, #0 @compare to see if pos is NULL
	BEQ		exitloop @if it is then exit the loop to prevent overwrting the null char (NUll char is needed for strlen)
	CMP		r0, #90 @compare r0 with the ascii value for uppercase Z, the last uppercase ascii value 
	ADDLT	r6, r0, #32 @if r0 was less than 90, add 32 to get its lower case equivalent 
	STRLTB	r6, [r5]@ loads lower string to place where original Upper char was if less than 
	ADD 	r5, r5, #1 @increment to next char
	CMP		r0, #0 @check to see if value has hit null yet
	BNE		lowerloop @if condition is not met, loop back
	
	
exitloop:

	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one


@ strupr is a subroutine that will covnert any lowercase chars in a string to uppercase	
strupr:
upperloop:

	LDRB	r0, [r4] @load the first byte of the string into register zero
	CMP		r0, #90 @compare r0 with the ascii value for uppercase Z, the last uppercase ascii value 
	SUBGT	r5, r0, #32 @if r0 was greater than 90, sub 32 to get its lower case equivalent 
	STRGTB	r5, [r4]@ loads upper string to place where original Upper char was if greater than 
	ADD 	r4, r4, #1 @increment to next char
	CMP		r0, #0 @check to see if value has hit null yet
	BNE		upperloop@if condition is not met, loop back
	
	
	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one
	
	
@Work in progress
strim:
	@insert code
	
	MOV		PC,LR
	
@ strprint is a subroutine that prints out a given string 
strprint:
	
	@tempeorary measure, must PUSH r1 to the stack in the start file inorder to retain pointer position when entering subroutine
	POP		{r1} @pop off r1 to get pointer at the beggining of the string
	PUSH	{r1,r12,LR} @push r1 to prepare it for the strlen function, LR gets pushed and poped as well to allow the subroutine to exit smoothly, r12 is used for stroing the /n char
	BL		strlen
	POP		{r1,r12,LR} @pop off r1 once again to regain the origianl pointer position of the string (pointing to the beggining of the string
	

	
	MOV		r2,r9 @setting the length of the string
	MOV		r9,#0 @reset the counter to 0 for the next time the strprint subroutine is called
	
	MOV		r0,#0 @prepare for output
	
	
	SWI		0
	
	MOV		r2,#0 @reset r2 so that the next length is added onto the previous length
	
	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one
	
	
	
	
@Optional Subroutines, will be transfered to a seperate file 	
	
	
@ equal is a subroutine to print out the string equal if two strings are compared and found to be equal
equal:
	
	POP		{r1} @pop off r1 to get pointer at the beggining of the string
	MOV		r0, #0 @prepare for output
	MOV		r2, #7 @length of the word equal including the 2 \n chars
	
	SWI		0
	
	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one
	
@ notequal is a subroutine to print out the string not eqaul if two strings are compared and found to be not equal
notequal:
	
	POP		{r1} @pop off r1 to get pointer at the beggining of the string
	MOV		r0, #0@prepare for output
	MOV		r2, #11 @length of the word not equal including the 2 \n chars
	
	SWI		0
	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one
	
	
@termnull is a subroutine which will terminated a  null terminated string with a newline char
termnull:


	nullloop:
	
	LDRB	r0, [r1] @load the first byte of the string into register zero 
	CMP		r0, #0  @compare to see if current pointed bit is equivalent to the ascii value of /n
	
	ADDNE 	r1, r1, #1 @if not equal, move address to the next character
	BNE		nullloop @if the not the /n character, jump to the loop label and restart process 
	
	MOV		r12, #10 @storing newline char into r12
	STRB	r12, [r1] @sstore the new line char into the current position of r1
	
	MOV		PC,LR @move the LR to the PC to prevent the subroutine from flowing into the next one
	
	

