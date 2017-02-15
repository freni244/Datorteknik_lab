
; uppgift 1
setup:
	move.l #$7000,a7	; laddar stackpekaren
	jsr PINIT		; given PIA-setup
	move.l AVBV,$1100	; lagger avbrottsrutiner pa 1100 resp 1200
	move.l AVBH $1200
	move.l $1100,$068	; flyttar adress 1100 till avbr.vektror med avbr.niva-2
	move.l $1200,$074	; Ñ..- 1200 -..- avbrottsniva-5
	and.w #F8FF,sr		; andrar avbrottsnivan i processorn till 0

printBAKGRUNDSPROGRAM:


; uppgift 2

AVBV:
	cmp.b #0,$10080		; laser fran PIAA Ñ> nolstaller flaggor i CRA, se 4.7
	jsr SKAVV		; $2048
	rte

AVBH:
	cmp.b #0,$10082		; laser fran PIAB Ñ> nolstaller flaggor i CRB
	jsr SKAVH		; $20A6
	rte

; Kanske detta, beroende pa vad som menas med laser fran PIAA/B under 4.7
; menar dem att man byter till PIAA/B eller laser fran den?
; or.b #4,10080
; or.b #4,10082