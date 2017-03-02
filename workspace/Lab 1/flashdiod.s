
;; Makes the diod flash in 1 Hz.

flashdiod:
	move.l d5,-(a7) 	; save d5 (needed???)
	move.l $10080,$10082
	xor #$01,10082 		; toggle LED
	move.l $10082,$10080

	move.w #0,d0		; counter for loop (.w 16 bit)
	jsr wait	
	rts
	
wait1:
	move.l $10082,d5 	; save data from PIAA to d5
	cpm #$ffffffff,d5	; if key pressed d5=/=ffffffff (ie cleared) => z=0 branch
	ben getkey      	; else d5=ffffffff (z=1) continue

	add #1,d0
	cpm #2000,d0		; delay 1 second
	ben wait1
	move.b (a7)+,d5		; reset d5 (needed???)
	
	rts


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;