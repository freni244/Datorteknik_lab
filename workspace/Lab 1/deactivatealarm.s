;underfined trap error
setup:
	move.l #$7000,a7
	jsr setuppia
	jsr deactivatealarm
	move.b #255,d7
	trap #14

deactivatealarm:
;Inargument: Inga
;Utargument: Inga
;Funktion: Slaacker lysdioden kopplad till PIAA
;har kan man helt enkelt kolla pa forelasningsanteckningarna fran fo4:
        move.l $10080,$10082
        and #$FE,$10082	;slacker lampan
        move.l $10082,$10080
	;; jsr clearinput
        rts

;30/1 od: kanske borde testa setuppia med hexatangentbordet 
setuppia:;initering
        move.b #0,$10084 ;Valj datariktningsregistret (DDRA)
        move.b #1,$10080 ;Satt pinne 0 pa PIAA som utgang
        move.b #4,$10084 ;Valj in/utgangsregistret
        move.b #0,$10086 ;Valj datariktningsregistret (DDRB)
        move.b #0,$10082 ;Satt alla pinnar som ingangar
        move.b #4,$10086 ;Valj in/utgangsregistret
        rts

clearinput:
;Inargument: Inga
;Utargument: Inga
;Funktion: Satter innehallet pa $4000-$4003 till #$FF
        move.l #$ffffffff,$4000
        move.l #$ffffffff,$4001
        move.l #$ffffffff,$4002
        move.l #$ffffffff,$4003
        rts

	