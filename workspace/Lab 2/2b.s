setup:
	move.l #$7000,a7	;SP=$7000
	jsr init_d		;satter upp D-register (la2.7)
	jsr setup_interrupt	;satter upp avbrott (le2)
	jsr setup_pia		;DDR(A/B) CR(A/B)-7 (la1,la2.7)
	and.w #$f8ff,SR		;avbrottsniva i2i1i0=#$000 (le2)
	move #$8000,d7

	move.b #$ff,d6		;satter spelets borjan som serve
	move.b #$80,d2		;borjar med bollen pa A-sidan
	move #$8000,d7
loop:
	cmp.b #0,d2		;bollen ur spel?
	beq out			;poangutdelning och loop
	move.l d7,d0		;delay
	jsr delay		;initiera delay med d0=1000 (ms)
	jsr update_ball		;egen loop som stegar vidare i dioder
	bra loop		;uppdaterar spelsekvensen
out:
	jsr point		;adderar poang till A/B mha bollens riktning
	bra loop		;fortsatter i spelsekvensen
update_ball:
	or.w #$700,SR		;laser ut andra avbrott
	cmp.b #$ff,d6		;serve?
	beq update_led		;byter varde pa dioderna mha lagring pa d2
move_ball:
	cmp.b #0,d5		;kollar riktning pa bollen
	bne move_B		;mot A om 00 mot B om FF
move_A:				;annars A
	lsl.b #1,d2		;flyttar d2 1 steg T.V.
	bra update_led		;fortsatter stega vidare mot A
move_B:
	lsr.b #1,d2		;fortsatter stega vidare mot B
update_led:
	move.b d2,$10080	;d2 taget fran move A/B skickas vidare till PIA
	and.w #$f8ff,SR		;avblockerar avbrott
	rts
point:
	or.w #$700,SR		;laser ut andra avbrott
	cmp.b #00,d5		;kollar riktning pa bollen
	beq point_B		;om bollen har riktning mot A
point_A:			;annars riktning mot B
	or.w #$700,SR		;blockerar avbrott
	add.b #1,d3		;lagger till 1 poang till spelare A
	move.b #$ff,d5		;byt riktning till B
	move.b #$80,d2		;bollen flyttas till A:s sida
	bra point_done
point_B:
	or.w #$700,SR		;blockera avbrott
	add.b #1,d4		;poang B
	move.b #0,d5		;satt riktning till A
	move.b #1,d2		;flytta bollen till B:s sida
point_done:
	move.b #$ff,d6		;satter spelet till serve
	and.w #$f8ff,SR		;avblockerar avbrott
	rts
delay:
	sub.l #1,d0		;tidsvariabel i d0
	cmp.l #0,d0		;har vi raknat klart?
	bne delay		;fortsatt rakna ner
	rts			;annars hopp

init_d:
	move.b #0,d0		;delay ms
	move.b #0,d2		;diod
	move.b #0,d3		;poang A (V)
	move.b #0,d4		;poang B (H)
	move.b #0,d5		;riktning pa bollen: 0O=V ff=H
	move.b #0,d6		;serve: 00=ja ff=nej
	move.b #0,d7		;static delay
	rts

setup_pia:
	move.b #$0,$10084	;DDRA
	move.b #$ff,$10080	;0-7 output
	move.b #$5,$10084	;PIAA CRA_7 avbrott
	move.b #$0,$10086	;DDRB
	move.b #$ff,$10082	;0-7 output
	move.b #$5,$10086	;PIAB CRB_7 avbrott
	rts

setup_interrupt:
	lea Ainterrupt,a1	;laddar a1 med avbrottsniva2 for A
	lea Binterrupt,a2	;laddar a2 med avbrottsniva5 for B
	move.l a1,$68		;flyttar avbrott A till $68-
	move.l a2,$74		;flyttar avbrott B till $74-
	rts

Ainterrupt:
	tst.b $10082		;vantar pa ett avbrott for A
	cmp.b #$80,d2		;ar bollen precis vid A?
	bne A_end		;fortsatt annars
	cmp.b #0,d6		;servas bollen?
	beq bounce_B		;dalig formulering, men borjar "studsa"
	move.b #0,d6		;flyttar tillbala bollen i loop for serve
	bra done_A		;hoppa tillbaka fran avbrottet
bounce_B:
	eor.b #$ff,d5		;byter riktning pa bollen vid B
	bra done_A		;hoppa tillbaka fran avbrottet
A_end:
	cmp.b #$ff,d6		;B_serve?
	beq done_A		;hoppa tillbaka fran avbrottet
	jsr point_B		;om bollen var i rorelse tilldelas B poang
done_A:
	rte

Binterrupt:
	tst.b $10080		;vantar pa ett avbrott for B
	cmp.b #1,d2		;ar bollen i spel?
	bne B_end		;om nej slutas forflyttningen av dioder
	cmp.b #0,d6		;serve?
	beq bounce_A		;dalig formulering, men borjar "studsa"
	move.b #0,d6		;flyttar tillbala bollen i loop for serve
	bra done_B		;hoppa tillbaka fran avbrottet
bounce_A:
	eor.b #$ff,d5		;satter riktning mot B
	bra done_B		;hoppar tillbaka fran avbrottet
B_end:
	cmp.b #$ff,d6		;serve?
	beq done_B		;om serve hoppar vi tillbaka fran avbrottet
	jsr point_A		;annars tilldela poang till A
done_B:
	rte
	