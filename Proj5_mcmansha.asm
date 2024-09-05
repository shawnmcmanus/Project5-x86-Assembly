TITLE Arrays, Addressing, and Stack-Passed Parameters     (Proj5_mcmansha.asm)

; Author: Shawn McManus
; Last Modified: 8/2/2024
; OSU email address: mcmansha@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5                Due Date: 8/11/2024
; Description: Generates an array of random integers in between a particular interval, sorts them, outputs amount of times each
;			   number appears in array, and calculates the median of the array ('array' and 'list' are used in comments interchangeably).

INCLUDE Irvine32.inc

LO = 15
HI = 50
ARRAY_SIZE = 200

.data

intro_1				BYTE	"Generating, Sorting, and Counting Random integers!",13,10,
							"Programmed by Shawn McManus (mcmansha)",13,10,0
intro_2				BYTE	13,10,"This program generates an array of random integers in between a particular interval (inclusive), ",13,10,
							"sorts the list in increasing value, outputs the amount of times each number appears ",13,10,
							"in the array, and calculates the median of the array.",13,10,0

unsorted_title		BYTE	13,10,"Your unsorted random numbers:",13,10,0
median_title		BYTE	"The median value of the array: ",0
sorted_title		BYTE	13,10,"Your sorted random numbers:",13,10,0
count_title			BYTE	13,10,"Your list of instances of each generated number, starting with the smallest value:",13,10,0
farewell_message	BYTE	13,10,"Thank you for using this program!",0

someArray			DWORD	ARRAY_SIZE DUP(?)
unsortedArray		DWORD	ARRAY_SIZE DUP(?)
sortedArray			DWORD	ARRAY_SIZE DUP(?)
countArray			DWORD	ARRAY_SIZE DUP(?)
numPerLine			DWORD	20


.code
main PROC
	push		OFFSET intro_1
	push		OFFSET intro_2
	call		introduction					;Introduce user to the program

	call		Randomize						;Generate random seed
	push		OFFSET someArray				;**From Module 6.3
	call		fillArray						;Fills the array with random integers

	
	push		ARRAY_SIZE
	push		OFFSET unsorted_title
	push		numPerLine
	mov 		ESI, OFFSET someArray
	call		displayList						;Showcases unsorted list
	
	push		OFFSET someArray	
	call		sortList						;Sorts original list

	push		OFFSET median_title
	push		OFFSET sortedArray
	call		displayMedian					;Displays median of the array

	push		ARRAY_SIZE
	push		OFFSET sorted_title
	push		numPerLine
	mov 		ESI, OFFSET sortedArray
	call		displayList						;Showcases sorted list
	
	push		OFFSET count_title
	push		OFFSET sortedArray
	push		OFFSET countArray
	call		countList						;Counts the number of instances each number appears in the array

	push		OFFSET farewell_message
	call		farewell						;Good-bye message

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ***************************************************************
; Procedure to introduce the program and its goal.
; receives: address of greeting and intro_1 on system stack
; returns: None
; preconditions: None
; registers changed: EDX and EBP
; ***************************************************************
introduction	PROC
		push	EBP
		mov		EBP, ESP
		push	EDX
		mov		EDX, [EBP + 12]		
		call	WriteString			;Print out intro_1
		mov		EDX, [EBP + 8]
		call	WriteString			;Print out intro_2
		pop		EDX
		pop		EBP
		ret		8

introduction	ENDP


; ***************************************************************
; Fills the array with 200 random integers in a certain range
; receives: none
; returns: the random integer array
; preconditions: Randomize is called and the array address is passed
; postconditions: the array contains only integers in between LO and HI (inclusive)
; registers changed: EBP, EAX, ECX, EDI, ESI
; ***************************************************************
fillArray	PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	ECX
	push	EDI
	push	ESI

	mov		ECX, ARRAY_SIZE			;Array length into ECX
	mov		EDI, [EBP + 8]			;Addres of array into EDI

_fillLoop:
	mov		EAX, HI			
	sub		EAX, LO					;Gives us HI-LO as a result
	inc		EAX						;Makes it so we will include 50 in our range
	call	RandomRange
	add		EAX, LO					;Adds LO to any random int created so that it falls inside [LO, HI]
	mov		[EDI], EAX				;Store random number in the array **From Module 6.3
	add		EDI, TYPE someArray
	loop	_fillLoop	

	pop		ESI
	pop		EDI
	pop		ECX
	pop		EAX
	pop		EBP
	ret		4

fillArray	ENDP


; ***************************************************************
; Sorts the random array of integers using bubble sort.
; receives: address of the original array 
; returns: A sorted array stored in sortedArray
; preconditions: someArray is filled with an array of random integers
; postconditions: the array passed is in sorted order at its memory location
; registers changed: EBP, EAX, EDI, ECX, ESI, EDX
; ***************************************************************
sortList	PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	EDI
	push	ECX
	push	ESI
	push	EDX

	mov		EDI, [EBP + 8]			;Address of the array
	mov		ECX, ARRAY_SIZE
	
_outerLoop:
	dec		ECX						;Sets it to 199 since index starts at 0, decrements each loop
	mov		ESI, EDI
	mov		EAX, ECX
	jle		_endsort
	
_innerLoop:
	mov		EBX, [ESI]				;EBX is element 'i' in the array (array[i])
	mov		EDX, [ESI + 4]			;EDX is element 'j' in the array (array[i + 1] = array[j])
	cmp		EBX, EDX
	jle		_noSwap					;No swap needed if array[i] <= array[j]
	
	push	ESI
	call	exchangeElements		
	mov		[ESI], EBX				
	mov		[ESI + 4], EDX			;Allows us to swap the two numbers we are currently comparing

_noSwap:
	add		ESI, TYPE someArray		;Move to the next element in the array to compare for sorting
	dec		EAX
	jnz		_innerLoop

	jmp		_outerLoop
	
_endSort:
	mov		ESI, EDI				;Set ESI to the start of the sorted array temporarily held at EDI
	mov		EDI, OFFSET sortedArray	;Set EDI to address of the start of sortedArray **Module 6.3
	mov		ECX, ARRAY_SIZE			;Repopulate ECX with ARRAY_SIZE to loop through and print out values to new array

_copyLoop:
    mov		EAX, [ESI]				;Move value from temp sortArray to EAX
    mov		[EDI], EAX				;Move EAX to the destination array
    add		ESI, TYPE someArray		
    add		EDI, TYPE someArray		;Increment both ESI and EDI to the next "slot"
    loop	_copyLoop			

	pop		EDX
	pop		ESI
	pop		ECX
	pop		EDI
	pop		EAX
	pop		EBP

	ret		4

sortList	ENDP


; ***************************************************************
; Exchanges two elements for the sort mechanism
; receives: Address of current position in the array
; returns: The two values in swapped positions
; preconditions: The next value in the array is less than the current value
; postconditions: The next value becomes the current and the current becomes the next
; registers changed: EBP, ESI, EDX, EBX
; ***************************************************************
exchangeElements	PROC
	push	EBP
	mov		EBP, ESP

	mov		ESI, [EBP + 8]

	mov		EDX, [ESI]

	mov		EBX, [ESI + 4]			;Swapped numbers

	pop		EBP
	ret		4

exchangeElements	ENDP


; ***************************************************************
; Displays the median of the array
; receives: median title string address and sortedArray address
; returns: the median
; preconditions: the random array is sorted in increasing order
; postconditions: we return the current median value
; registers changed: EBP, EAX, EDX, EBX
; ***************************************************************
displayMedian	PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	EDX
	push	EBX

	mov		EDX, [EBP + 12]				
	call	WriteString										;Writes array title
	mov		EBX, [EBP + 8]
	mov		EAX, ARRAY_SIZE
	xor		EDX, EDX
	mov		ECX, 2
	div		ECX
	cmp		EDX, 0
	jne		_odd
	jmp		_even

_odd:
	mov		EAX, [EBX + EAX * TYPE sortedArray]				;Outputs the middle element since there is an odd total											
	jmp		_done

_even:
	dec		EAX												;Decrement to get to the first value "sandwiching" the median
	mov		EDX, [EBX + EAX * TYPE sortedArray + 4]			
	mov		EAX, [EBX + EAX * TYPE sortedArray]				
	add		EAX, EDX										;Add the values sandwiching the median and then find their average
	xor		EDX, EDX
	div		ECX	
	cmp		EDX, 0
	jne		_roundup
	jmp		_done

_roundup:
	inc		EAX												;Increment since every decimal median will be rounded up

_done:
	call	WriteDec
	call	CrLf

	pop		EBX
	pop		EDX
	pop		EAX
	pop		EBP

	ret		8

displayMedian	ENDP


; ***************************************************************
; Displays an array of numbers
; receives: size of the array, address of the array, title of the array,
;			and the numbers per line to be printed
; returns: None (prints the array)
; preconditions: an array with an address, size, and numbers per line
; postconditions: array prints as desired
; registers changed: EBP, EAX, ECX, EDX, ESI
; ***************************************************************
displayList		PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	ECX
	push	EDX

	mov		EDX, [EBP + 12]				
	call	WriteString					;Writes array title
	mov		EDX, [EBP + 16]
	mov		ECX, [EBP + 8]

_displayLoop:
	cmp	    EDX, 0
	je		_endLoop
	mov		EAX, [ESI]
	call	WriteDec
	mov		AL, " "
	call	WriteChar
	add		ESI, TYPE someArray
	dec		EDX
	loop	_displayLoop	

_newLine:
	call	CrLf
	mov		ECX, numPerLine
	jmp		_displayLoop

_endLoop:
	call	CrLf

	pop		EDX
	pop		ECX
	pop		EAX
	pop		EBP

	ret		12

displayList		ENDP


; ***************************************************************
; Counts the number of times a number appears in the array
; receives: count array title, starting address of the sorted array, and
;			starting address of the count array
; returns: array of the number of instances of each number, smallest
;		   to largest
; preconditions: array is sorted
; postconditions: count array showcases correct amount for each number
; registers changed: EAX, EBX, ECX, EDX, EDI
; ***************************************************************
countList	PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	EBX
	push	ECX
	push	EDX

	mov		ECX, ARRAY_SIZE
	mov		EBX, [EBP + 12]							;sortedArray base
	mov		EDI, [EBP + 8]							;countArray base
	xor		EDX, EDX								;Count of number of appearances, initialize to 0
	mov		EAX, LO

_countLoop:
	push	EBX
	mov		EBX, [EBX]
	cmp		EAX, EBX
	jne		_resetCount
	inc		EDX
	jmp		_nextInt

_resetCount:
	cmp		EDX, 0
	je		_noVal
	jmp		_continue

_noVal:
	mov		EAX, [EBX]
	mov		[EDI], EDX
	add		EDI, TYPE countArray
	jmp		_nextInt

_continue:
	inc		EAX
	mov		[EDI], EDX
	mov		EDX, 1
	add		EDI, TYPE countArray

_nextInt:
	pop		EBX
	add		EBX, TYPE sortedArray
	loop	_countLoop
	mov		[EDI], EDX

	mov		EAX, HI
	inc		EAX
	sub		EAX, LO

	push	EAX
	push	[EBP + 16]
	push	numPerLine
	mov 	ESI, OFFSET countArray
	call	displayList			

	pop		EDX
	pop		ECX
	pop		EBX
	pop		EAX
	pop		EBP

	ret		12

countList	ENDP

; ***************************************************************
; Prints out farewell message.
; receives: farewell string
; returns: None
; preconditions: The rest of the program completed without issue
; postconditions: None
; registers changed: EBP, EDX
; ***************************************************************
farewell	PROC
	push	EBP
	mov		EBP, ESP
	mov		EDX, [EBP + 8]
	call	WriteString
	call	CrLf

	pop		EBP
	ret		4

farewell	ENDP

END main
