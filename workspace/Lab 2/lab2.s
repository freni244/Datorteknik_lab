
; uppgift 1
setup:
	move.l #$7000,a7	; laddar stackpekaren
	jsr PINIT		; given PIA-setup
	move.l AVBV,$1100	; lagger avbrottsrutiner pa 1100 resp 1200
	move.l AVBH $1200
	move.l $1100,$068	; flyttar adress 1100 till avbr.vektror med avbr.niva-2 ;;???
	move.l $1200,$074	; Ñ..- 1200 -..- avbrottsniva-5
	and.w #F8FF,sr		; andrar avbrottsnivan i processorn till 0

printBAKGRUNDSPROGRAM:


; uppgift 2

AVBV:
	cmp.b #0,$10080		; laser fran PIAA Ñ> nolstaller flaggor i CRA, se 4.7
	jsr SKAVV		; $2048
	rte

AVBH:
	cmp.b #0,$10080		; laser fran PIAB Ñ> nolstaller flaggor i CRB
	jsr SKAVH		; $20A6
	rte

