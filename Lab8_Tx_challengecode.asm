;***********************************************************
;*
;*	Jared_Tence_and_Tyler_Farnham_Lab8_Tx_sourcecode.asm
;*
;*	Lab8 code
;*
;*	This is the transmitter file for Lab 8 of ECE 375
;*
;***********************************************************
;*
;*	 Author: Jared Tence and Tyler Farnham
;*	   Date: 3/11/2018
;*
;***********************************************************
.def	mpr = r16				; Multi-Purpose Register
.def	mpr2 = r17
.def	waitcnt = r18
.def	ilcnt = r19
.def	olcnt = r20
.equ	WTime = 100
.equ	EngEnR = 4				; Right Engine Enable Bit
.equ	EngEnL = 7				; Left Engine Enable Bit
.equ	EngDirR = 5				; Right Engine Direction Bit
.equ	EngDirL = 6				; Left Engine Direction Bit
; Use these action codes between the remote and robot
; MSB = 1 thus:
; control signals are shifted right by one and ORed with 0b10000000 = $80
.equ	MovFwd =  ($80|1<<(EngDirR-1)|1<<(EngDirL-1))	;0b10110000 Move Forward Action Code
.equ	MovBck =  ($80|$00)								;0b10000000 Move Backward Action Code
.equ	TurnR =   ($80|1<<(EngDirL-1))					;0b10100000 Turn Right Action Code
.equ	TurnL =   ($80|1<<(EngDirR-1))					;0b10010000 Turn Left Action Code
.equ	Halt =    ($80|1<<(EngEnR-1)|1<<(EngEnL-1))		;0b11001000 Halt Action Code
.equ	Frz =  0b11111000									;0b11111000
.equ	ID = 0b11100111
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt


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
		ldi mpr, $ff
		out DDRB, mpr
		; Initialize Port D for input
		ldi mpr, 0b00001000
		out DDRD, mpr
		ldi mpr, $ff
		out PORTD, mpr

		; Set baudrate at 2400
		ldi   mpr, high(416)    ; Load high byte of 0x0340
		sts   UBRR1H, mpr       ; UBRR0H in extended I/O space
		ldi   mpr, low(416)     ; Load low byte of 0x0340
		sts   UBRR1L, mpr       ;
		; Set frame format: 8 data, 2 stop bits, asynchronous
		ldi   mpr, (0<<UMSEL0 | 1<<USBS0 | 1<<UCSZ01 | 1<<UCSZ00)
		sts   UCSR1C, mpr       ; UCSR0C in extended I/O space
		; Enable both transmitter and receiver, and receive interrupt
		ldi   mpr, (1<<TXEN0)
		sts   UCSR1B, mpr       ;    
		; Turn on interrupts
			; NOTE: This must be the last thing to do in the INIT function
		sei
;***********************************************************
;*	Main Program
;***********************************************************
MAIN:							; The Main program
		in mpr, PIND
		
		sbrs mpr, 0
		rcall MOVE_FORWARD
		
		sbrs mpr, 1
		rcall MOVE_BACKWARD
	
		sbrs mpr, 4
		rcall TURN_RIGHT

		sbrs mpr, 5
		rcall TURN_LEFT
		
		sbrs mpr, 6
		rcall RHALT

		sbrs mpr, 7
		rcall FREEZE
		
		ldi waitcnt, 25
		rcall Wait
	rjmp MAIN


MOVE_FORWARD:

	push mpr2
	push mpr
	ldi mpr2, MovFwd
	rcall TRANSMIT
	pop mpr
	pop mpr2
	ret

MOVE_BACKWARD:
	push mpr2
	push mpr
	ldi mpr2, MovBck
	rcall TRANSMIT
	pop mpr
	pop mpr2
	ret

TURN_RIGHT:
	push mpr2
	push mpr
	ldi mpr2, TurnR
	rcall TRANSMIT
	pop mpr
	pop mpr2
	ret

TURN_LEFT:
	push mpr2
	push mpr
	ldi mpr2, TurnL
	rcall TRANSMIT
	pop mpr
	pop mpr2
	ret

RHALT:
	push mpr2
	push mpr
	ldi mpr2, Halt
	rcall TRANSMIT
	pop mpr
	pop mpr2
	ret

FREEZE:
	push mpr2
	push mpr
	ldi mpr2, FRZ
	rcall TRANSMIT
	pop mpr
	pop mpr2
	ret

TRANSMIT:
	WAIT1:
	lds mpr, UCSR1A
	sbrs mpr, UDRE1
	rjmp WAIT1

	ldi mpr, ID
	sts UDR1, mpr

	WAIT2:
	lds mpr, UCSR1A
	sbrs mpr, UDRE1
	rjmp WAIT2

	sts UDR1, mpr2
		
	rcall CLEAR_TRANSMITION

	ret

CLEAR_TRANSMITION:
	lds mpr, UCSR1A
	sbrs mpr, TXC1
	rjmp CLEAR_TRANSMITION
	ldi mpr, (1<<TXC1)
	sts UCSR1A, mpr
	ret

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