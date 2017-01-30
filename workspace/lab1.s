;;vanliga misstag kan vara att absolut/omedelbar adresseringsmod #/#$/$
;;kontrollera suffix .b (8) .w(16) .l(32)
;;glom inte att satta stackpekaren
;;kolla logiska problem i programmet mha trace
;;dela upp programmet i subutiner och testa en i taget
	
;$1000 start
;$4000-$4003 4 senaste hexa-tecknen
;$4010-$4013 korrekt kod
;$4020- textstrangen'Felakig kod!'
;$7000 startvarde for stackpekaren 
;set stackpointer->subrutin->...->move to monitor...rts
setup:
	move.l #$7000,a7   	;stackpekaren till a7 (a7 brukar vara tom)

	move.b #$00,$4010	;kombination for avlarmning
        move.b #$00,$4011
        move.b #$00,$4012
        move.b #$00,$4013

        move.b #14,d5		;langd av'FELAKTIG KOD!'

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

	jsr setuppia		;drar igang PIA A,B,C
	jsr clearinput		;rensa inbuffer
	bra deactivatealarm	;avaktivera larm
	jsr activatealarm	;aktivera larm
	jsr getkey
	
activatealarm:
;;; ;   samma har som de-.s las forelasnsanteckningar fran fo 04
	        move.l $10080,$10082
	        or #$01,$10082  ;tand lampan
	        move.l $10082,$10080
		jsr flashdiod
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

;;;   Inargument: Pekare till strangen i a4
;;;   Langd pa strangen i d5
printstring:
;Inargument: Pekare till straangen i a4
;Langd pa straangen i d5
;vi kan loopa mha printchar och narlangden av d5 ar 0
;vet vi att alla tecken blir utskrivna
	move.l -(a7),d4		;flyttar pekaren till a4
	jsr printchar		;ateranvand stack-funktionaliteten har
	sub.l #1,d5		;minskar langd d5 med 1 nu efter printen
	bne printstring		;jamfor om branch ar 'equal'
	rts


deactivatealarm:
;Inargument: Inga
;Utargument: Inga
;Funktion: Slaacker lysdioden kopplad till PIAA
;har kan man helt enkelt kolla pa forelasningsanteckningarna fran fo4:
	move.l $10080,$10082
	and #$FE,$10082		;slacker lampan
	move.l $10082,$10080
	jsr clearinput
	rts			;undrar om denna rts behovs
	
getkey:
;Inargument: Inga
;Utargument: Tryckt knappt returneras i d4
;har laser vi av piab 0, piab 1, piab 2, piab 3 med abcd och a=MSB
;kolla setuppia-rutinen fo ingangar till hexa-tangentborde
;om hexa-tecknet ar mellan 0 och 9 skrivs en siffra utannars inte
	move.b #$00,d4		;tom minnet
	move.b $10082,d5	;inmatning fran PIAB
	move.b d5,$4000		;lagra senaste siffran
	cmp.b #'A',d5		;kollar om hexkey ar storre an 9
	bgt getkey		;om hogre an A->hoppa upp igen
	jsr addkey		;om d4<=9 laggstecknet pa stacken
	move.l d4,$4000		;inmatning av kod till minne
	rts

addkey:	
;Inargument: Vald tangent i d4
;Utargument: Inga
;Funktion: Flyttar innehallet pa $4001-$4003 bakat en byte till
;$4000-$4002. Lagrar sedan innehallet i d4 pa adress $4003.
	cmp.b #'A',d4		;kollar om hexkey ar 'A'->aktivaera alarm
	beq activatealarm
	lsr.l #8,d3		;fortsatter vidare i strangen
	move.l d4,$4003		;flyttar tillbaka d3 till 4 senaste hexa-tecknen
	rts			;ska det inte vara 4001-4003 som flyttas till 4000-4002
				;;blir det inte lsr.l #8 4003 ($a $b $c $d) -> ($0 $a $b $c)
				;;sedan	move.l d4,4003 ($d4 $a $b $c)
				;;Obs: inte alls saker
				;;od 29/1: det kanns som en battre losning
				;;od 29/1: fick bustrap error med lsr .l $4003 sa har far vi nog anvanda d-registret
				;;od 29/1: kanske behover fler hopp efter cmp.b for att det ska funka
	
clearinput:
;Inargument: Inga
;Utargument: Inga
;Funktion: Satter innehallet pa $4000-$4003 till #$FF
	move.l #$ffffffff,$4000
        move.l #$ffffffff,$4001
        move.l #$ffffffff,$4002
	move.l #$ffffffff,$4003
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


timelimitedopen:
; Activates alarm after five seconds unless a key is pressed, except A, 
; which activates the alarm directly. 
	move.l d5,-(a7) 	; save d5 (needed???)
	move.l #0,d0		; counter for loop (.l 32 bit)
	jsr wait	
	rts
	
wait2:
	move.l $10082,d5 	; save data from PIAA to d5
	cpm #$ffffffff,d5	; if key pressed d5=/=ffffffff (ie cleared) => z=0 => branch
	ben checkA      	; else, d5=ffffffff (z=1), no key was pressed continue

	cpm #$
	add #1,d0
	cpm #10000,d0		; delay 5 seconds
	ben wait2
	move.b (a7)+,d5		; reset d5 (needed???)	
	jsr activatealarm	; 5 seconds has passed
	rts

checkA:
	cpm #’A’,d5		
	beq activatealarm	; if d5=A z=1 => branch to activatealarm
	jsr deactivatealarm	; else deactivatealarm

	rts


flashdiod:
; Makes the diod flash in 1 Hz.
	move.l d5,-(a7) 	; save d5 (needed???)
	move.l $10080,$10082
	xor #$01,10082 		; toggle LED
	move.l $10082,$10080

	move.w #0,d0		; counter for loop (.w 16 bit)
	jsr wait	
	rts
	
wait1:
	move.l $10082,d5 	; save data from PIAA to d5
	cpm #$ffffffff,d5	; if key pressed d5=/=ffffffff (ie cleared) => z=0 branch
	ben getkey      	; else d5=ffffffff (z=1) continue

	add #1,d0
	cpm #2000,d0		; delay 1 second
	ben wait1
	move.b (a7)+,d5		; reset d5 (needed???)
	
	rts
