setup:	
	move.l #$7000,a4
	move.l #$c126,a4
	move.b #16,d5
	jsr printstring
	move.b #255,d7
	trap #14

printstring:
;Inargument: Pekare till strangen i a4 
;Langd pa strangen i d5
;vi kan loopa mha printchar och nar langden av d5 ar 0
;vet vi att alla tecken blir utskrivna
        move.b (a4)+,d4 ;skickar vidare M(a4) till d4
        jsr printchar	;subrutinsanrop
        sub.b #1,d5	;minskar langden pa strangen med 1
        beq skip	;om d5=0 ghoppar vi tillbaka till setup
        bra printstring	;annars printstring
	
skip:   rts		;anropas om d5=0

printchar:
        move.b d5,-(a7) ;Spara undan d5 (bit 7-0) pa stacken
waittx
        move.b $10040,d5 ;Serieportens statusregister
        and.b #2,d5      ;Isolera bit 1 (Ready to transmit)
        beq waittx
        move.b d4,$10042 ;Skicka ut
        move.b (a7)+,d5  ;Aterstall d5
        rts
