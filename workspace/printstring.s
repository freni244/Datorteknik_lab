setup:
	move.l #$7000,a7
	move.l #$c126,a4
	move.b #16,d5
	jsr printstring
	move.b #255,d7
	trap #14
printstring:
;Inargument: Pekare till strangen i a4 
;Langd pa strangen i d5
;vi kan loopa mha printchar och narlangden av d5 ar 0
;vet vi att alla tecken blir utskrivna
        move.l (a7)+,d4	;flyttar pekaren till a4
        jsr printchar	;ateranvand stack-funktionaliteten har
        sub.b #1,d5	;minskar langd d5 med 1 nu efter printen
        bne printstring	;jamfor om branch ar 'equal'
        rts

printchar:
        move.b d5,-(a7) ;Spara undan d5 (bit 7-0) p?a stacken
waittx
        move.b $10040,d5 ;Serieportens statusregister
        and.b #2,d5      ;Isolera bit 1 (Ready to transmit)
        beq waittx
        move.b d4,$10042 ;Skicka ut
        move.b (a7)+,d5  ;aterstall d5
        rts
	