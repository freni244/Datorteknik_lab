
;; Activates alarm after five seconds unless a key is pressed, except A, 
;; which activates the alarm directly. 

timelimitedopen:
	move.l d5,-(a7) 	; save d5 (needed???)
	move.l #0,d0		; counter for loop (.l 32 bit)
	jsr wait	
	rts
	
wait2:
	move.l $10082,d5 	; save data from PIAA to d5
	cpm #$ffffffff,d5	; if key pressed d5=/=ffffffff (ie cleared) => z=0 => branch
	ben checkA      	; else, d5=ffffffff (z=1), no key was pressed continue

	cpm #$
	add #1,d0
	cpm #10000,d0		; delay 5 seconds
	ben wait2
	move.b (a7)+,d5		; reset d5 (needed???)	
	jsr activatealarm	; 5 seconds has passed
	rts

checkA:
	cpm #’A’,d5		
	beq activatealarm	; if d5=A z=1 => branch to activatealarm
	jsr deactivatealarm	; else deactivatealarm

	rts




;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;