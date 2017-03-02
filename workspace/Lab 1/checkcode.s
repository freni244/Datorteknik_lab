setup:
	move.l #$7000,a7
	jsr checkcode
	move.b #255,d7
	trap #14
	
checkcode:	
	move.l $4000,d2;input hexa-tangentbord
	move.l $4010,d3	;vi lägger fram korrekt kod
	cmp.l d2,d3	;vi jämföinput med korrekt kod
	beq correct	;om rkorrekt sätts d4 till 1
	move.b #0,d4	;annars 0 i d4
	rts
correct:
	move.b #1,d4	;checkcode hoppar hit om d2 och d3 är samma
	rts

	