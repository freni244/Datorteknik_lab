

setup:
	move.l #$7000,a7	; laddar stackpekaren
	g c300			; hamtar givna subrutiner
	jsr PINIT		; given PIA-setup
	move.l #AVBV,$068	; flyttar adress till AVBV som avbr.vektror med avbr.niva-2
	move.l #AVBH,$074	; Ñ..- AVBH -..- avbrottsniva-5
	and.w #F8FF,sr		; andrar avbrottsnivan i processorn till 0
msg_loop:
	and.w #FEFF,sr		; andrar avbrottsnivan i processorn till &6 = %110 (%1111 1110 1111 1111)
	jsr SKBAK		; nu kan bara rod knapp avbryta under utskrift
	and.w #F8FF,sr		; avbrottsniva 0
	move.b #&1000,d0	; flyttar 1000 till d0
	jsr DELAY		; 1000 ms = 1 s fordrojning
	bra msg_loop
	
AVBV:
	cmp.b #0,$10080		; laser fran PIAA Ñ> nolstaller flaggor i CRA, se 4.7
	jsr SKAVV		; $2048
	rte

AVBH:
	cmp.b #0,$10082		; laser fran PIAB Ñ> nolstaller flaggor i CRB
	jsr SKAVH		; $20A6
	rte

