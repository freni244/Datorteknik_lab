setup:
	move.l #$7000,a7
	jsr clearinput
	move.b #255,d7
	trap #14
clearinput:
;Inargument: Inga
;Utargument: Inga
;Funktion: Satter innehallet pa $4000-$4003 till #$FF
        move.l #$ff,$4000
        move.l #$ff,$4001
        move.l #$ff,$4002
        move.l #$ff,$4003
        rts

	