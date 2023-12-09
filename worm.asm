; worm.asm
;
; Kevin Chen ECE 109
;
; Date Submitted: Apr. 9, 2023
;
; Program 3 Spring 2023 - Worm game that takes 'w', 'a', 's', 'd' inputs for movement and 'r', 'g', 
; 'b', 'y', 'space' inputs to manually change the worm's color. The worm's color also changes every 
; 5 moves. The worm can't move outside the display's border. 'Enter' clears the screen and resets 
; the worm's location to the center of the screen and 'q' stops the program.

        .ORIG   x3000

START       AND R0, R0, #0
            AND R1, R1, #0
            AND R2, R2, #0  ; pen color
            AND R3, R3, #0
            AND R4, R4, #0
            AND R5, R5, #0
            AND R6, R6, #0
            AND R7, R7, #0

            ADD R1, R1 #5       ; move counter
            
            JSR DRAW

USERLOOP    GETC                ; user input
            LD R3, Negq
            ADD R3, R3, R0      ; check for 'q'
            BRz QUIT
            LD R3, Negenter     ; check for enter
            ADD R3, R3, R0
            BRz RESET
            ; check for color
            LD R6, red          
            LD R3, Negr
            ADD R3, R0, R3
            BRz CHANGECOLOR
            LD R6, blue          
            LD R3, Negb
            ADD R3, R0, R3
            BRz CHANGECOLOR
            LD R6, green          
            LD R3, Negg
            ADD R3, R0, R3
            BRz CHANGECOLOR
            LD R6, yellow          
            LD R3, Negy
            ADD R3, R0, R3
            BRz CHANGECOLOR
            LD R6, white          
            LD R3, Negspace
            ADD R3, R0, R3
            BRz CHANGECOLOR
            ; check movement 
            AND R4, R4, #0      ; forward
            AND R6, R6, #0      ; R6 x-coor
            ADD R4, R4, #-4     ; R4 y-coor
            LD R3, Negw         ; fowward
            ADD R3, R0, R3
            BRz DIRECTION
            ADD R6, R6, #4      ; right
            ADD R4, R4, #4
            LD R3, Negd
            ADD R3, R0, R3
            BRz DIRECTION
            ADD R6, R6, #-4     ; backward
            ADD R4, R4, #4
            LD R3, Negs         
            ADD R3, R0, R3
            BRz DIRECTION
            ADD R6, R6, #-4     ; left
            ADD R4, R4, #-4
            LD R3, Nega
            ADD R3, R0, R3
            BRz DIRECTION
            BRnzp USERLOOP

DRAW        ST R7, SaveR7b
            JSR GETLOCATION
            AND R4, R4, #0
            AND R5, R5, #0
            ADD R4, R4, #4      ; draw square
            ADD R5, R5, #4 
            LD R2, color        ; color
            LD R3, CurrTopLeft  ; load location
LOOPDRAW    STR R2, R3, #0 
            ADD R3, R3, #1
            ADD R4, R4, #-1
            BRp LOOPDRAW    
            LD R0, Num124
            ADD R3, R3, R0
            ADD R4, R4, #4
            ADD R5, R5, #-1
            BRp LOOPDRAW
            LD R7, SaveR7b
            RET

; changes color
CHANGECOLOR ST R6, color
            ST R7, SaveR7
            JSR DRAW
            LD R7, SaveR7
            RET

; coordinate position to hex
GETLOCATION LD R3, TopLeftCorner
            LD R0, Currx
            ADD R3, R3, R0
            LD R0, Curry
            LD R4, Num128
LOOPGETL    ADD R3, R3, R0
            ADD R4, R4, #-1
            BRp LOOPGETL
            ST R3, CurrTopLeft
            RET            

; modifies direction
DIRECTION   ST R7, SaveR7
            LD R5, Currx
            ADD R5, R6, R5
            ST R5, Currx
            LD R5, Curry
            ADD R5, R4, R5
            ST R5, Curry
            JSR BOUNDARY
            ADD R1, R1, #-1
            BRz MOVE5 
COMEBACK    JSR DRAW                ; go draw
            LD R7, SaveR7
            RET

; move 5 change color
MOVE5       ADD R1, R1, #5          ; reset counter
            LD R5, color
            LD R6, red
            NOT R6, R6 
            ADD R6, R6, #1
            ADD R6, R6, R5
            BRz CHANGERED
            LD R6, green
            NOT R6, R6 
            ADD R6, R6, #1
            ADD R6, R6, R5
            BRz CHANGEGREEN
            LD R6, blue
            NOT R6, R6 
            ADD R6, R6, #1
            ADD R6, R6, R5
            BRz CHANGEBLUE
            LD R6, yellow
            NOT R6, R6 
            ADD R6, R6, #1
            ADD R6, R6, R5
            BRz CHANGEYELL
            BRnzp CHANGEWHITE

CHANGERED   LD R6, green            ; red to green
            ST R6, color
            BRnzp COMEBACK

CHANGEGREEN LD R6, blue             ; green to blue
            ST R6, color
            BRnzp COMEBACK

CHANGEBLUE  LD R6, yellow           ; blue to yellow 
            ST R6, color
            BRnzp COMEBACK

CHANGEYELL  LD R6, white            ; yellow to white
            ST R6, color
            BRnzp COMEBACK

CHANGEWHITE LD R6, red              ; white to red
            ST R6, color
            BRnzp COMEBACK

; check boundary
BOUNDARY    LD R5, Currx            ; too far left
            BRn WORMOUT             
            LD R2, Neg127           ; too far right
            ADD R2, R5, R2
            BRp WORMOUT
            LD R5, Curry            ; too far up
            BRn WORMOUT
            LD R2, Neg123           ; too far down
            ADD R2, R5, R2
            BRp WORMOUT
            RET

WORMOUT     LEA R0, wormprompt
            PUTS
            NOT R6, R6
            ADD R6, R6, #1
            LD R5, Currx
            ADD R5, R6, R5
            ST R5, Currx
            NOT R4, R4
            ADD R4, R4, #1
            LD R5, Curry
            ADD R5, R4, R5
            ST R5, Curry
            BRnzp USERLOOP

; reset screen      
RESET       LD R4, Num128           ; 128
            LD R5, Num124           ; 124
            LD R2, black
            LD R3, TopLeftCorner
LOOPRESET   STR R2, R3, #0
            ADD R3, R3, #1
            ADD R4, R4, #-1
            BRp LOOPRESET
            LD R4, Num128 
            ADD R5, R5, #-1
            BRp LOOPRESET
            LD R3, Startx
            ST R3, Currx
            LD R3, Starty
            ST R3, Curry
            LD R6, white
            JSR CHANGECOLOR
            BRnzp START



QUIT        HALT

; variables
white               .FILL       x7FFF   ; hex color white
color               .FILL       x7FFF
red                 .FILL	x7C00
blue                .FILL	x001F
green               .FILL	x03E0
yellow              .FILL       x7FED
Negq                .FILL       #-113   ; 'q' decimal value
Currx               .FILL       #64
Curry               .FILL	#60
Startx              .FILL	#64
Starty              .FILL	#60
CurrTopLeft         .FILL	xC000
TopLeftCorner       .FILL	xC000
Num128              .FILL	#128
Neg123              .FILL       #-123
Num124              .FILL	#124
Neg127              .FILL       #-127
Negr                .FILL	#-114
Negb                .FILL	#-98
Negg                .FILL	#-103
Negy                .FILL	#-121
Negspace            .FILL	#-32
Negw                .FILL       #-119
Nega                .FILL	#-97
Negs                .FILL	#-115
Negd                .FILL	#-100
Negenter            .FILL	#-10
SaveR7              .FILL	xA000
SaveR7a             .FILL	xA001
SaveR7b             .FILL	xA002
black               .FILL       x0000
wormprompt          .STRINGZ	"WORMS CAN’T LEAVE!\n"