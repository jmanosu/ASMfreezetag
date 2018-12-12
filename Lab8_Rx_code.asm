;***********************************************************
;*
;*	Jared_Tence_and_Tyler_Farnham_Lab8_Rx_sourcecode.asm
;*
;*	Lab8 code
;*
;*	This is the RECEIVE file for Lab 8 of ECE 375
;*
;***********************************************************
;*
;*	 Author: Jared Tence and Tyler Farnham
;*	   Date: 3/11/2018
;*
;***********************************************************

.def mpr = r16						; Multipurpose register 
.def waitcnt = r17					; Wait Loop Counter
.def ilcnt = r18					; Inner Loop Counter
.def olcnt = r19					; Outer Loop Counter
.def frezcnt = r20 
.equ WTime = 100					; Time to wait in wait loop
.equ WskrR = 0						; Right Whisker Input Bit 
.equ WskrL = 1						; Left Whisker Input Bit 
.equ EngEnR = 4						; Right Engine Enable Bit 
.equ EngEnL = 7						; Left Engine Enable Bit 
.equ EngDirR = 5					; Right Engine Direction Bit
.equ EngDirL = 6					; Left Engine Direction Bit 
.equ MovFwd = (1<<EngDirR|1<<EngDirL) ; Move Forward Command 
.equ MovBck = $00					; Move Backward Command 
.equ TurnR = (1<<EngDirL)			; Turn Right Command 
.equ TurnL = (1<<EngDirR)			; Turn Left Command  
.equ Halt = (1<<EngEnR|1<<EngEnL)	; Halt Command
.equ ID = 0b11100111
.equ Frc = 0b11111000
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt

		; Set up interrupt vectors for any interrupts being used

		; This is just an example:
.org	$0002					; Analog Comparator IV
		rcall	HITRIGHT		; Call function to handle interrupt
		reti					; Return from interrupt

.org	$0004					; Analog Comparator IV
		rcall	HITLEFT		; Call function to handle interrupt
		reti					; Return from interrupt

.org	$003C
		rcall   USART_Receive 
		reti

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:							; The initialization routine
		; Initialize Stack Pointer
		ldi mpr, high(RAMEND)
		out SPH, mpr
		ldi mpr, low(RAMEND)
		out SPL, mpr
		; Initialize Port B for output
		ldi mpr, (1<<EngEnL)|(1<<EngEnR)|(1<<EngDirL)|(1<<EngDirR)
		out DDRB, mpr
		; Initialize Port D for input
		ldi mpr, (0<<WskrL)|(0<<WskrR)|(0<<2)|(1<<3)
		out DDRD, mpr
		ldi mpr, (1<<WskrL)|(1<<WskrR)|(0<<2)|(0<<3)
		out PORTD, mpr
		; Initialize external interrupts
			; Set the Interrupt Sense Control to falling edge 
		ldi mpr, 0b00001010
		sts EICRA,  mpr
		; Configure the External Interrupt Mask
		ldi mpr, 0b00000011
		out EIMSK, mpr
		;USART

		; Set baudrate at 2400
		ldi   mpr, high(416)    ; Load high byte of 0x0340
		sts   UBRR1H, mpr       ; UBRR0H in extended I/O space
		ldi   mpr, low(416)     ; Load low byte of 0x0340
		sts   UBRR1L, mpr       ;
		; Set frame format: 8 data, 2 stop bits, asynchronous
		ldi   mpr, (0<<UMSEL0 | 1<<USBS0 | 1<<UCSZ01 | 1<<UCSZ00)
		sts   UCSR1C, mpr       ; UCSR0C in extended I/O space
		; Enable both transmitter and receiver, and receive interrupt
		ldi   mpr, (1<<TXEN0 | 1<<RXEN0 | 1<<RXCIE0)
		sts   UCSR1B, mpr       ;    
		; Turn on interrupts

		ldi frezcnt, 0
			; NOTE: This must be the last thing to do in the INIT function
		sei
;***********************************************************
;*	Main Program
;***********************************************************
MAIN:							; The Main program
		rcall   USART_Receive		
		rjmp	MAIN			; Create an infinite while loop to signify the 
								; end of the program.

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
;	You will probably want several functions, one to handle the 
;	left whisker interrupt, one to handle the right whisker 
;	interrupt, and maybe a wait function
;------------------------------------------------------------

;-----------------------------------------------------------
; Func: Hitright
; Desc: Cut and paste this and fill in the info at the 
;		beginning of your functions
;-----------------------------------------------------------
HITRIGHT:							; Begin a function with a label
		; Save variable by pushing them to the stack
		push mpr
		push waitcnt
		in mpr, SREG
		push mpr
		in mpr, PORTB
		push mpr
		; Execute the function here
		ldi mpr, MovBck
		out PORTB, mpr
		ldi waitcnt, Wtime
		rcall Wait
		;turn left for a second
		ldi mpr, TurnL
		out PORTB, mpr
		ldi waitcnt, Wtime
		rcall Wait
		; Restore variable by popping them from the stack in reverse order
		pop mpr
		out PORTB, mpr
		pop mpr
		out SREG, mpr
		sbr mpr, (1<<WskrR)|(1<<WskrL) 
		out EIFR, mpr
		pop waitcnt
		pop mpr

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: Hitleft
; Desc: Cut and paste this and fill in the info at the 
;		beginning of your functions
;-----------------------------------------------------------
HITLEFT:							; Begin a function with a label
		; Save variable by pushing them to the stack
		push mpr
		push waitcnt
		in mpr, SREG
		push mpr
		in mpr, PORTB
		push mpr
		; Execute the function here
		ldi mpr, MovBck
		out PORTB, mpr
		ldi waitcnt, Wtime
		rcall Wait
		;turn left for a second
		ldi mpr, TurnR
		out PORTB, mpr
		ldi waitcnt, Wtime
		rcall Wait
		; Restore variable by popping them from the stack in reverse order
		pop mpr
		out PORTB, mpr
		pop mpr
		out SREG, mpr
		sbr mpr, (1<<WskrR)|(1<<WskrL) 
		out EIFR, mpr  
		pop waitcnt
		pop mpr

		ret					; End a function with RET

;-----------------------------------------------------------
; Func: Wait
; Desc: Cut and paste this and fill in the info at the 
;		beginning of your functions
;-----------------------------------------------------------
Wait:							; Begin a function with a label

	OLoop:
		ldi   olcnt, 224        ; (1) Load middle-loop count
	MLoop:
		ldi   ilcnt, 237        ; (1) Load inner-loop count
	ILoop:
		dec   ilcnt             ; (1) Decrement inner-loop count
		brne  Iloop             ; (2/1) Continue inner-loop
		dec   olcnt             ; (1) Decrement middle-loop count
		brne  Mloop             ; (2/1) Continue middle-loop
		dec   waitcnt           ; (1) Decrement outer-loop count
		brne  OLoop             ; (2/1) Continue outer-loop
	ret

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

USART_Receive:
		push  mpr               ; Save mpr
		lds    r17, UDR1         ; Get data from Receive Data Buffer
		
		brtc SKIP_MOVE

		CLT

		ldi   mpr, 0b10110000
		cp  mpr, r17
		brne SKIPMF
			rcall MOVE_FORWARD
		SKIPMF:

		ldi   r16, 0b10000000
		cp  r16, r17
		brne SKIPMB
			rcall MOVE_BACKWARD
		SKIPMB:

		ldi   r16, 0b10100000
		cp  r16, r17
		brne SKIPTR
			rcall TURN_RIGHT
		SKIPTR:

		ldi   r16, 0b10010000
		cp  r16, r17
		brne SKIPTL
			rcall TURN_LEFT
		SKIPTL:

		ldi   r16, 0b11001000
		cp  r16, r17
		brne SKIPH
			rcall RHALT
		SKIPH:

		ldi   mpr, 0b11111000 
		cp  mpr, r17
		brne SKIPFS
			rcall FREEZE_send
		SKIPFS:

		SKIP_MOVE:


		ldi   mpr, ID
		cp  mpr, r17
		brne SKIP1
		set
		SKIP1:

		ldi   mpr, 0b01010101
		cp  mpr, r17
		brne SKIPFR
			rcall FREEZE_recieve
		SKIPFR:

		
		pop   mpr               ; Restore mpr
	ret
;***********************************************************
;*	Stored Program Data
;***********************************************************
MOVE_FORWARD:
		push mpr
		ldi mpr, MovFwd
		out PORTB, mpr
	ret

MOVE_BACKWARD:
		push mpr
		ldi mpr, MovBck
		out PORTB, mpr
		pop mpr
	ret

TURN_RIGHT:
		push mpr
		ldi mpr, TurnR
		out PORTB, mpr
		pop mpr
	ret

TURN_LEFT:
		push mpr
		ldi mpr, TurnL
		out PORTB, mpr
		pop mpr
	ret

RHALT:
		push mpr
		ldi mpr, Halt
		out PORTB, mpr
		pop mpr
	ret

FREEZE_recieve:
		push mpr
		in mpr, PORTB
		push mpr
		
		rcall RHALT

		ldi waitcnt, 250
		rcall Wait
		ldi waitcnt, 250
		rcall Wait

		ldi mpr, 0b00000011
		out EIFR, mpr 
		
		inc frezcnt
		
		cpi frezcnt, 3
		;FLOOP:
		;breq FLOOP

		pop mpr	
		out PORTB, mpr
		pop mpr	
ret

FREEZE_send:
	WAIT1:
	lds mpr, UCSR1A
	sbrs mpr, UDRE1
	rjmp WAIT1

	ldi mpr, 0b01010101 
	sts UDR1, mpr

	CLEAR_TRANSMITION:
	lds mpr, UCSR1A
	sbrs mpr, TXC1
	rjmp CLEAR_TRANSMITION
	ldi mpr, (1<<TXC1)
	sts UCSR1A, mpr	
ret

;***********************************************************
;*	Additional Program Includes
;***********************************************************