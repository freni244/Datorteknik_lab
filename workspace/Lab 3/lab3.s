setup:
	move.l #$7000,a7
	move.l #$0,$3000 	  ; starttid 00:00
	jsr piainit
	and.w #$F8FF,SR		  ; avb.niva 0 (SR = 1111 1000 1111 1111)

main_loop:
	;stop #$2000		 ;; testa (satter i vilolage)
	bra main_loop

bcd:
	tst.b $10082		  ; laser fran PIAB —> nolstaller flaggor i CRB
	movem.l a0-a6/d0-d7,-(a7) ; Sparar register
	move.l $3000,a1		  ; hamta tid (hela 00:00 32-bitar)
	move.b #$0,d1		  ; raknare = 0
	move.b #$1,d3		  ; d3 carryflagga, avgor om rakna upp
				  ; (start alltid 1 ty rakna 1 sek)
bcd_loop:
	move.b (a1),d2		  ; hamta BCD-del
	add.b d3,d2		  ; rakna upp med ett om d3 = 1
	jsr bcd_carry	  	  ; om carry => d3=1, annars d3 = 0
	move.b d2,(a1)+		  ; spara ny tid och byt decimal
	
	add.b #1,d1
        cmp.b #4,d1
        bne bcd_loop		  ; loopa tills alla 4 decimaler uppdaterade

       	movem.l (a7)+,a0-a6/d0-d7 ; aterstall register
        rte

bcd_carry:
	move.b #$0,d3		  ; carry-flagga noll
	
	move.b d1,d4		  ; klock position (0-3) till d4
        and.b #$1,d4		  ; position 0-3 grindas med 0001
        beq.b carry_ten	 	  ; branch om z=1 (dvs d4 = 0000, eller 0010)
				  ; annars position 2, eller 4 (0001, 0011)

	cmp.b #$6,d2		  ; carry 6?
	bne not_carry		  ; ja => skip
	move.b #$1,d3		  ; nej => d3 = 1
	move.b #$0,d2		  ; nollstall nuvarande decimal (tex 00:59->01:00)
	
carry_ten:
	cmp.b #$A,d2		  ; carry 9?
	bne not_carry		  ; ja => skip
	move.b #$1,d3		  ; nej => d3 = 1
	move.b #$0,d2		  ; nollstall nuvarande decimal (tex 00:09->00:10)
not_carry:
	rts


mux:	
	movem.l a0-a6/d0-d7,-(a7) ; Sparar register
	tst.b $10080		  ; laser fran PIAA —> nolstaller flaggor i CRA
	move.l #$3010,a1          ; #displayadress
        move.b (a1),d1		  ; aktiv display
	
	and.l #$3,d1		  ; maska ut 2 bitar (00, 01, 10, 11 del)
	jsr select_num		  ; hitta aktiv-tid (= d3)
	
	;; Siffra ur tabell:
	;; adress = tabellstart + index(0-9)
	and.l #$F,d3	 	  ; Maska ut siffran (fyra bitar)
	lea SJUSEGTAB,a0	  ; tabellstart till a0
	add.l d3,a0		  ; Peka ut ratt byte (siffra ur tab)
	move.b (a0),d0		  ; Hamta siffra ur tabell
	
        move.b #0,$10080          ; slack lampor
        move.b d1,$10082          ; aktiv display till PIAB
        move.b d0,$10080          ; 7seg-siffra till PIAA

        add.b #$1,d1              ; Byt display (00 -> 01 -> 10 -> 11)
        move.b d1,(a1)            ; Sparar ny display pa a1:s adress

	movem.l (a7)+,a0-a6/d0-d7 ; aterstall register
	rte
select_num:
	move.l #$3000,d2	  ; #tidsadress
        add.b d1,d2	  	  ; #aktiv-tid = display + #tidsadress
        move.l d2,a2
        move.b (a2),d3		  ; (#aktiv-tid)
        rts

piainit:
	move.b #$00,$10084	  ; DDRA
	move.b #$ff,$10080	  ; valj in/ut (a-7 anvands ej)
	move.b #$07,$10084	  ; PIAA och tillat avb da CRA7 1-satts (CA1 0->1)
	move.b #$00,$10086	  ; DDRB
	move.b #$ff,$10082	  ; alla ut
	move.b #$07,$10084	  ; PIAB och tillat avb da CRA7 1-satts (CB1 0->1)

	move.l #bcd,$68 	  ; flyttar adress till avbr.niva-2
        move.l #mux,$74 	  ; flyttar adress till avbrottsniva-5
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
	




;; 1 Hz till CB1 (BCD)
;; 1000 Hz till CA1 (MUX)
; test: move.l #$01020408,$3010
; Hade kunnat anvanda bara #$900
