setup:	
	        move.l #$7000,a7
	        jsr pinit
	        jsr interrupt_vectors
	        and.w #$f8ff,sr
loop
	        jsr delay
	        jsr skbak
	        bra loop

pinit:
	        jsr $20ec
	        rts
skbak:	
	        or.w #$0700,sr
	        jsr $2020
	        and.w #$f8ff,sr
	        rts
skavv:
	        tst.b $10082
	        jsr $2048
	        rte
skavh:
	        tst.b $10080
	        jsr $20a6
	        rte
delay:
                move.l #1000,d0
                jsr $2000
                rts
interrupt_vectors:
	        lea skavv,a1
	        move.l a1,$68
	        lea skavh,a1
	        move.l a1,$74
	        rts
	