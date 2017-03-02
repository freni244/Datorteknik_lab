setup:
        move.l #$7000,a7
        move.l #$5ed29943,$4000
        move.l #$cd42dc8f,$4004
        move.l #$158d9def,$4008
        move.l #$e58973ab,$400c
        move.l #$8935eb79,$5000
        move.l #$f770f97b,$5004
        move.l #$e6b312a6,$5008
        move.l #$22fca01c,$500c

start:
        move.b  #10,d0
        move.l #$4000,a0
        move.l #$5010,a1
loop
        move.b (a0)+,d4
        move.b -(a1),d1
        eor.b  d1,d4
        jsr    printchar
        add.b  #-1,d0
        bne    loop

        move.b #228,d7
        trap   #14
	

printchar:
	move.b d5,-(a7) 	; Spara undan d5 (bit 7-0) p˚a stacken
waittx
	move.b $10040,d5 	; Serieportens statusregister
	and.b #2,d5 		; Isolera bit 1 (Ready to transmit)
	beq waittx 		; V¨anta tills serieporten ¨ar klar att s¨anda
	move.b d4,$10042 	; Skicka ut
	move.b (a7)+,d5 	; ˚Aterst¨all d5
	rts
	