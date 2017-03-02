;; 1 Hz till CB1 (BCD)
;; 100 Hz.. till CA1 (MUX)

; test: move.l #$01020408,$910


setup:
	move.l #$7000,a7
	move.l #$0,$900 	  ; Starttid 32-bitar, 00:00.
	jsr PIAINIT
	
	move.l #BCD,$68 	  ; flyttar adress till avbr.niva-2
        move.l #MUX,$74 	  ; flyttar adress till avbrottsniva-5

	and.w #$F8FF,SR
	
main_loop:
	bra main_loop

BCD:
	movem.l a0-a6/d0-d7,-(a7) ; Sparar register
	tst.b $10082		  ; laser fran PIAB —> nolstaller flaggor i CRB

	move.l $900,a1		  ; hamta tid (hela 00:00 32-bitar)
	move.b #$0,d1		  ; raknare = 0
	move.b #$1,d3		  ; d3 carryflagga, avgor om rakna upp
				  ; (start alltid 1 ty rakna 1 sek)

BCD_loop:
	move.b (a1),d2		  ; hamta BCD-del
	add.b d3,d2		  ; rakna upp en decimal
	jsr BCD_carry	  	  ; kolla om rakna upp en decimal (tex 00:59)
	move.b d2,(a1)+		  ; spara ny tid och rakna byt decimal
	
	add.b #1,d1
        cmp.b #4,d1
        bne BCD_loop		  ; loopa tills alla decimaler uppdaterade
	
        movem.l (a7)+,a0-a6/d0-d7 ; aterstall register
        rte

BCD_carry:
	move.b #$0,d3		  ; carry-flagga noll
	
	move.b d1,d4		  ; klock position till d4
        and.b #$1,d4		  ; position 1-4 grindas med 0001
        beq.b carry_ten	 	  ; branch om z=1 (dvs d4 = 0001, eller 0011)
				  ; annars position 2, eller 4 (0010, 0100)

	cmp.b #$6,d2		  ; carry 6?
	bne not_carry
	move.b #$1,d3		  ; => rakna upp med ett i pa nasta decimal
	move.b #$0,d2		  ; nollstall nuvarande decimal (tex 00:59->01:00)
	
carry_ten:
	cmp.b #$A,d2		  ; carry 9?
	bne not_carry
	move.b #$1,d3		  ; => rakna upp med ett i pa nasta decimal
	move.b #$0,d2		  ; nollstall nuvarande decimal (tex 00:09->00:10)
not_carry:
	rts


MUX:
	movem.l a0-a6/d0-d7,-(a7) ; Sparar register
	tst.b $10080		  ; laser fran PIAA —> nolstaller flaggor i CRA
	move.l #$910,a1          ; BCD-siffras basadress
        move.b (a1),d1		  ; hamta del av BCD-siffra (bara byte)

	;;BCD del: $08    = 0000 1000
	;;	   $08+$3 = 0000 1011 .. .. 
	
	add.l #$3,d1
	jsr select_num		  ; ”d3 = 8-bit d1”

	
	;; Siffra ur tabell. 
	;; Slutlig adress i tab = tabellstart + index(0-9)
	and.l #$f,d3	 	  ; Maska ut siffran (fyra bitar)
	lea SJUSEGTAB,a0	  ; tabellstart till a0
	add.l d3,a0		  ; Peka ut ratt byte (siffra ur tab)
	move.b (a0),d0		  ; Hamta siffra ur tabell
	

        move.b #0,$10080          ; slack lampor
        move.b d1,$10082          ; aktiv display till PIAB
        move.b d0,$10080          ; BCD-del till PIAA

        add.b #$1,d1              ; Byt display (00 -> 01 -> 10 -> 11)
        move.b d1,(a1)            ; Sparar nytt segment pa adress till a1 ($910-$913)

	movem.l (a7)+,a0-a6/d0-d7 ; aterstall register

select_num:
	move.l #$900,d2  	  ; d2 = 0000 0000 (32-bit)
        add.b d1,d2	  	  ; d2 = 0000 00xx d1=xx (BCD-del + 3) 
        move.l d2,a2
        move.b (a2),d3	  	  ; xx (byte) till d3 som ska hamtas ur tabell
        rts

SJUSEGTAB:
	dc.b $3F; ”0”
        dc.b $06; ”1” 
        dc.b $5B; ”2” 
        dc.b $4F; ”3” 
        dc.b $66; ”4” 
        dc.b $6D; ”5” 
        dc.b $7D; ”6” 
        dc.b $07; ”7” 
        dc.b $7F; ”8” 
        dc.b $6F; ”9”
	rts


PIAINIT:
	move.b #00,$10084	  ; DDRA
	move.b #$7f,$10080	  ; valj in/ut (a-7 anvands ej)
	move.b #$07,$10084	  ; PIAA och tillat avb da CRA7 1-satts (CA1 0->1)
	move.b #00,$10086	  ; DDRB
	move.b #$ff,$10082	  ; alla ut
	move.b #$07,$10084	  ; PIAB och tillat avb da CRA7 1-satts (CB1 0->1)
	rts

