;;vanliga misstag kan vara att absolut/omedelbar adresseringsmod #/#$/$
;;kontrollera suffix .b (8) .w(16) .l(32)
;;glÃ¶m inte att sÃ¤tta stackpekaren
;;kolla logiska problem i programmet mha trace
;;dela upp programmet i subutiner och testa en i taget
	
;$1000 start
;$4000-$4003 4 senaste hexa-tecknen
;$4010-$4013 korrekt kod
;$4020- textstrﾃ､ngen'Felakig kod!'
;$7000 startvﾃ､rde fﾃ stackpekaren 
;set stackpointer->subrutin->...->move to monitor...rts
setup:
	move.l #$7000,a7   	;sﾃtackpekaren till a7 (a7 brukar vara tom)

	move.b #$00,$4010	;kombination fÃ¶r avlarmning
        move.b #$00,$4011
        move.b #$00,$4012
        move.b #$00,$4013

        move.b #14,d5		;lÃ¤ngd av'FELAKTIG KOD!'

        move.b #'F',$4020 	;meddelande
        move.b #'E',$4021
        move.b #'L',$4022
        move.b #'A',$4023
        move.b #'K',$4024
        move.b #'T',$4025
        move.b #'I',$4026
        move.b #'G',$4027
        move.b #' ',$4028
        move.b #'K',$4029
        move.b #'O',$402A
        move.b #'D',$402B
        move.b #'!',$402C

	jsr setuppia		;drar igﾃ･ng PIA A,B,C
	jsr clearinput		;rensa inbuffer
	bra deactivatealarm	;avaktivera larm
	jsr activatealarm	;aktivera larm
	jsr getkey
	
activatealarm:
;;; ;   F??orberedelseuppgift: Skriv denna subrutn!
;;; ;   samma h??r som de-.s l??s f??rel??snsanteckningar fr??n f?? 04
	        move.l $10080,$10082
	        or #$01,$10082  ;tând lampan
	        move.l $10082,$10080
	        rts
;;; ; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printchar:		    ;utskrift i terminal
	move.b d5,-(a7)     ; Spara undan d5 (bit 7-0) pp stacken
waittx:	
	move.b $10040,d5    ; Serieportens statusregister
	and.b  #2,d5        ; Isolera bit 1 (Ready to transmit)
	beq waittx          ; Vﾃ､nta tills serieporten ﾃ､r klar att sﾃ､nda
	move.b d4,$10042    ; Skicka ut
	move.b (a7)+,d5     ; ﾃ･terstﾃ､ll d5
	rts 		    ; Tips: Sﾃ､tt en breakpoint hﾃ､r om du har problem med trace

setuppia:	;initering
	move.b #0,$10084    ; Vﾃ､lj datariktningsregistret (DDRA)
	move.b #1,$10080    ; Sﾃ､tt pinne 0 pﾃ･ PIAA som utgÃ¥ng
	move.b #4,$10084    ; Vﾃ､lj in/utgﾃ･ngsregistret
	move.b #0,$10086    ; Vﾃ､lj datariktningsregistret (DDRB)
	move.b #0,$10082    ; Sﾃ､tt alla pinnar som ingﾃ･ngar
	move.b #4,$10086    ; Vﾃ､lj in/utgﾃ･ngsregistret
	rts

;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Inargument: Pekare till strﾂｨangen i a4
;;;   Lﾂｨangd pﾋ啾 strﾂｨangen i d5
printstring:
;;;   Fﾂｨorberedelseuppgift: Skriv denna subrutin!
;;;   vi kan loopa mha printchar och nﾃ､rlﾃ､ngden av d5 ﾃ､r 0
;;;   vet vi att alla tecken blir utskrivna
	move.l -(a7),d4		;flyttar pekaren till a4
	jsr printchar		;ﾃ･teranvﾃ､nd stack-funktionaliteten hﾃ､r
	sub.l #1,d5		;minskar lﾃ､ngd d5 nmed 1 nu neftr printen
	beq fin			;ljﾃ､mfﾃｶr om branc ﾃ､r 'equal'
				;; Förslag: 	ben printstring ; om 0 gå vidare annars branch
				;;		rts
	bra printstring		;hoppa direkt till bﾃｶrjan
	rts			;gﾃ･ till subrutinen som kallade pﾃ･ printstring

fin:	rts			;hoppa tillbaka om alla element Ãr utskrvna
;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Inargument: Inga
;;;   Utargument: Inga
;;;
;;;   Funktion: Slﾂｨacker lysdioden kopplad till PIAA

deactivatealarm:
;;;   Fﾂｨorberedelseuppgift: Skriv denna subrutin!
;;;   hﾃ､r kan man helt enkelt kolla pﾃ･ fﾃｶrelﾃ､sningsanteckningarna frﾃ･n fﾃｶ4:
;;;   move LED,D
;;;    or #$FD,D
;;;   move D,LED
	move.l $10080,$10082
	or #$FD,$10082 		;slﾃ､cker lampan
				;; Tror vi ska ha ”and $FE,D” eftersom and släcker och FE=1111 1110 
				;; väljer pinne 0, där lampan sitter.
				;; tex 1111 1110 & 0000 1001 = 0000 1000
				;; Om jag fattat rätt.
	move.l $10082,$10080
	jsr clearinput
	rts			;undrar om denna rts behÃ¶vs
;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Inargument: Inga
;;;   Utargument: Tryckt knappt returneras i d4
getkey:	
;;;   Fﾂｨorberedelseuppgift: Skriv denna subrutin!
;;;   hﾃ､r lﾃ､ser vi av piab 0, piab 1, piab 2, piab 3 med abcd och a=MSB
;;;   kolla setuppia-rutinen fﾃｶ ingﾃ･ngar till hexa-tangentborde
;;;   om hexa-tecknet ﾃ､r mellan 0 och 9 skrivs en siffra utannars inte
	move.b #$00,d4		;tÃ¶m minnet
	move.b $10082,d5 	;inmatning frﾃ･n PIAB
	move.b d5,$4000		;lagra senaste siffran
        cmp.b #'A',d5		;kollar om hexkey ??r st??rre ??n 9
	bgt getkey		;om hÃ¶gre Ã¤n A->hoppa upp igen
	jsr addkey	 	;om d4<=9 lÃ¤ggstecknet pÃ¥ stacken
	move.l d4,$4000		;inmatning av kod till minne
	rts
;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Inargument: Vald tangent i d4
;;;   Utargument: Inga
;;;
;;;   Funktion: Flyttar inneh???llet p??? $4001-$4003 bak???t en byte till
;;;   $4000-$4002. Lagrar sedan inneh???llet i d4 p??? adress $4003.
addkey:
;;;   F??orberedelseuppgift: Skriv denna subrutin
	        cmp.b #'A',d4 	;kollar om hexkey ??r st??rre ??n 9
		beq activatealarm
	        lsl.w #8,d4     ;forts??tter vidare i str??ngen
	        move.l d4,$4000 ;flyttar tillbaka d3 till 4 senaste hexa-tecknen
	        move.l d4,$4013 ;senaste siffran i PIAB
				;; ska det inte vara 4001-4003 som flyttas till 4000-4002
				;; blir det inte lsr.l #8 4003  ($a $b $c $d) -> ($0 $a $b $c)
				;; sedan move.l d4,4003 ($d4 $a $b $c)
				;; Obs: inte alls säker
	        rts
g_t_9:
	        rts
;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Inargument: Inga
;;;   Utargument: Inga
;;;
;;;   Funktion: SÂ¨atter innehËallet pËa $4000-$4003 till $FF
clearinput:	
;;;   FÂ¨orberedelseuppgift: Skriv denna subrutin
;;;   HÃ¤r kan i fylla minnet med 20 bitar (minneskapaciteten i MC68008)
;;;   typ som setup i dugga1 fast istÃ¤ï¿½llet med tomma vÃ¤rden
	move.l #$ffffffff,$4000
	rts
;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Inargument: Inga
;;;   Utargument: Returnerar 1 i d4 om koden var korrekt, annars 0 i d4
;;;   hÃ¤r kan vi antingen Ã¤ndra vÃ¤rden internt i checkcode eller
;;;   hoppa till ytterligare subrutiner och Ã¤ndra
checkcode:	
;;;   FÂ¨orberedelseuppgift: Skriv denna subrutin
	move.l $4010,d2 	;vi kollar input
	move.l $4000,d3		;vi lÃ¤gger fram korrekt kod
	cmp.l d2,d3		;vi jÃ¤mfÃ¶input med korrekt kod
	beq correct		;om rkorrekt sÃ¤tts d4 till 1
	move.b #0,d4		;annars 0 i d4
	rts
correct:
	move.b #1,d4		;checkcode hoppar hit om d2 och d3 Ã¤r samma
	rts
;;; ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
