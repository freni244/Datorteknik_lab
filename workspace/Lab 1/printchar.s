start:		move.l #$7000,a7
	        move.l #64,d4
	        jsr printchar
	        move.b #228,d7
	        trap   #14

printchar:
	        move.b d5,-(a7)	; Spara undan d5 (bit 7-0) p?a stacken
waittx
	        move.b $10040,d5 ; Serieportens statusregister
	        and.b #2,d5	 ; Isolera bit 1 (Ready to transmit)
	        beq waittx
	        move.b d4,$10042 ; Skicka ut
	        move.b (a7)+,d5	 ; ?Aterst▒all d5
	        rts
	