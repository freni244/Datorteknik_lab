setup:
	move.l #$7000,a7
	jsr setuppia
	jsr activatealarm
	move.b #255,d7
	trap #14
activatealarm:
	;; las forelasnsanteckningar fran fo 04
	move.l $10080,$10082
	        or #$01,$10082 	;tand lampan
	move.l $10082,$10080
	;; jsr flashdiod
	rts

;; 30/1 od: kanske borde testa setuppia med hexatangentbordet
setuppia:			;initering
        move.b #0,$10084 ;Valj datariktningsregistret (DDRA)
        move.b #5,$10080 ;Satt pinne 0 pa PIAA som utgang
        move.b #4,$10084 ;Valj in/utgangsregistret
        move.b #0,$10086 ;Valj datariktningsregistret (DDRB)
        move.b #0,$10082 ;Satt alla pinnar som ingangar
        move.b #4,$10086 ;Valj in/utgangsregistret
        rts

clearinput:
	;; Inargument: Inga
	;; Utargument: Inga
	;; Funktion: Satter innehallet pa $4000-$4003 till #$FF
        move.l #$ffffffff,$4000
        move.l #$ffffffff,$4001
        move.l #$ffffffff,$4002
        move.l #$ffffffff,$4003
        rts

	