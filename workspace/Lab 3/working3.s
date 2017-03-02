;; 1 Hz till CB1 (BCD)	
;; 100 Hz.. till CA1 (MUX)

; test: move.l #$01020408,$910
setup:
        move.l #$7000,a7
        move.l #$0,$900			; Starttid 32-bitar, 00:00.
        
        jsr setuppia
        jsr setuploop
        and.w #$F8FF,SR
main_loop:
        jsr loop
        bra main_loop

bcd:
        tst.b $10082                    
        movem.l a0-a6/d0-d7,-(a7)       

        move.l #$900,a1
	move.b #$0,d1                  
        move.b #$1,d3
bcd_loop:
        move.b (a1),d2                 
        add.b d3,d2                     
        jsr bcd_carry
	move.b d2,(a1)+                

        add.b #1,d1
        cmp.b #4,d1                    
        bne bcd_loop
bcd_done:
        move.l #$FFFF,$2010
        movem.l (a7)+,a0-a6/d0-d7      
        rte
bcd_carry:
        move.b #$0,d3                  
        
        move.b d1,d4
        and.b #$1,d4
        beq.b carry_up_to_9

        cmp.b #$6,d2                    
        bne no_carry
        move.b #$0,d2                  
        move.b #$1,d3                   

carry_up_to_9:
        cmp.b #$A,d2                   
        bne no_carry
        
        move.b #$0,d2
	move.b #$1,d3                  
no_carry:
        rts
seg_mux:
        movem.l a0-a6/d0-d7,-(a7)      
        tst.b $10080                    
        move.l #$910,a1               
        move.b (a1),d1                 

        and.l #$3,d1
        jsr get_num                
	
        and.l #$F,d3
        lea seg_mem,a0
	add.l d3,a0
        move.b (a0),d0

        move.b #0,$10080               
        move.b d1,$10082                
        move.b d0,$10080              

        add.b #$1,d1                   
        move.b d1,(a1)                 
 
        movem.l (a7)+,a0-a6/d0-d7      
        rte
get_num:
        move.l #$900,d2
        add.b d1,d2
        move.l d2,a2                  
        move.b (a2),d3
        rts        
setuppia:
        move.b #$00,$10084        ; Valj datariktningsregistret (DDRA)
        move.b #$FF,$10080        ; Satt alla pinnar pa PIAA som utgang
        move.b #$07,$10084        ; Valj in/utgangsregistret och satt interrupt CRA_7
        move.b #$00,$10086        ; Valj datariktningsregistret (DDRB)
        move.b #$FF,$10082        ; Satt alla pinnar pa PIAB som utgang 
        move.b #$07,$10086        ; Valj in/utgangsregistret och satt interrupt CRB_7
        
        move.l #bcd,$68
        move.l #seg_mux,$74
        rts

seg_mem:
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
setuploop:
        move.b #$FF,$2000
        move.b #$AA,$2001
        move.b #$66,$2002
        move.b #$00,$2003

        move.b #$0,$2010
        rts
loop:
counter:
        move.b $2010,d0
        add.b #1,d0
        cmp.b #$FF,d0
        bne no_loop_reset
        move.b #0,d0
no_loop_reset: 
        move.b d0,$2010

loop_control:
        move.b $910,d1                
        and.b #$03,d1
        move.l #$2000,d2
        add.b d1,d2
        move.l d2,a0
        move.b (a0),d3
        cmp d3,d0
        beq turn_7seg_off
        rts
turn_7seg_off:
        move.b #0,$10080               
        rts
next_num
        move.b $2004,d1
        
        and.b d0,d1

        cmp.b #0,d0
        lsl.b #1,d0
        bne next_num 
        rts
	