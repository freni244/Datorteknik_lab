;3: grinda statusregistret med or 111 p� i2i1i0 s� inga avbrott p�verkar texten
;3: f�r avbrottsniv� 7 �r p� samma niv� som 111 s� det avbrottet kan k�ras
;4: vi f�r 6ff4 ist�llet f�r 6ff8
;4: 00 00 10 52 00 00 10 16
;5: v�rt stackdjup blir 40, $7000-$6fd8=#40
;5: 00 00 10 52 00 00 10 16
;5: kanske $1016 (jsr sbak) och $103a (rte skav)
setup:				
        move.l #$7000,a7
        jsr pinit
        jsr interrupt_vectors
        and.w #$f8ff,sr
loop:	
        jsr delay
        jsr skbak
        bra loop
pinit:
        jsr $20ec
        rts
skbak:	
        or.w #$700,sr
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
        lea skavh,a2
	move.l a2,$74
        rts
