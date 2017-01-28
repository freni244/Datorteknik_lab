;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;  Inargument: ASCII-kodat tecken i register d4
	;;  Varning - Denna rutin g˚ar inte att stega sig igenom med TRACE d˚a den
	;;  anv¨ander serieporten p˚a ett s¨att som ¨ar inkompatibelt med TRACE.
printchar
	move.b d5,-(a7) 	; Spara undan d5 (bit 7-0) p˚a stacken
waittx
	move.b $10040,d5 	; Serieportens statusregister
	and.b #2,d5 		; Isolera bit 1 (Ready to transmit)
	beq waittx 		; V¨anta tills serieporten ¨ar klar att s¨anda
	move.b d4,$10042 	; Skicka ut
	move.b (a7)+,d5 	; ˚Aterst¨all d5
	rts 			; Tips: S¨att en breakpoint h¨ar om du har problem med trace!	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	