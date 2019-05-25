;  Manousaridis Ioannis 8855
;  Letros Konstantinos 8851 
;  Lab exercise - Traffic Lights
;----------------------------------------------------------------------------------------------------


;----------------------------------------------------------------------------------------------------
; Declarations:

.include "m16def.inc"

.def timeCounter = r20
.def buttonPressed = r21
.def phaseReg = r22
.dseg
.cseg
.org 0x00
rjmp Reset
.org 0x010
jmp Timer1Interrupt
;----------------------------------------------------------------------------------------------------
Reset:
  ldi r16, 0b00000000
	out DDRB, r16       ; PortB Input
	out DDRD, r16		; PortD Input

	ldi r16, 0b11111111
	out DDRC, r16		; PortC Output
	
	ldi r16, 0b11110000
	out DDRA, r16		; PortA: Output/Input
	ldi r16, 0b00001111
	out PORTA, r16		; initialize pull-up resistors
;----------------------------------------------------------------------------------------------------
InitStack:
	ldi r16, low(RAMEND)
	out spl, r16
	ldi r16, high(RAMEND)
	out sph, r16
;----------------------------------------------------------------------------------------------------
;Initialize Timer 1           ; 3906 cycles * 256 us/cycles = 1 seconds

	ldi r16,0xF0			  ; Initialize Timer 1 from value 65535-3906=61629
	out TCNT1H,r16			  ; Overflow every 1 second
	ldi r16,0xBD
	out TCNT1L,r16	
	
	ldi r16,1<<TOIE1          ; Enable Timer 1 Overflow Interrupt 
	out TIMSK,r16

	ldi r16, 0b00000101       ; Clock Prescaler (1024): 4000000/1024 = 256usec/cycle
	out TCCR1B,r16
  
	sei						  ; Enable Global Interrupts
;----------------------------------------------------------------------------------------------------
; Green=10, Yellow=01, Red=00, Disabled=11

; PORTA 0 = Pedestrians A
; PORTA 1 = Pedestrians B
; PORTA 2 = Turn C1
; PORTA 3 = Turn F1

; PORTD 2,1,0 = Flow1
; PORTB 2,1,0 = Flow2
; PORTB 5,4,3 = Flow3

; PORTA 7,6 = Cars C
; PORTA 5,4 = Cars F

; PORTC 7,6 = Cars E
; PORTC 5,4 = Cars B
; PORTC 3,2 = Cars D
; PORTC 1,0 = Cars A

main:	
;----------------------------------------------------------------------------------------------------
; Main Phases

; 1) Phase-1 Cars B,E and Pedestrians A = Green 
Phase1:
	
	ldi phaseReg, 0b00000010 	  ; Next Phase must be Phase2
	push phaseReg				  ; Save Next Phase to Stack
	
	; Green 1
	ldi r16, 0b10100000       	  ; PORTC traffic lights E, B = Green, D,A = Red
	out PORTC,r16
	ldi r16, 0b00001111  	  	  ; PORTA Pedestrians A = Green, C,F,Pedestrians B = Red
	out PORTA,r16
	ldi timeCounter,15		   	  ; Count 15 seconds
	rcall initTimer			  	  ; Initialize timer for 1 second duration
wasteCPUtime1sec1:
 	in r16, PINA				  ; check if a button was pressed
	com r16
  	or buttonPressed, r16			
	cpi timeCounter, 0
	brne wasteCPUtime1sec1 
	
	call checkButton			 ; check if a button was pressed and add the appropiate phase as the next one into the stack
   
	pop phaseReg			  	 ; Restore Next Phase from Stack
	
	; Yellow 1				  	 ; Depending on the Next Phase, call the corresponding yellow1 routine
	cpi phaseReg,0b00000010	
	breq yellow1_2
	cpi phaseReg,0b00000011
	breq yellow1_3
	jmp yellow1_4

;-------------------
; Yellow 1 Routines
;-------------------

yellow1_2:
; Yellow Phase1 -> Phase2
	ldi r16, 0b01010000  	  ; PORTC traffic lights B,E = Yellow, A,D = Red
	out PORTC,r16
	ldi r16, 0b00001111  	  ; PORTA C,F,Pedestrians A,B = Red
	out PORTA,r16
	ldi timeCounter,3		  ; Count 3 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec2:
	in r16, PINA			 ; check if a button was pressed
  	com r16
	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec2
	
	call checkButton			; check if a button was pressed and add the appropiate phase as the next one into the stack
   
  
  jmp nextPhase			  ; Go to Next Phase

yellow1_3:
	; Yellow Phase1 -> Phase3
	ldi r16, 0b01000000  	  ; PORTC traffic lights E = Yellow, A,B,D = Red
	out PORTC,r16
	ldi r16, 0b00001111  	  ; PORTA C,F,Pedestrians A,B = Red
	out PORTA,r16
	ldi timeCounter,3		  ; Count 3 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec3:
  	in r16, PINA			 ; check if a button was pressed
  	com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec3 
	
  call checkButton			; check if a button was pressed and add the appropiate phase as the next one into the stack
   
  
  jmp nextPhase			  ; Go to Next Phase

yellow1_4:
	; Yellow Phase1 -> Phase4
	ldi r16, 0b00010000  	  ; PORTC traffic lights B = Yellow, A,D,E = Red
	out PORTC,r16
	ldi r16, 0b00001111  	  ; PORTA C,F,Pedestrians A,B = Red
	out PORTA,r16
	ldi timeCounter,3		  ; Count 3 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec4:
  	in r16, PINA
  	com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec4 
	
  call checkButton			; check if a button was pressed and add the appropiate phase as the next one into the stack
  
  jmp nextPhase			  ; Go to Next Phase
		
; 2) Cars A,D and Pedestrians B - Green + Yellow Routines
Phase2:
	
	ldi phaseReg, 0b00000001  ; Next Phase must be Phase1
	push phaseReg			  ; Save Next Phase to Stack

	; Green 2
	ldi r16, 0b00001010  ; PORTC traffic lights A,D = Green, B,E = Red
	out PORTC,r16
	ldi r16, 0b00001111  ; PORTA Pedestrians B = Green, C,F,Pedestrians A = Red
	out PORTA,r16
	ldi timeCounter,10		  ; Count 10 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec5:
  	in r16, PINA
  	com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec5 

  call checkButton			  ; check if a button was pressed and add the appropiate phase as the next one into the stack
  
	pop phaseReg			  ; Restore Next Phase from Stack
		
	; Yellow 2				  ; No matter what the next Phase is - A,D must be Yellow (one routine)
	ldi r16, 0b00000101 	  ; PORTC traffic lights A,D = Yellow, B,E = Red
	out PORTC,r16
	ldi r16, 0b00001111  	  ; PORTA C,F,Pedestrians A,B = Red
	out PORTA,r16
	ldi timeCounter,3		  ; Count 3 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec6:
  	in r16, PINA
  	com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec6 
	
  call checkButton			; check if a button was pressed and add the appropiate phase as the next one into the stack
   
  
  jmp nextPhase			  ; Go to Next Phase

;----------------------------------------------------------------------------------------------------
; Turn Phases - Button Pushed (Interrupts)

; 3) Cars B,C and Pedestrians A - Green + Yellow Routines
Phase3:

	; Green 3
	ldi r16, 0b00100000  ; PORTC traffic lights B = Green, A,E,D = Red
	out PORTC,r16
	ldi r16, 0b10001111  ; PORTA traffic lights C, Pedestrians A = Green, F,Pedestrians B = Red
	out PORTA,r16
	ldi timeCounter,5		  ; Count 5 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec7:
  	in r16, PINA
  	com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec7 

	call checkButton			; check if a button was pressed and add the appropiate phase as the next one into the stack
   
  
	pop phaseReg			  ; Restore Next Phase from Stack
	
	; Yellow 3				  ; Depending on the Next Phase, call the corresponding yellow3 routine
	cpi phaseReg,0b00000001		  
	breq yellow3_1
	cpi phaseReg,0b00001111
	breq goTo_no_yellow
	jmp yellow3_24

goTo_no_yellow:
	jmp no_yellow	
;-------------------
; Yellow 3 Routines
;-------------------

	yellow3_1:
	; Yellow Phase3 -> Phase1
	;ldi r16, 0b00100000  	  ; PORTC traffic lights B = Green, A,D,E = Red
	;out PORTC,r16
	ldi r16, 0b01001111  	  ; PORTA C = Yellow, F,Pedestrians A,B = Red
	out PORTA,r16
	ldi timeCounter,3		  ; Count 3 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec8:
	in r16, PINA
  	com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec8 

  call checkButton  
  
	jmp nextPhase			  ; Go to Next Phase

yellow3_24:
	; Yellow Phase3 -> (Phase2 or Phase4)
	ldi r16, 0b01000000  	  ; PORTC traffic lights B = Yellow, A,D,E = Red
	out PORTC,r16
	ldi r16, 0b01001111  	  ; PORTA C = Yellow, F,Pedestrians A,B = Red
	out PORTA,r16
	ldi timeCounter,3		  ; Count 3 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec9:
  	in r16, PINA
  	com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec9 
	
   call checkButton
  
  jmp nextPhase			  ; Go to Next Phase
	
; 4) Cars E,F - Green + Yellow Routines
Phase4:

	; Green 4
	ldi r16, 0b10000000  	  ; PORTC traffic lights E = Green, A,B,D = Red
	out PORTC,r16
	ldi r16, 0b00101111  	  ; PORTA traffic lights F = Green, C, Pedestrians A,B = Red
	out PORTA,r16
	ldi timeCounter,5		  ; Count 5 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec10:
  	in r16, PINA
  	com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec10 

  call checkButton
  	
	pop phaseReg			  ; Restore Next Phase from Stack
	
	; Yellow 4				  ; Depending on the Next Phase, call the corresponding yellow4 routine
	cpi phaseReg,0b00000001		  
	breq yellow4_1
	cpi phaseReg,0b00000100
	breq no_yellow	
	jmp yellow4_23
	
;-------------------
; Yellow 4 Routines
;-------------------

yellow4_1:
; Yellow Phase4 -> Phase1
	;ldi r16, 0b10000000  	  ; PORTC traffic lights E = Green, A,B,D = Red
	;out PORTC,r16
	ldi r16, 0b00010000  	  ; PORTA F = Yellow, C,Pedestrians A,B = Red
	out PORTA,r16
	ldi timeCounter,3		  ; Count 3 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec11:
  in r16, PINA
  com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec11 
	
  call checkButton
  
  jmp nextPhase
	
yellow4_23:
; Yellow Phase4 -> (Phase2 or Phase3)
	ldi r16, 0b01000000  	  ; PORTC traffic lights E = Yellow, A,B,D = Red
	out PORTC,r16
	ldi r16, 0b00011111  	  ; PORTA F = Yellow, C,Pedestrians A,B = Red
	out PORTA,r16
	ldi timeCounter,3		  ; Count 3 seconds
	rcall initTimer			  ; Initialize timer for 1 second duration
wasteCPUtime1sec12:
  in r16, PINA
  com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
  brne wasteCPUtime1sec12 
  
  call checkButton
  
	jmp nextPhase
	
no_yellow:
	ldi timeCounter,3		  ; Count 3 seconds
	rcall initTimer	  		  ; Initialize timer for 1 second duration
wasteCPUtime1sec13:
	in r16, PINA
	com r16
  	or buttonPressed, r16
	cpi timeCounter, 0
	brne wasteCPUtime1sec13 
	
  call checkButton
  
  jmp nextPhase
	
;----------------------------------------------------------------------------------------------------
; Routines

initTimer:
	ldi r24,0xF0			  ; Re-Initialize Timer 1 (HIGH)
	out TCNT1H,r24			  ; Overflow every 1 second (HIGH)
	ldi r24,0xBD			  ; Re-Initialize Timer 1 (LOW)
	out TCNT1L,r24			  ; Overflow every 1 second (LOW)
	ret

nextPhase:					 			  ; Find next Phase
	cpi phaseReg,0b00000001	  ; Check if Phase1 next
	breq goToPhase1
	cpi phaseReg,0b00000010	  ; Check if Phase2 is next
	breq goToPhase2
	cpi phaseReg,0b00000011	  ; Check if Phase3 is next
	breq goToPhase3
	rjmp goToPhase4				    ; If none of the above, then Phase4 is next

goToPhase1:
	jmp Phase1
	
goToPhase2:
	jmp Phase2
	
goToPhase3:
	jmp Phase3

goToPhase4:
	jmp Phase4

;----------------------------------------------------------------------------------------------------
checkButton: 				;check if a button was pressed and add the appropiate next phase into the stack

	pop xh pop xl
  
  ldi r18, 0b00000001  		; if pushed go to Phase1
	sbrc buttonPressed, 0	  ; Check if any of A1,A2 buttons are pushed 
	push r18			 				  ; Next Phase = Phase 1
	
  ldi r18, 0b00000010		 ; if pushed go to Phase2
	sbrc buttonPressed, 1	 ; Check if any of B1,B2 buttons are pushed 
	push r18			 				 ; Next Phase = Phase 2

	ldi r18, 0b00000011	 		; if pushed go to Phase3
	sbrc buttonPressed, 2	 	; Check C1 button is pushed 
  push r18			 					; Next Phase = Phase 3
	
	ldi r18, 0b00000100	 		; if pushed go to Phase4
	sbrc buttonPressed, 3		; Check if F1 button is pushed 
	push r18			 					; Next Phase = Phase 4

	push xl push xh
  clr buttonPressed
  ret

;----------------------------------------------------------------------------------------------------
Timer1Interrupt:
	; Every 1 Second - Timer Overflow
	dec timeCounter
	ldi r24, 0xF0			  ; Re-Initialize Timer 1 
	out TCNT1H,r24			  ; Overflow every 1 second
	ldi r24, 0xBD
	out TCNT1L,r24	
	reti
