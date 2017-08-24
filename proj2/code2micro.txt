.include "m16def.inc"	
.org 0
.cseg


.def digit0=r17
.def digit1=r18
.def digit2=r19
.def digit3=r20
.def counter=r28
.def flag0=r22
.def flag1=r23
.def flag2=r24
.def flag3=r25
.def flag_alarm=r31
.def delay_counter=r26

sp_init:
	ldi r16,low(RAMEND)				;stack pointer initialization
	out spl,r16
	ldi r16,high(RAMEND)
	out sph,r16
	ldi counter,1                   ; to xrhsimopoioume san deikth 8eshs pshfiou

switch_init:
	clr r16
	out DDRD,r16
	ser r16				;initialization of switches
	out PIND,r16
led_init:
	ser r16				;initiallize
	out DDRB,r16
	ser r16
	out PORTB,r16



rjmp initPassword

initPassword:
	sbis PIND,0x00			;if(Port D,pin0=0) then dont execute next command
	rcall sw0_pressed		;calls the sw0_pressed function
	
	sbis PIND,0x01			;if(Port D,pin0=0) then dont execute next command
	rcall sw1_pressed		;calls the sw0_pressed function

	sbis PIND,0x02
	rcall sw2_pressed
	
	sbis PIND,0x03
	rcall sw3_pressed



	sbrc flag0,0
	rcall sw0_unpressed
	sbrc flag1,0
	rcall sw1_unpressed
	sbrc flag2,0
	rcall sw2_unpressed
	sbrc flag3,0
	rcall sw3_unpressed

	sbis PIND,0x07
	rjmp sw7_pressed

	rjmp initPassword

sw0_pressed:
	sbrs flag0,0
	mov digit0,counter
	sbrs flag0,0
	adiw counter,1
	ldi flag0,1
	ret	




sw1_pressed:
	sbrs flag1,0
	mov digit1,counter
	sbrs flag1,0
	adiw counter,1
	ldi flag1,1
	ret	




sw2_pressed:
	sbrs flag2,0
	mov digit2,counter
	sbrs flag2,0
	adiw counter,1
	ldi flag2,1
	ret	





sw3_pressed:
	sbrs flag3,0
	mov digit3,counter
	sbrs flag3,0
	adiw counter,1
	ldi flag3,1
	ret	


	
sw0_unpressed:
	sbic PIND,0x00
	rjmp reset
	ret

sw1_unpressed:
	sbic PIND,0x01
	rjmp reset
	ret

sw2_unpressed:
	sbic PIND,0x02
	rjmp reset
	ret

sw3_unpressed:
	sbic PIND,0x03
	rjmp reset
	ret


reset:
	ldi counter,1
	ldi flag0,0
	ldi flag1,0
	ldi flag2,0
	ldi flag3,0
	ldi digit0,0
	ldi digit1,0
	ldi digit2,0
	ldi digit3,0
	ser r16				;initialization of switches
	out PIND,r16
	rjmp initPassword

reset2: 
	ldi counter,1
	ldi flag0,0
	ldi flag1,0
	ldi flag2,0
	ldi flag3,0

    ldi flag_alarm,0
    ldi delay_counter,1
	ret


sw7_pressed:
	cpi counter,1
	breq reset
	
	sbis PIND,0x07
	rjmp sw7_pressed
	clr r16
	out DDRD,r16
	ser r16				;initialization of switches
	out PIND,r16

loop_sw0:
	sbic PIND,0x00
	rjmp loop_sw0
	ldi r16,1
	com r16
	out PORTB,r16
	clr r16
	out DDRD,r16
	ser r16				;initialization of switches
	out PIND,r16
	rcall reset2



		
	
password_check:
	sbis PIND,0x00
	rcall check_sw0
	
	sbis PIND,0x01
	rcall check_sw1
	
	sbis PIND,0x02
	rcall check_sw2

	sbis PIND,0x03
	rcall check_sw3

	
	
	clr r4
	cpse flag_alarm,r4
	call  bdelay      ;delay025s
	
	
	cpi delay_counter,21
	breq identify
	
	

	
	rjmp password_check

	
	



check_sw0:
	sbis PIND,0x00
	rjmp check_sw0
	ldi flag_alarm,1
	mov flag0,counter
	adiw counter,1
	ret
	



	
;select_sw0:	
	;mov flag0,counter
	;adiw counter,1
	
	;ret


check_sw1:
	sbis PIND,0x01
	rjmp check_sw1
	ldi flag_alarm,1
	mov flag1,counter
	adiw counter,1
	ret
	



	
;select_sw1:	
	;mov flag1,counter
	;adiw counter,1
	
	;ret

check_sw2:
	sbis PIND,0x02
	rjmp check_sw2
	ldi flag_alarm,1
	mov flag2,counter
	adiw counter,1
	ret
	



	
;select_sw2:	
	;mov flag2,counter
	;adiw counter,1
	
	;ret

check_sw3:
	sbis PIND,0x03
	rjmp check_sw3
	ldi flag_alarm,1
	mov flag3,counter
	adiw counter,1
	ret
	



	
;select_sw3:	
	;mov flag3,counter
	;adiw counter,1
	
	;ret




identify:
	rcall check
	rcall reset2
	rcall alarm1



check:
	cpse digit0,flag0
	ret
	cpse digit1,flag1
	ret
	cpse digit2,flag2
	ret
	cpse digit3,flag3
	ret
	
	ser r16
	ldi r16,2
	com r16
	out PORTB,r16

	rcall normal_operation



;alarm:
	;ldi delay_counter,1
	;adiw fail_flag,1

	;cpi fail_flag,1
	;breq alarm1
	;cpi fail_flag,2
	;breq alarm2



normal_operation:
	
	sbis PIND,0x02
	rcall lightled2
	sbis PIND,0x03
	rcall lightled3
	sbis PIND,0x04
	rcall lightled4
	sbis PIND,0x05
	rcall lightled5
	sbis PIND,0x06
	rcall lightled6
	sbis PIND,0x07
	rcall lightled7
	sbis PIND,0x01
	rcall loop_sw0

	rjmp normal_operation
	
lightled2:
	ser r16
	ldi r16,4
	com r16
	out PORTB,r16
	rjmp lightled2

lightled3:
	ser r16
	ldi r16,12
	com r16
	out PORTB,r16
	rjmp lightled3

lightled4:
	ser r16
	ldi r16,20
	com r16
	out PORTB,r16
	rjmp lightled4

lightled5:
	ser r16
	ldi r16,36
	com r16
	out PORTB,r16
	rjmp lightled5

lightled6:
	ser r16
	ldi r16,68
	com r16
	out PORTB,r16
	rjmp lightled6

lightled7:
	ser r16
	ldi r16,132
	com r16
	out PORTB,r16
	rjmp lightled7






alarm1:
	mov r5,delay_counter
	lsr r5
	lsl r5
	rcall offled
	cpse delay_counter,r5
	rcall onled			 ;ama einai monos anabei ta led
	                     ; ama einai zhgos sbhsta ta led


	sbis PIND,0x00
	rcall check_sw0

	sbis PIND,0x01
	rcall check_sw1
	
	sbis PIND,0x02
	rcall check_sw2

	sbis PIND,0x03
	rcall check_sw3

	
	clr r4
	cpse flag_alarm,r4
	rcall bdelay
	
	cpi delay_counter,11
	breq identify2

	

	
	rjmp alarm1

offled:
	ser r16
	out PORTB,r16
	ret


onled:	
	ser r16
	ldi r16,1
	com r16
	out PORTB,r16
	ret


identify2:
	rcall check
	rcall alarm2



alarm2:
 	
	ser r16
	out PORTB,r16
	rcall bdelay;delay05s
	clr r16
	out PORTB,r16
	rcall bdelay;delay05s
	rjmp alarm2
	
		

	







bdelay:
	adiw delay_counter,1
	ret
delay025s:

    ldi  r21, 6
    ldi  r27, 19
    ldi  r29, 174
L1: dec  r29
    brne L1
    dec  r27
    brne L1
    dec  r21
    brne L1
	adiw delay_counter,1
    ret

delay05s:

    ldi  r21, 11
    ldi  r27, 38
    ldi  r29, 94
L2: dec  r29
    brne L2
    dec  r27
    brne L2
    dec  r21
    brne L2
	adiw delay_counter,1
	ret
