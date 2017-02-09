;vanliga misstag kan vara att absolut/omedelbar adresseringsmod #/#$/$ 
;kontrollera suffix .b (8) .w(16) .l(32)
;glom inte att satta stackpekaren
;kolla logiska problem i programmet mha trace
;dela upp programmet i subutiner och testa en i taget
	
;$1000 start
;$4000-$4003 4 senaste hexa-tecknen
;$4010-$4013 korrekt kod
;$4020- textstrangen'Felakig kod!'
;$7000 startvarde for stackpekaren 
;set stackpointer->subrutin->...->move to monitor...rts
setup:
	move.l #$7000,a7   	;stackpekaren till a7 (a7 brukar vara tom)

	jsr setuppia		;drar igang PIA A,B,C
	jsr printerror
	jsr code
	jsr clearinput		;rensa inbuffer
	;jsr setupflashdiod
	bra disable		;avaktivera larm

enable:
	jsr activatealarm
	;jsr flashdiod
	;jsr update_diod	;snabb uppdatering fran address (som ev. ej ar andrad)
	jsr getkey
	cmp.b #$f,d4		;; nollstalls inte d4 vid skip2?
	beq testcode 		; vanta pa att f trycks -> testa kod
	bra enable
testcode:
	jsr checkcode
	cmp.b #1,d4
	beq disable		; om ratt kod (d4=1) disable
				; annars felmedelande och enable
wrongcode:
	jsr printmsg
	bra enable
disable:
	jsr deactivatealarm
	jsr edit		;har kommer edit for koden for forsta gangen
	jsr clearinput
	;jsr setupselfactivate
	;jsr selfactivate aktiverar larm efter 5 sek om ej knapp (utom A) trycks
disable_func:	
	jsr getkey
	cmp.b #$a,d4
	bne disable_func	; vanta pa att a trycks -> enable
	bra enable
	
activatealarm:
;samma har som de-.s las forelasnsanteckningar fran fo 04
;move.l $10080,$10082
;or #$01,$10082  ;ta’nd lampan
;move.l $10082,$10080
	move.b #$01,$10080
        rts
edit:
	cmp.b #$c,d4		;uppgiften fragar efter input c, d4 har input
	beq changecode		;om sant hoppar vi till changecode (byter 4010-)
	rts
	
printmsg:
	move.l #$4020,a4
	move.b #15,d5		;langd av'FELAKTIG KOD!'
	jsr printstring
	rts
printchar:			;utskrift i terminal
	move.b d5,-(a7)		;Spara undan d5 (bit 7-0) pp stacken
waittx:
	move.b $10040,d5	;Serieportens statusregister
	and.b #2,d5		;Isolera bit 1 (Ready to transmit)
	beq waittx		;Vanta tills serieporten ar klar att sanda
	move.b d4,$10042	;Skicka ut
	move.b (a7)+,d5		;aterstall d5
	rts			;Tips: Satt en breakpoint har om du har problem med trace

setuppia:			;initering
	move.b #0,$10084	;Valj datariktningsregistret (DDRA)
	move.b #1,$10080	;Satt pinne 0 pa PIAA som utgang
	move.b #4,$10084	;Valj in/utgangsregistret
	move.b #0,$10086	;Valj datariktningsregistret (DDRB)
	move.b #0,$10082	;Satt alla pinnar som ingangar
	move.b #4,$10086	;Valj in/utgangsregistret
	rts


printstring:
;Inargument: Pekare till strangen i a4
;Langd pa strangen i d5
;vi kan loopa mha printchar och narlangden av d5 ar 0
;vet vi att alla tecken blir utskrivna
        move.b (a4)+,d4 	;skickar vidare M(a4) till d4
        jsr printchar   	;subrutinsanrop
        sub.b #1,d5     	;minskar langden pa str–’angen med 1
        beq skip1        	;om d5=0 hoppar vi tillbaka till setup
        bra printstring 	;annars printstring

skip1:	   rts             	;anropas om d5=0

deactivatealarm:
;Inargument: Inga
;Utargument: Inga
;Funktion: Slaacker lysdioden kopplad till PIAA
;har kan man helt enkelt kolla pa forelasningsanteckningarna fran fo4:
	;move.l $10080,$10082
	;and #$FE,$10082		;slacker lampan
	;move.l $10082,$10080
	move.b #$00,$10080
	rts			;undrar om denna rts behovs
	
getkey:
	move.b #$00,d4
        move.b $10082,d5 ;input piab
        move.b $4005,d6  ;tidigare input
	
        move.b d5,$4005 ;spara ny input
        move.b d6,$4004 ;spara gammal input

        and.b  #$10,d5 	;ny strobe
        and.b  #$10,d6 	;tidigare strobe
        lsr.b  #4,d5   	;strobe till bit 1
        lsr.b  #4,d6   	;strobe till  bit 1

        cmp.b  #$0,d6 	
        bne skip2	;om strobe==1  ;; skip2? dvs rts om strobe d6 var 1
strobe_0:
        cmp.b  #$1,d5 	;kollar om strobe
        bne skip2	;nar strobe = 0 => skip 2
        move.b $4005,d4 ;input
        and.b  #$0f,d4  
        jsr addkey
        rts     	
skip2:
        move.b #$00,d4
        rts
	

addkey:
;Inargument: Vald tangent i d4
;Utargument: Inga
;Funktion: Flyttar innehallet pa $4001-$4003 bakat en byte till
;$4000-$4002. Lagrar sedan innehallet i d4 pa adress $4003.
        cmp.b #9,d4     ;kollar om hexkey ar 'A'->aktivaera alarm
        bgt skip3
        move.l $4000,d3
	move.b $4000,d7
	move.l d7,$4006
	lsl.l #8,d7
	lsl.l #8,d3     ;flyttar 4001-4003 till 4000-4002
	move.l d3,$4000
        move.b d4,$4003 ;flyttar tillbaka d3 till 4 senaste hexa-tecknen
	
	rts             ;ska det inte vara 4001-4003 som flyttas till 4000-4002
;;; ; blir det inte lsr.l #8 4003 ($a $b $c $d) -> ($0 $a $b $c)
;;; ; sedan move.l d4,4003 ($d4 $a $b $c)
;;; ; Obs: inte alls saker
;;; ; od 29/1: det kanns som en battre losning
;;; ; od 29/1: fick bustrap error med lsr .l $4003 sa har far vi nog anvanda d-registret
;;; ; od 29/1: kanske behover fler hopp efter cmp.b for att det ska funka
skip3:	  rts
	
clearinput:
;Inargument: Inga
;Utargument: Inga
;Funktion: Satter innehallet pa $4000-$4003 till #$FF
	move.b #$ffffffff,$4000
	move.b #$ffffffff,$4006
	rts

checkcode:
;Inargument: Inga
;Utargument: Returnerar 1 i d4 om koden var korrekt, annars 0 i d4
	move.l $4010,d2	;vi lagger fram korrekt kod
	move.l $4000,d3	;vi kollar input
	cmp.l d2,d3	;vi jamfoinput med korrekt kod
	beq correct	;om rkorrekt satts d4 till 1
	move.b #0,d4	;annars 0 i d4
	rts
	
correct:
	move.b #1,d4	;checkcode hoppar hit om d2 och d3 ar samma
	rts

printerror:
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
	move.b #10,$402D	;newline
	rts
code:	
	move.b #$00,$4010	;kombination for avlarmning
        move.b #$00,$4011
        move.b #$00,$4012
        move.b #$00,$4013
	rts

update_diod:
	cmp.b #1,$4300
	beq activatealarm
	bne deactivatealarm
	move.l $4300,$10080	; lagger till ev. ny info pa 10080
	rts

setupflashdiod:
	move.b #0,$4300		;tillstand (1=tand, 0=slackt), istallet for att hemta fran PIA
	move.l #0,$4400		;raknare
	move.l #1000,$4500	;satt fordrojning till 1 sek

flashdiod:
; diod blinkar med 1 Hz. Raknar +1 och hoppar tillbaka till enable tills raknat klart, da togglar.
	;move.b $10082,d5 	;input piab
        ;and.b  #$10,d5 		;strobe
	;lsr.b  #4,d5   		;strobe till bit 1
	;cmp.b #1,d5
	;beq getkey		;om strobe=1 hoppa till getkey
	; alt om strobe finns sparad
	move.l $4400,d1 	;rakanre till d1
	add.l #1,d1		;+1
	move.l d1,$4400		;spara
	
	move.l $4400,d2		;fordrojning till d2
	cmp.l d1,d2		;raknat klart?
	beq togglediod		;toggla om sant, annars hoppa tillbaka till enable
	rts

togglediod:
	move.b $4300,d3		;tillstand till d3
	eor.b #01,d3		;toggla tillstand pa bit 1
	move.b d3,$4300		;spara tillstand
	move.l #0,$4400		;nollstall raknare
	rts


selfactivate:
; Aktiverar larm efter fem sekunder. 
; Om en knapp trycks innan dess blir larmet permanent avstangt, forutom om A trycks.
	
	move.l #0,$4600		;raknare
	move.l #5000,$4500	;satt fordrojning till 5 sekunder
	jsr wait
	rts
	
wait:
	;move.l $10082,d5 	;sparar data fran PIAA till d5, (behovs ej om d4 fran getkey funkar)
	jsr getkey		;;beroende pa om getkey vantar pa input
				;;annars kan ha d4 till nagot stort och ta blt f, sa 
				;;eller stroben
	cmp.b #$f,d4
	blt checkA      	;hex-key d4 < F (dvs ingen knapptryckning) branch

	add #1,d0
	cmp.l $4500,d0
	bne wait		;tid < 5 sek => wait
	jsr enable		;5 har passerat
	rts

checkA:
	cmp.b #$a,d4
	beq enable		;om d4 = A => enable alarm
	bra disable_func	;annars hoppa till disable_funk
	rts

changecode:
	move.l $4000,a1		;sparar 32bit input (4000-4003) i a1
	move.l $4006,a2		;sparar 32bit tidigare input (4006-4006) i a2
	cmp.l a1,a2		;har vi skrivit in samma 4siffriga kod 2 ganger?
	bne skip4		;nej->skippa kodbytet
	move.l a1,$4010		;ja->byt kod
	
skip4:	rts
