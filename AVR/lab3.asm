;  lab3.asm
;  Letros Konstantinos 8851
;  Manousaridis Ioannis 8855
;  Group 4 Team 13 
;  Lab3
;--------------------------------------------------------------------------------------------
; 
; check link: https://www.lucidchart.com/invitations/accept/b26fcd34-8e38-404d-9b2b-2ac42d36988c
; 
;--------------------------------------------------------------------------------------------

;--------------------------------
; washing machine with assembly
;--------------------------------

; Declarations:

.include "m16def.inc"

.def program = r20
.def interrupt = r22
.def helper = r17
.dseg
.cseg

rjmp Reset 

;--------------------------------------------------------------------------------------------
Reset: ;Reset configutation
       
	   ldi r16, 0b00000000
	   out DDRD, r16      ; portD  input

	   ldi r16, 0b11111111
	   out DDRB, r16      ; portB output
	   out PORTB , r16

	   clr program
;--------------------------------------------------------------------------------------------

InitStack: ;Initialize stack

	ldi r16, low(RAMEND)
	out spl, r16
	ldi r16, high(RAMEND)
	out sph, r16

;--------------------------------------------------------------------------------------------
start_sw6:  ;wait for sw6 

			in r21, pinD
			com r21
			sbrs r21,6
			rjmp start_sw6
			rjmp enter_code

;--------------------------------------------------------------------------------------------

enter_code:  ;code to determine the washing program 

			rcall delay_5s
			in program, pinD
			rcall delay_5s
			
			cpi program, 0xff
			breq enter_code; no program was entered
			brne wait_sw6

;--------------------------------------------------------------------------------------------
wait_sw6:	
			clr r21
			in r21, pinD
			com r21
			sbrs r21,6
			rjmp start_sw6
			rjmp check_sw1
			

;--------------------------------------------------------------------------------------------
check_sw1: ;wait 10 seconds for sw1

		 	rcall delay_5s
			in interrupt, pinD
			rcall delay_5s
			com interrupt
			sbrs interrupt,1
			rjmp overload
			rjmp check_pre_washing
;--------------------------------------------------------------------------------------------
; CORRECT check_sw1
;
; 40 ms * 250 = 10seconds
; 
;check_sw1:
;	ldi helper,250
;	check_sw1_helper:
;		
;		
;		in interrupt, pinD
;
;	    ldi  r18, 208  ; 40ms delay at 4.0 MHz
;    	ldi  r19, 202
;	L1:	dec  r19
;    	brne L1
;    	dec  r18
;    	brne L1
;    	nop
;		dec helper
;		brne check_sw1_helper
;		sbrs interrupt,1
;		rjmp overload
;		clr interrupt
;		rjmp check_prewashing
;
;
;--------------------------------------------------------------------------------------------

overload: ;the machine is overloaded

		rcall flash_led_1_for_1_second
		clr interrupt
		in interrupt, pinD
		com interrupt
		sbrs interrupt,1
		rjmp overload
		clr interrupt
		rjmp check_pre_washing

;--------------------------------------------------------------------------------------------
check_pre_washing: ;program  76543X01 .X=0 pre washing. X = 1 main program

	sbrs program,2
	rjmp pre_washing
	rjmp main_program

;--------------------------------------------------------------------------------------------
; 40 ms * 250 = 10seconds

pre_washing:

	ldi helper, 0b11111000
	out portB, helper

	ldi helper, 250
	
	pre_washing_helper:
			
			clr interrupt
			in interrupt, pinD

			ldi  r18, 208  ; 40ms delay at 4.0 MHz
	    	ldi  r19, 202
		L1:	dec  r19
    		brne L1
    		dec  r18
    		brne L1
    		nop
			
			dec helper		;  <------------o
							       ;|	
			com interrupt			       ;|	
			sbrs interrupt,0		       ;|	
			rcall open_door			       ;|
							       ;|
			sbrs interrupt, 7		       ;|
			rcall out_of_water		       ;|
					                       ;|
			brne pre_washing_helper          ;<-----o
			
			rjmp main_program

;--------------------------------------------------------------------------------------------

main_program:
		
		ldi helper, 0b11110100
		out portB, helper

		ldi helper, 0b11100111
		or helper, program

		com helper  ; now helper is like 000 PR1 PR2 000
			
		cpi helper, 0b00000000
		breq program_4s
		
		cpi helper, 0b00001000
		breq program_8s
		
		cpi helper, 0b00010000
		breq program_12s
		
		cpi helper, 0b00011000
		breq program_18s

;--------------------------------------------------------------------------------------------
; 100 * 20 = 2s
program_2s:

	ldi helper, 100
	
	program_2s_helper:
			
			clr interrupt
			in interrupt, pinD

			ldi  r18, 104  ; 20ms delay at 4.0 MHz
	    	ldi  r19, 229
		L2:	dec  r19
    		brne L2
    		dec  r18
    		brne L2
    		nop
			
			dec helper		; <------------o
										  ;|	
			com interrupt				  ;|	
			sbrs interrupt,0			  ;|	
			rcall open_door				  ;|
										  ;|
			sbrs interrupt, 7			  ;|
			rcall out_of_water			  ;|
										  ;|
			brne program_2s_helper ;<-----o
			
			ret


;--------------------------------------------------------------------------------------------
program_4s: ;2*2=4

		rcall program_2s
		rcall program_2s

		rjmp clothes_out
;--------------------------------------------------------------------------------------------

program_8s: ;2*4=8

		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		
		rjmp clothes_out
;--------------------------------------------------------------------------------------------

program_12s: ;and it goes on like this

		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		
		
		rjmp clothes_out

;--------------------------------------------------------------------------------------------

program_18s:

		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		rcall program_2s
		
		rjmp clothes_out
		
;--------------------------------------------------------------------------------------------
clothes_out:
		ldi helper, 0b11101111
		out portB, helper
		rcall delay_1s

		rjmp check_pr2

;--------------------------------------------------------------------------------------------
check_pr2: ;program  76X4321 .X=0 dry_clothes. X = 1 finish
		
		sbrs program,5 ;
		rjmp dry_clothes
		rjmp finish

;--------------------------------------------------------------------------------------------
dry_clothes:

	ldi helper, 0b11011111
	out portB, helper
	
	rcall delay_1s
	rcall delay_1s
	
	rjmp finish

;--------------------------------------------------------------------------------------------
;   METHODS
;--------------------------------------------------------------------------------------------
delay_1s:
	ret


delay_5s:	;5 seconds delay
		
		rcall delay_1s
		rcall delay_1s
		rcall delay_1s
		rcall delay_1s
		rcall delay_1s

		ret


flash_led_1_for_1_second:  ;turn on led1. wait 1 second. turn off wait 1 second, then return
		ret
		
open_door:
  		ret

out_of_water:
		ret



finish:
	ldi helper, 0b01111111
	out portB, helper
	nop
		
