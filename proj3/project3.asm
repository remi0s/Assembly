.include "m16def.inc"	
.org 0
.cseg
.def programm=r18					;arxikopoihsh kataxwrhth pou tha krataei to epilegmeno programma plushs
.def proplysh=r19					;arxikopoihsh kataxwrhth pou tha krataei an tha ginetai proplysh h oxi
.def stragisma=r20					;arxikopoihsh kataxwrhth pou tha krataei an tha ginetai stragisma h oxi
.def delay_counter=r30				;kataxwrhths ston opoio apothikeuetai o arithmos twn epanalhpsewn pou apaitei to kathe programma plushs
.def alluse_counter = r24			;kataxwrhths pollaplwn xrhsewn gia na apothikeuetai o arithmos twn epanalhpsewn gia to stragisma kai gia thn proplush
sp_init:     
	ldi r16,low(RAMEND)            ;arxikopoihsh stack pointer
	out spl,r16
	ldi r16,high(RAMEND)
	out sph,r16
switch_init:
	clr r17
	out DDRD,r17
	ser r17				           ;arxikopoihsh switch
	out PIND,r17
led_init:
	ser r17				           ;arxikopoihsh led kai kataxwrhtwn
	out DDRB,r17
	ser r17
	out PORTB,r17
	ldi r17,0b10000000				;LED 7 = 1 (230V)
	com r17
	out PORTB,r17
	clr programm
	clr proplysh
	clr delay_counter
	clr r28
	clr r20
	clr alluse_counter
	

select_programm:						;elegxos epiloghs programmatos plushs
	sbis PIND,0x03
	ori programm,0b00000001
	sbis PIND,0x04
	ori programm,0b00000010
	sbis PIND,0x05
	ori programm,0b00000100
	
	sbis PIND,0x02						;elegxos epiloghs proplushs
	ldi proplysh,1
	
	sbis PIND,0x06						;elegxos gia ekkinhsh tou programmatos plushs
	rjmp define_programm

	rjmp select_programm

	
define_programm:
										;Elegxoume poio programma exei epilegei
	cpse programm,r28					;auxanontas ton kataxwrhth r28 kai sugkrinontas ton me to kataxwrhth programm
	brne jump0							;otan o r28 kai o programm ginoun isoi kataxwreitai ston delay counter h epithumhth kathusterhsh
	ldi delay_counter,8						
	ldi stragisma,1						; Sta prwta 4 o kataxwrhths stragisma tithetai 1 wste na ginei stragisma enw sta 4 teleytaia oxi
	jump0:
	adiw r28,1
	cpse programm,r28
	brne jump1
	ldi delay_counter,16
	ldi stragisma,1
	jump1:
	adiw r28,1
	cpse programm,r28
	brne jump2
	ldi delay_counter,32
	ldi stragisma,1
	jump2:
	adiw r28,1
	cpse programm,r28
	brne jump3
	ldi delay_counter,64
	ldi stragisma,1
	jump3:
	adiw r28,1



	cpse programm,r28
	brne jump4
	ldi delay_counter,8
	jump4:
	adiw r28,1
	cpse programm,r28
	brne jump5
	ldi delay_counter,12
	jump5:
	adiw r28,1
	cpse programm,r28
	brne jump6
	ldi delay_counter,32
	jump6:
	adiw r28,1
	cpse programm,r28
	brne jump7
	ldi delay_counter,64
	jump7:
	lsl delay_counter						;epeidh xrhsimopoioyme kathusterhsh 0.5 deuteroleptou
											;Led 0 = 1 (Porta kleisth)
	com r17									;Led 1 = 1 (Plunthrio se leitourgia)
	ori r17,0b00000011
	com r17	

	ldi r28,0

	cpi proplysh,1							;elegxoume ama exei epilegei h leitourgia proplushs wste na metavei ekei to programma
	breq proplysh_led						;alliws metavainei kateuthian sthn kuria plush

	rjmp change


proplysh_led:					
	com r17
	ori r17,0b00000100						;LED 3 = 1 (leitourgia proplushs)
	com r17
	out PORTB,r17




proplysh_wash:
	sbis PIND,0x00							;Ama patithei to 0 anoigei h porta anastelletai h leitourgia
	rcall door_led_off_on
	sbis PIND,0x00
	rjmp proplysh_wash


	sbis PIND,0x07							;Ama patithei to 7 stamataei h paroxh nerou kai anastelletai h leitourgia
	rcall water_stop
	

	mov r22,alluse_counter					;Metaferoume ton alluse_counter ston r22 gia na mhn metavlithei h timh tou
	sbis PIND,0x01							;Ama patithei to 1 prosïmoiwnetai h uperfortwsh tou plunthriou
	rcall overloaded						

	rcall delay05s							;Kaloume thn kathusterhsh 0.5 deuteroleptou
	adiw alluse_counter,1
	
	cpi alluse_counter,8					;Olh h diadikasia epanalamvanetai gia 8*0.5 = 4 deuterolepta
	breq change								;molis oloklhrwthei h diadikasia metavainei sthn kuria plush

	rjmp proplysh_wash

door_led_off_on:							;leitourgia anavosvhshs tou led
	com r17
	andi r17,0b11111110						;Svhsimo tou led 0
	com r17
	out PORTB,r17

	rcall delay05s							;kathusterhsh 0.5 deuteroleptou
	
	com r17
	ori r17,0b00000001						;Anama tou led 0
	com r17
	out PORTB,r17


	ret

water_stop:									;leitourgia diakophs paroxhs nerou
	com r17
	ori r17,0b01000000						;Anama tou led 6
	com r17
	out PORTB,r17
	
	water_stop_on_off:						;leitourgia anasvhshs tou led 1 pou apaiteitai se periptwsh diakophs paroxhs nerou
		com r17
		ori r17,0b00000010					;Anama tou led 1
		com r17
		out PORTB,r17
	
		rcall delay05s
			
		com r17
		andi r17,0b11111101					;Svhsimo tou led 1
		com r17
		out PORTB,r17

		sbis PIND,0x07						;Elegxetai ama exei afethei to switch 7 wste na sunexisei h leitourgia tou programmatos
		rjmp water_stop_on_off
	
	ret


change:										;Diadikasia metavashs sthn kuria plush
	com r17
	andi r17,0b11111011						;Svhsimo tou led proplushs
	ori r17,0b00001000						;Anama tou led kuria plushs(LED3)
	com r17
	out PORTB,r17

wash:										;Leitourgia kurias plushs
	sbis PIND,0x00							;Ama patithei to 0 anoigei h porta anastelletai h leitourgia
	rcall door_led_off_on
	sbis PIND,0x00
	rjmp wash

	sbis PIND,0x07							;Ama patithei to 7 stamataei h paroxh nerou kai anastelletai h leitourgia
	rcall water_stop

	mov r22,delay_counter					;Metaferoume ton delay_counter ston r22 gia na mhn metavlithei h timh tou
	sbis PIND,0x01							;Ama patithei to 1 prosïmoiwnetai h uperfortwsh tou plunthriou
	rcall overloaded
	
	rcall delay05s							;Kaloume thn kathusterhsh 0.5 deuteroleptou
	subi delay_counter,1					;kai meiwnoume to delay_counter kata 1 mexri na ftasei sto mhden
											;dhladh mexri na oloklirwthei h kathusterhsh
	cpi delay_counter,0						;Elegxoume ama exei mhdenistei to delay_counter
	breq change2							;An nai metavainoume sthn diadikasia xevgalmatos

	rjmp wash


overloaded:									;Diadikasia uperfortwshs tou plunthriou
	mov r28,r22								;Metaferoume ton r22 ston r28
	lsr r28									;Kanoume shift kata mia thesi dexia kai kata mia thesi aristera
	lsl r28									;Auto mas epitrepei na sugkrinoume sthn sunexeia tous kataxwrhtes


	cpse r22,r28							;Elegxoume ama meta tis metakinhseis oi kataxwrhtes einai isoi
	rjmp avoid0								;An den einai parakamptei tis entoles mexri to label avoid0
	com r17									;Auto ginetai epeidh thelei na anavosvhnei to led 1
	ori r17,0b00000010						;Anama tou led 1
	com r17
	out PORTB,r17
	rjmp avoid1								;efoson den einai isoi parakamptei tis entoles mexri to label avoid1
	

	avoid0:
	com r17
	andi r17,0b11111101						;Svhsimo tou led 1
	com r17
	out PORTB,r17
	avoid1:

	ret


change2:									;Leirougia metavashs sto ksavgalma
	com r17
	andi r17,0b11110111						;Svhsimo tou Led 3 (Kurias plushs)
	ori r17, 0b00010000						;Anama tou Led 4 (Xevgalma)
	com r17
	out PORTB,r17
	ldi alluse_counter,0					
	rjmp ksebgalma

ksebgalma:
	sbis PIND,0x00							;Ama patithei to 0 anoigei h porta anastelletai h leitourgia
	rcall door_led_off_on
	sbis PIND,0x00
	rjmp ksebgalma

	sbis PIND,0x07							;Ama patithei to 7 stamataei h paroxh nerou kai anastelletai h leitourgia
	rcall water_stop
	
	mov r22,alluse_counter					;Metaferoume ton alluse_counter ston r22 gia na mhn metavlithei h timh tou
	sbis PIND,0x01							;Ama patithei to 1 prosïmoiwnetai h uperfortwsh tou plunthriou
	rcall overloaded

	rcall delay05s								
	adiw alluse_counter,1
	
	cpi alluse_counter,2					;Olh h diadikasia epanalamvanetai gia 2*0.5 = 1 deuterolepto
	breq change3							;Metavash sthn diadikasia metavashs stragismatos h exodou

	rjmp ksebgalma




change3:									;Diadikasia metavashs stragismatous h exodou
	cpi stragisma,0							;Elegxos ama exei epilegei h diadikasia stragismatos
	breq exit								;An oxi to programma termatizei
	com r17
	andi r17,0b11101111						;Svhsimo tou LED 4 xevgalma
	ori r17, 0b00100000						;Anama tou LED 5 stragisma
	com r17
	out PORTB,r17
	ldi alluse_counter,0						
	rjmp stragisma_wash				


stragisma_wash:								;Diadikasia stragismatos
	sbis PIND,0x00                          ;Ama patithei to 0 anoigei h porta anastelletai h leitourgia
	rcall door_led_off_on
	sbis PIND,0x00
	rjmp stragisma_wash

	sbis PIND,0x07							;Ama patithei to 7 stamataei h paroxh nerou kai anastelletai h leitourgia
	rcall water_stop

	mov r22,alluse_counter					;Metaferoume ton alluse_counter ston r22 gia na mhn metavlithei h timh tou
	sbis PIND,0x01							;Ama patithei to 1 prosïmoiwnetai h uperfortwsh tou plunthriou
	rcall overloaded
	
	rcall delay05s
	adiw alluse_counter,1
	
	cpi alluse_counter,4					;Olh h diadikasia epanalamvanetai gia 4*0.5 = 2 deuterolepta
	breq exit								;Metavash sthn diadikasia  exodou

	rjmp stragisma_wash



exit:                                     ;eksodos
	rjmp exit




bdelay05s:                               ;delay gia tis dokimes
	ret

delay05s:                                ;delay 0.5 deyteroleptwn
	ldi  r21, 11
    ldi  r23, 38
    ldi  r25, 94
L1: dec  r25
    brne L1
    dec  r23
    brne L1
    dec  r21
    brne L1
   	ret



