setup:
	move.l #$7000,a7
	jsr clearinput
	move.b #1,d4
	jsr addkey
	move.b #2,d4
	jsr addkey
	move.b #3,d4
	jsr addkey
	move.b #4,d4
	jsr addkey
	move.b #255,d7
	trap #14
	
clearinput:
	;; Inargument: Inga
	;; Utargument: Inga
	;; Funktion: Satter innehallet pa $4000-$4003 till #$FF
	        move.l #$ffffffff,$4000
	        move.l #$ffffffff,$4001
	        move.l #$ffffffff,$4002
	        move.l #$ffffffff,$4003
	        rts
	
addkey:
	;; Inargument: Vald tangent i d4
	;; Utargument: Inga
	;; Funktion: Flyttar innehallet pa $4001-$4003 bakat en byte till
	;; $4000-$4002. Lagrar sedan innehallet i d4 pa adress $4003.
	        cmp.b #'A',d4	;kollar om hexkey ar 'A'->aktivaera alarm
	        beq activatealarm
	        lsr.l #8,d3	;fortsatter vidare i strangen
	        move.l d4,$4003	;flyttar tillbaka d3 till 4 senaste hexa-tecknen
	        rts		;ska det inte vara 4001-4003 som flyttas till 4000-4002
;;; blir det inte lsr.l #8 4003 ($a $b $c $d) -> ($0 $a $b $c)
;;; sedan move.l d4,4003 ($d4 $a $b $c)
;;; Obs: inte alls saker
;;; od 29/1: det kanns som en battre losning
;;; od 29/1: fick bustrap error med lsr .l $4003 sa har far vi nog anvanda d-registret
;;; od 29/1: kanske behover fler hopp efter cmp.b for att det ska funka

activatealarm:
;;; ; ;   samma har som de-.s las forelasnsanteckningar fran fo 04
	                move.l $10080,$10082
	                or #$01,$10082 ;ta\226\222nd lampan
	                move.l $10082,$10080
	                jsr flashdiod
	                rts

flashdiod:
	;;  Makes the diod flash in 1 Hz.
	        move.l d5,-(a7)	; save d5 (needed???)
	        move.l $10080,$10082
	        eor #$01,10082	; toggle LED
	        move.l $10082,$10080
	        move.w #0,d0	; counter for loop (.w 16 bit)
	        jsr wait1
	        rts

wait1:	  add #1,d0
	;; avbrott istallet for jsr checkkeypress...

	        cmp.l #2000,d0	; delay 1 second
	        bne wait1
	        move.b (a7)+,d5	; reset d5 (needed???)
	        rts
	