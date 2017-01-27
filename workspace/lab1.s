;$1000 start
;$4000-$4003 4 senaste hexa-tecknen
;$4010-$4013 korrekt kod
;$4020- textsträngen'Felakig kod!'
;$7000 startvärde f� stackpekaren 
;set stackpointer->subrutin->...->move to monitor...rts
printchar:		    ;utskrift i terminal
	move.b d5,-(a7)     ; Spara undan d5 (bit 7-0) pp stacken
waittx
	move.b $10040,d5    ; Serieportens statusregister
	and.b  #2,d5        ; Isolera bit 1 (Ready to transmit)
	beq waittx          ; Vänta tills serieporten är klar att sända
	move.b d4,$10042    ; Skicka ut
	move.b (a7)+,d5     ; återställ d5
	rts 		    ; Tips: Sätt en breakpoint här om du har problem med trace

setuppia:	;initering
	move.b #0,$10084    ; Välj datariktningsregistret (DDRA)
	move.b #1,$10080    ; Sätt pinne 0 på PIAA som utgång
	move.b #4,$10084    ; Välj in/utgångsregistret
	move.b #0,$10086    ; Välj datariktningsregistret (DDRB)
	move.b #0,$10082    ; Sätt alla pinnar som ingångar
	move.b #4,$10086    ; Välj in/utgångsregistret
rts

printstring:		    ; utskrift string (Förberedelseuppgift: Skriv denna subrutin!)

deactivatealarm:;avaktivera larm
activatealarm:	;aktivera larm
getkey:		;keylistener
addkey:		;tangent->inbuffer
clearinput:	;rensa inbuffer
checkcode:	;kodcheck
