setup:
	move.l #$7000,a7
	jsr getkey
	move.b #255,d7
	trap #14
getkey:
	move.b $10082,d5 ;input piab
        move.b $4000,d6	 ;tidigare input

        move.b d5,$4000	;spara ny input
        move.b d6,$4002	;spara gammal input

        and.b  #$10,d5 ;ny strobe
        and.b  #$10,d6 ;tidigare strobe
        lsr.b  #4,d5   ;strobe till bit 1
        lsr.b  #4,d6   ;strobe till  bit 1

        cmp.b  #$0,d6 ;nostrobe
        bne skip
strobe:
        cmp.b  #$1,d5 ;kollar om strobe 
        bne skip
        move.b $4000,d4	; Fetch input
        and.b  #$0f,d4	; Zero out the four MSB bits
        jsr addkey
        rts	; Return input to d4
skip:
        move.b #$00,d4
	rts
clearinput:
;Inargument: Inga
;Utargument: Inga
;Funktion: Satter innehallet pa $4000-$4003 till #$FF
        move.l #$ff,$4000
        move.l #$ff,$4001
        move.l #$ff,$4002
        move.l #$ff,$4003
        rts

addkey:
;Inargument: Vald tangent i d4
;Utargument: Inga
;Funktion: Flyttar innehallet pa $4001-$4003 bakat en byte till
;$4000-$4002. Lagrar sedan innehallet i d4 pa adress $4003.
        cmp.b #'9',d4	;kollar om hexkey ar 'A'->aktivaera alarm
	bgt char
        lsl.l #8,d5	;fortsatter vidare i strangen
        move.l d4,$4003	;flyttar tillbaka d3 till 4 senaste hexa-tecknen
        rts		;;ska det inte vara 4001-4003 som flyttas till 4000-4002
;;blir det inte lsr.l #8 4003 ($a $b $c $d) -> ($0 $a $b $c)
;;sedan move.l d4,4003 ($d4 $a $b $c)
;;Obs: inte alls saker
;od 29/1: det kanns som en battre losning
;od 29/1: fick bustrap error med lsr .l $4003 sa har far vi nog anvanda d-registret
;od 29/1: kanske behover fler hopp efter cmp.b for att det ska funka
char:	rts
	