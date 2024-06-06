JUMPS
IDEAL
MODEL small
 

 





STACK 100h


DATASEG

	RndCurrentPos dw 0
	matrix dw 0
    OneBmpLine 	db 320 dup (0)  ; One Color line read buffer
   
    ScrLine 	db 324 dup (0)  ; One Color line read buffer


	;background file 
	backgroundmatrix db 6400 dup (0)


	;BMP File data
	
	OpeningScreenFileName db "OPS.bmp" ,0
	OpeningScreenHowToPlayFileName db "OPSHTP.bmp" ,0
	OpeningScreenAboutFileName db "OPSA.bmp" ,0
	OpeningScreenPlayFileName db "OPSP.bmp" ,0
	OpeningScreenQuitFileName db "OPSQ.bmp", 0
	AboutScreenFileName db "ABOUTS.bmp", 0
	HowToPlayScreenFileName db "HTPS.bmp", 0 
	GameOverFileName db "GameO.bmp", 0
	GameOverQuitFileName db "GOQ.bmp", 0
	GameOverStartAgainFileName db "GOSG.bmp", 0
	GameWonFileName db "Gamewon.bmp", 0
	
	PlayAgainPrint db 0
	OpeningScreenPrint db 0
	
	
	
	EXP1FileName db "EXP1.bmp", 0
	EXP2FileName db "EXP2.bmp", 0
	EXP3FileName db "EXP3.bmp", 0
	EXP4FileName db "EXP4.bmp", 0

	
	
	IsMouseOn db 0 ;if 0 mouse is not on icon (Print OPS)
	IsAbout db 0 
	IsHowToPlay db  0
	IsQuit db 0
	StartAgain db 0 ;if 1 start again 
	
	
	PlayerFileName 	db "xwing.bmp" ,0
	BotFileName db "tief.bmp", 0
	BackGround db "b2.bmp" ,0
	LaserFileName db "Laser.bmp", 0
	LaserMagFileName db "LasMag.bmp", 0
	
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	SmallPicName db 'Pic48X78.bmp',0
	
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ', 0dh, 0ah,'$'
	ErrorFile           db 0
			  
			  			  	
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ? 
	;End BMP DATA
	
	
	;player variables
	xplayer dw 150
	yplayer dw 140
	
	
	;laser variables
	laserspeed dw 14
	
	las1x dw 0
	las1y dw 0
	las1onscreen db 0
	
	las2x dw 0
	las2y dw 0
	las2onscreen db 0
	
	las3x dw 0
	las3y dw 0
	las3onscreen db 0
	
	NumberofLasersLeft db 3 ;currently number of lasers (can get up every x seconds)
	
	;bots stats 
	bot1TimeToDeploy db 5 ;5 mean the bot doesn't have time to deploy (need to random)
	bot1x dw 150
	bot1y dw 0
	bot1onscreen db 0 ;if this equal 0 bot is not on screen 
	bot1move db 0 ; 0-did not move have the chance to move 1- bot is moving untill get stuck or finish move also if 1 no chance to move 
	bot1direction db 0 ;1 - left , 2 - right 
	bot1TravelDistance db 0 ;0- mean nothing, x>0 traveling  
	bot1Destroyed db 0 ;0 - bot1 dont need to be destroyed 1 - destroy bot 1
	Bot1ExCounter db 0 ;couter for every 300 milisec change explotion image
	
	bot2TimeToDeploy db 5 ;5 mean the bot doesn't have time to deploy (need to random)
	bot2x dw 0
	bot2y dw 0
	bot2onscreen db 0 ;if this equal 0 bot is not on screen 
	bot2move db 0 ; 0-did not move have the chance to move 1- bot is moving untill get stuck or finish move also if 1 no chance to move 
	bot2direction db 0 ;1 - left , 2 - right 
	bot2TravelDistance db 0 ;0- mean nothing, x>0 traveling  
	bot2Destroyed db 0 ;bot2 dont need to be destroyed 1 - destroy bot 2
	Bot2ExCounter db 0 ;couter for every 300 milisec change explotion image
	
	bot3TimeToDeploy db 5 ;5 mean the bot doesn't have time to deploy (need to random)
	bot3x dw 0
	bot3y dw 0
	bot3onscreen db 0 ;if this equal 0 bot is not on screen 
	bot3move db 0 ; 0-did not move have the chance to move 1- bot is moving untill get stuck or finish move also if 1 no chance to move 
	bot3direction db 0 ;1 - left , 2 - right 
	bot3TravelDistance db 0 ;0- mean nothing, x>0 traveling  
	bot3Destroyed db 0 ;bot3 dont need to be destroyed 1 - destroy bot 3
	Bot3ExCounter db 0 ;couter for every 300 milisec change explotion image
	
	;bots speed 
	botsspeed dw 5
	
	
	;time 
	milicount db 0
	
	;points 
	points db 0
	 
	
	
	 
	;sound
	
	
	
	;touch 
	Touch db 0
	GameWon db 0
	
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here(pookie bear[yonatan]):
	
	
	call SetGraphic
	
	
OpeningScreen:
	call StartOpening
	cmp [IsQuit], 1 ;if quit icon was pressed in start screen quit 
	je EndGame
	mov ax, 2 ;hide mouse 
	int 33h
	
Loop1:
	
	
    ;delay 
    call time ;delay and inc variables
    call Bots
	call MovePlayerAllaxis
	call MoveLasers
    call DrawEverything 
	call CheckTouch
	call CheckTouchLaser
	
	
	cmp [touch], 1 ;if player touch bot go to GameOver
	je GameOver
	
	cmp [GameWon], 1
	je GameWon1 
	
	
	
	
    jmp Loop1 ;main loop 
	
GameOver:
	call GameOverScreen
	cmp [StartAgain], 1  ;if play again button wasn't  pressed end game 
	jne EndGame 
	
	;if play again button was pressed reset data and go back to loop
	call ResetData
	jmp Loop1 
	
GameWon1:
	call GameWonScreen
	call ResetData
	jmp OpeningScreen
	
	
EndGame:
	call ClearScreen
	call SetTextMod
	


; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	



;reset all data and mouse for starting game again 
proc ResetData

	mov ax, 2
	int 33h
	
	mov [points], 0
	mov [milicount], 0
	mov [touch], 0
	mov [xplayer], 150
	mov [yplayer], 145

	mov [bot1TimeToDeploy], 5
	mov [bot1x], 150
	mov [bot1y], 0
	mov [bot1onscreen], 0
	mov [bot1move], 0
	mov [bot1direction], 0
	mov [bot1TravelDistance], 0
	mov [bot1Destroyed], 0
	mov [Bot1ExCounter], 0
	
	mov [bot2TimeToDeploy], 5
	mov [bot2x], 150
	mov [bot2y], 0
	mov [bot2onscreen], 0
	mov [bot2move], 0
	mov [bot2direction], 0
	mov [bot2TravelDistance], 0
	mov [bot2Destroyed], 0
	mov [Bot2ExCounter], 0
	
	
	mov [bot3TimeToDeploy], 5
	mov [bot3x], 150
	mov [bot3y], 0
	mov [bot3onscreen], 0
	mov [bot3move], 0
	mov [bot3direction], 0
	mov [bot3TravelDistance], 0
	mov [bot3Destroyed], 0
	mov [Bot3ExCounter], 0
	
	
	mov [las1onscreen], 0
	mov [las1x], 0
	mov [las1y], 0
	
	mov [las2onscreen], 0
	mov [las2x], 0
	mov [las2y], 0
	
	
	mov [las3onscreen], 0
	mov [las3x], 0
	mov [las3y], 0

	
	mov [IsMouseOn], 0
	mov [IsAbout], 0
	mov [IsHowToPlay], 0
	mov [IsQuit], 0
	mov [StartAgain], 0
	mov [botsspeed], 3
	mov [laserspeed], 14
	mov [NumberofLasersLeft] ,3 
	mov [Gamewon], 0
	
	call ClearScreen


	ret
endp 






;  __   ______ ___ ___ __  _   __  
;/' _/ / _/ _ \ __| __|  \| |/' _/ 
;`._`.| \_| v / _|| _|| | ' |`._`. 
;|___/ \__/_|_\___|___|_|\__||___/ 



;contain all the code of the opening screen 
proc StartOpening

	call PrintOPS
	mov ax, 1
	int 33h
	mov ax, 0
	int 33h
	mov ax, 1 
	int 33h
	
@@t1: 
	mov [IsMouseOn], 0 ;reset is mouse on for check if mouse is on icon 
  
	
	
	
	;get mouse status
	mov ax, 3
	int 33h
	shr cx, 1
	
@@OpeningScreen:
	
@@CheckPlay:
	cmp cx, 133
	jnae @@CheckAbout
	
@@CheckPlayXb:
	cmp cx,189
	jnbe @@CheckAbout
	
@@CheckPlayy:
	cmp dx, 63
	jnae @@CheckAbout
	
@@CheckPlaya:
	cmp dx, 92 
	jnbe @@CheckAbout
	
@@DoPlay: 
	call PrintOPSP
	mov [IsMouseOn], 1
	mov [OpeningScreenPrint], 0
	mov ax, 3
	int 33h
	cmp bx , 00000001b               
	jne @@t1
	
	
	ret
	
	jmp @@t1
	
	;start check about 
@@CheckAbout:
	cmp cx, 130
	jnae @@CheckHowToPlay
	
@@CheckAboutXb:
	cmp cx,199
	jnbe @@CheckHowToPlay
	
@@CheckAbouty:
	cmp dx, 104
	jnae @@CheckHowToPlay
	
@@CheckAbouta:
	cmp dx, 130
	jnbe @@CheckHowToPlay
	
@@DoAbout: 
	call PrintOPSA
	mov [IsMouseOn], 1
	mov [OpeningScreenPrint], 0
	mov ax, 3
	int 33h
	cmp bx , 00000001b               
	jne @@t1
	
	mov [IsAbout], 1
	jmp @@MidPrint
	
	;end check about 
	
@@CheckHowToPlay:
	cmp cx, 87
	jnae @@CheckQuit
	
@@CheckHowToPlayXb:
	cmp cx,246
	jnbe @@CheckQuit
	
@@CheckHowToPlayy:
	cmp dx, 144
	jnae @@CheckQuit
	
@@CheckHowToPlaya:
	cmp dx, 176
	jnbe @@CheckQuit
	
@@DoHowToPlay: 
	call PrintOPSHTP
	mov [IsMouseOn], 1
	mov [OpeningScreenPrint], 0
	mov ax, 3
	int 33h
	cmp bx , 00000001b               
	jne @@jmpt1
	
	mov [IsHowToPlay], 1
	jmp @@MidPrint

	;here needs to be check for input to enter how to play 
	jmp @@EndCheck
	;end check about 
@@CheckQuit:	
	;start check for quit
		cmp cx, 8
	jnae @@EndCheck
	
@@CheckQuitXb:
	cmp cx,60
	jnbe @@EndCheck
	
@@CheckQuity:
	cmp dx, 3
	jnae @@EndCheck
	
@@CheckQuita:
	cmp dx, 25
	jnbe @@EndCheck
	
@@DoQuity: 
	call PrintOPSQ
	mov [IsMouseOn], 1
	mov [OpeningScreenPrint], 0
	mov ax, 3
	int 33h
	cmp bx , 00000001b               
	jne @@jmpt1
	
	mov [IsQuit], 1
	ret 
	
	;here needs to be check for input to enter how to play 
	jmp @@EndCheck
	;end check quit 
@@jmpt1:
	jmp @@t1
	

@@EndCheck:

	cmp [IsAbout], 1 ;if about was pressed print about screen 
	je @@MidPrint
	
	cmp [IsHowToPlay], 1;if how to play was pressed print how to play 
	je @@MidPrint
	
	cmp [IsMouseOn], 1;if nothing was pressed check if mouse is on icon if no print again the regual start screen 
	je @@jmpt1 
	
	
	cmp [OpeningScreenPrint], 0
	je @@LPrintOPS

	jmp @@t1 
@@LPrintOPS:	
	call PrintOPS
	mov [OpeningScreenPrint], 1
	

	jmp @@t1 ;jmp back to start 
	
@@MidPrint:
	mov ah, 1
	int 16h 
	jnz @@CheckKey
	
	cmp [IsAbout], 1 ;if about was pressed print about screen 
	je @@PrintAbout
	
	cmp [IsHowToPlay], 1;if how to play was pressed print how to play 
	je @@PrintHowToPLay
	
	
@@PrintAbout: 
	call PrintAboutS




	jmp @@MidPrint
@@PrintHowToPLay:
	call PrintHowToPlayS


	jmp @@MidPrint
@@CheckKey:
	mov ah, 0
	int 16h 
	cmp al, 27 ;if escape key was pressed go back to start screen 
	je @@ChangeToStartScreen
	
	jmp @@MidPrint
@@ChangeToStartScreen:
	mov [IsHowToPlay], 0
	mov [IsAbout], 0
	call PrintOPS
	jmp @@t1 
	
	
	jmp @@t1
	

	ret 
endp 

proc GameOverScreen

;labels: play = quit, about = playagain
	call PrintGameOver
	mov ax, 1
	int 33h
	
	
@@t1:
	mov ah, 2
	mov bh, 0
	mov dh, 9
	mov dl, 18
	int 10h 
	mov al, [points]
	mov ah, 0
	call ShowAxDecimal
	
	
	mov [IsMouseOn], 0
	
	mov ax, 3
	int 33h
	shr cx, 1

;switch play and quit 
@@CheckPlay:
	cmp cx, 59
	jnae @@CheckAbout
	
@@CheckPlayXb:
	cmp cx,124
	jnbe @@CheckAbout
	
@@CheckPlayy:
	cmp dx, 97
	jnae @@CheckAbout
	
@@CheckPlaya:
	cmp dx, 131
	jnbe @@CheckAbout
	
@@DoPlay: 
	call PrintGameOverQuit
	mov [IsMouseOn], 1
	mov [PlayAgainPrint], 0
	mov ax, 3
	int 33h
	cmp bx , 00000001b               
	jne  @@Mid
	
	mov [IsQuit], 1 ;quit game after game over 
	ret 
	
	
	;start check about 
@@CheckAbout:
	cmp cx, 153
	jnae @@Mid
	
@@CheckAboutXb:
	cmp cx,261
	jnbe @@Mid
	
@@CheckAbouty:
	cmp dx, 97
	jnae @@Mid
	
@@CheckAbouta:
	cmp dx, 132
	jnbe @@Mid
	
@@DoAbout: 
	call PrintGameOverStartAgain
	mov [IsMouseOn], 1
	mov [PlayAgainPrint], 0
	mov ax, 3
	int 33h
	cmp bx , 00000001b             
	jne @@Mid
	
	mov [StartAgain], 1
	ret 
	
@@Mid:
	
	cmp [IsMouseOn], 1
	je @@t1 
	
	
	
	cmp [PlayAgainPrint], 0
	je @@PrintGameOver23
	
	jmp @@t1
	
@@PrintGameOver23:
	mov [PlayAgainPrint], 1
	call PrintGameOver
	jmp @@t1 
	
	;end check about 




	ret 
endp 

proc GameWonScreen

	call PrintGameWonS
	

	mov ah, 0
	int 16h 


	
	

	ret 
endp 

proc PrintOPS 

	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset OpeningScreenFileName
	call OpenShowBmp

	ret 
endp 

proc PrintOPSP

	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset OpeningScreenPlayFileName
	call OpenShowBmp



	ret 
endp 

proc PrintOPSA
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset OpeningScreenAboutFileName
	call OpenShowBmp

	ret 
endp 

proc PrintOPSHTP


	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset OpeningScreenHowToPlayFileName
	call OpenShowBmp

	ret 

endp 

proc PrintOPSQ

	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset OpeningScreenQuitFileName
	call OpenShowBmp


	ret 
endp

proc PrintAboutS
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset AboutScreenFileName
	call OpenShowBmp

	ret 
endp 

proc PrintHowToPlayS

	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset HowToPlayScreenFileName
	call OpenShowBmp


	ret 
endp 

proc PrintGameOver
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset GameOverFileName
	call OpenShowBmp

	ret 
endp 


proc PrintGameOverQuit
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset GameOverQuitFileName
	call OpenShowBmp
	ret 
endp 

proc PrintGameOverStartAgain
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset GameOverStartAgainFileName
	call OpenShowBmp

	ret 
endp 

proc PrintGameWonS

	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset GameWonFileName
	call OpenShowBmp





	ret
endp 


;___          ___ 
; |  |  |\/| |__  
; |  |  |  | |___ 
           


;Do delay of 100 mili sec + dec time of bots deploy time + count points 
proc time
	
	call Loop100MiliSec3000cycles;delay of 100 milisec 
	inc [milicount]
	cmp [milicount], 10 ;if milicount = 10
	jne @@Cont ; if not cont 
	
	
	
	inc [points] ;inc points 
	
	cmp [points], 250 
	je @@WinGame 
	
	
	
	mov al, [points]
	mov ah, 0
	mov bl, 5
	div bl 
	cmp ah, 0
	jne @@Bot1
	
	cmp [NumberofLasersLeft], 3
	jae @@T1
	
	
	inc [NumberofLasersLeft]

	
@@T1:
	
	cmp  [botsspeed], 26
	je @@Bot1 
	inc [botsspeed]
	inc [laserspeed]
	
;Bots  

@@Bot1: 
	mov [milicount], 0
	cmp [bot1onscreen], 0 ;if bot not on screen 
	jne @@Bot2 
	
	cmp [bot1TimeToDeploy], 4; if bot got timetodeploy 
	jnbe @@Bot2 
	
	dec [bot1TimeToDeploy];dec his time 

@@Bot2: 
	cmp [bot2onscreen], 0
	jne @@Bot3
	
	cmp [bot2TimeToDeploy], 4
	jnbe @@Bot3
	
	dec [bot2TimeToDeploy]

@@Bot3: 
	cmp [bot3onscreen], 0
	jne @@Cont 
	
	cmp [bot3TimeToDeploy], 4
	jnbe @@Cont  
	
	dec [bot3TimeToDeploy]
	
	jmp @@Cont 
	
	
	
@@WinGame:
	mov [GameWon], 1
	


@@Cont: 

	ret 
endp 
; __   __  ___  __  
;|__) /  \  |  /__` 
;|__) \__/  |  .__/ 

; 1. if [botTimeToDeploy] = 5  && [botonscreen] = 0,  == Get respawn time  
;2. if [botTimeToDeploy] = 0 , == Get x for respawn + [botTimeToDeploy] = 5  + [bot1onscreen]=1
;3. if [botTimeToDeploy] = 5 ??? && [botonscreen] =1, == Draw 
;4. if [botonscreen] = 1, == move bots (inc y) 
;5. ;if bot get to end, == [botonscreen]=0  + reset  y           





;Have every necessary bot commad by the order 
;;without draw 
proc Bots

	
	
	call SetBotsTimeToRespawn
	call SetRandomXtoBots
	call SetBotsMoveXAxisRandom 
	call MoveBots
	call MoveBotsXAxis
	call HideBotsIfGetToEnd
	

	

	ret 
endp     

;Set Random Time to respawn for each bot
; if  [bottimetodeply] == 5 && [botonscreen] = 0 ,set respawn time 
proc SetBotsTimeToRespawn

; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
@@Checkbot1:
	cmp [bot1onscreen], 1
	je @@Bot2

@@Checkbot1Time:

	cmp [bot1TimeToDeploy], 4
	jbe @@Bot2

@@SetBot1: 
	mov bx, 0 
	mov dx, 4
	call RandomByCsWord
	
	mov [bot1TimeToDeploy], al 
	
@@Bot2: ;check bot2
	
@@Checkbot2:
	cmp [bot2onscreen], 1
	je @@Bot3

@@Checkbot2Time:

	cmp [bot2TimeToDeploy], 4
	jbe @@Bot3
	
@@SetBot2: 
	mov bx, 0 
	mov dx, 4
	call RandomByCsWord
	
	mov [bot2TimeToDeploy], al 

@@Bot3:


@@Checkbot3:
	cmp [bot3onscreen], 1
	je @@Cont 

@@Checkbot3Time:

	cmp [bot3TimeToDeploy], 4
	jbe @@Cont 

@@SetBot3: 
	mov bx, 0 
	mov dx, 4
	call RandomByCsWord
	
	mov [bot3TimeToDeploy], al 
	
	
	
@@Cont: 

	ret 
endp 


;set bots with random x 
;if [botTimeToDeploy] = 0 , == Get x for respawn + [botTimeToDeploy] = 5  + [bot1onscreen]=1
proc SetRandomXtoBots

	
@@Bot1:
	cmp [bot1TimeToDeploy], 0 ;if bot1 need to deploy 
	je @@Bot1Set;set random x 
	
	jmp @@Bot2;if not check bot2 
	
@@Bot1Set:
	mov bx, 10
	mov dx, 279
	call RandomByCsWord;Do random x to bot1 
	;save the random x in ax 

	
@@Check1to2:
	
	cmp [bot2onscreen], 1;check if bot 2 is on screen
	jne @@Check1to3 ;if not on screen check bot 1 to bot 3
	
	mov bx, [bot2x]  ;mov bot2x to bx 
	cmp bx, ax 
	jb @@CheckBot1to2above;if bo1 random x bigger then bot 2 x
	
	cmp bx, ax 
	je @@Bot1Set ;if bot1 random x equal to bot2 x random again 
	
	jmp @@CheckBot1to2below;if bot1 random x smaller then bot 2

	
@@CheckBot1to2above: ;if random x bigger then bot 2 x 
	mov dx, ax ;mov random x to dx 
	sub dx, bx ;sub from random x bot 2 x 
	cmp dx, 40 ; if it bigger then 40 (space from topleft bot1 to topleft bot2 is 40), (its good)
	ja @@Check1to3;check bot 1 to bot 3

	jmp @@Bot1Set ;if not random x again 
	
@@CheckBot1to2below: ;if random x smaller then bot 2x 
	sub bx, ax ;sub from bot2x random x 
	cmp bx, 40 	; if it bigger then 40 (space from topleft bot2 to topleft bot1 is 40), (its good)
	ja @@Check1to3 ;check bot 1 to bot 3
	
	jmp @@Bot1Set ;if not random again 
	
	
	
@@Check1to3:
	
	cmp [bot3onscreen], 1;check if bot 3 is on screen
	jne @@Bot1Do ;if not on screen random x is good 
	
	mov bx, [bot3x]  ;mov bot3x to bx 
	cmp bx, ax 
	jb @@CheckBot1to3above;if bo1 random x bigger then bot 3 x
	
	cmp bx, ax 
	je @@Bot1Set ;if bot1 random x equal to bot3 x random again 
	
	jmp @@CheckBot1to3below;if bot1 random x smaller then bot 3

	
@@CheckBot1to3above: ;if random x bigger then bot 2 x 
	mov dx, ax ;mov random x to dx 
	sub dx, bx ;sub from random x bot 2 x 
	cmp dx, 40 ; if it bigger then 40 (space from topleft bot1 to topleft bot2 is 40), (its good)
	ja @@Bot1Do ;change variable of bot 1 

	jmp @@Bot1Set ;if not random x again 
	
@@CheckBot1to3below: ;if random x smaller then bot 2x 
	sub bx, ax ;sub from bot2x random x 
	cmp bx, 40 	; if it bigger then 40 (space from topleft bot2 to topleft bot1 is 40), (its good)
	ja @@Bot1Do ;change variable of bot 1
	
	jmp @@Bot1Set ;if not random again 
	
	
@@Bot1Do:
;[botTimeToDeploy] = 5  + [botonscreen]=1
	mov [bot1x], ax 
	mov [bot1TimeToDeploy], 5
	mov [bot1onscreen], 1
	
	
	
@@Bot2:
	cmp [bot2TimeToDeploy], 0 ;if bot2 need to deploy 
	je @@Bot2Set;set random x 
	
	jmp @@Bot3;if not check bot2 
	
@@Bot2Set:
	mov bx, 10
	mov dx, 279
	call RandomByCsWord;Do random x to bot2
	;save the random x in ax 

	
@@Check2to1:
	
	cmp [bot1onscreen], 1;check if bot 1 is on screen
	jne @@Check2to3 ;if not on screen check bot 3
	
	mov bx, [bot1x]  ;mov bot1x to bx 
	cmp bx, ax 
	jb @@CheckBot2to1above;if bot2 random x bigger then bot 1 x
	
	cmp bx, ax 
	je @@Bot2Set ;if bot2 random x equal to bot1 x random again 
	
	jmp @@CheckBot2to1below;if bot2 random x smaller then bot 1

	
@@CheckBot2to1above: ;if random x bigger then bot 1 x 
	mov dx, ax ;mov random x to dx 
	sub dx, bx ;sub from random x bot 1 x 
	cmp dx, 40 ; if it bigger then 40 (space from topleft bot2 to topleft bot1 is 40), (its good)
	ja @@Check2to3;check bot 2 to bot 3

	jmp @@Bot2Set ;if not random x again 
	
@@CheckBot2to1below: ;if random x smaller then bot 2x 
	sub bx, ax ;sub from bot2x random x 
	cmp bx, 40 	; if it bigger then 40 (space from topleft bot2 to topleft bot1 is 40), (its good)
	ja @@Check2to3 ;check bot 1 to bot 3
	
	jmp @@Bot2Set ;if not random again 
	
	
	
@@Check2to3:
	
	cmp [bot3onscreen], 1;check if bot 3 is on screen
	jne @@Bot2Do ;if not on screen random is good 
	
	mov bx, [bot3x]  ;mov bot3x to bx 
	cmp bx, ax 
	jb @@CheckBot2to3above;if bot2 random x bigger then bot 3 x
	
	cmp bx, ax 
	je @@Bot2Set ;if bot2 random x equal to bot3 x random again 
	
	jmp @@CheckBot2to3below;if bot2 random x smaller then bot 3

	
@@CheckBot2to3above: ;if random x bigger then bot 3 x 
	mov dx, ax ;mov random x to dx 
	sub dx, bx ;sub from random x bot 3 x 
	cmp dx, 40 ; if it bigger then 40 (space from topleft bot1 to topleft bot2 is 40), (its good)
	ja @@Bot2Do ;change variable of bot 1 

	jmp @@Bot2Set ;if not random x again 
	
@@CheckBot2to3below: ;if random x smaller then bot 2x 
	sub bx, ax ;sub from bot2x random x 
	cmp bx, 40 	; if it bigger then 40 (space from topleft bot2 to topleft bot1 is 40), (its good)
	ja @@Bot2Do ;change variable of bot 1
	
	jmp @@Bot2Set ;if not random again 
	
	
@@Bot2Do:
;[botTimeToDeploy] = 5  + [botonscreen]=1
	mov [bot2x], ax 
	mov [bot2TimeToDeploy], 5
	mov [bot2onscreen], 1
	




@@Bot3: 

	cmp [bot3TimeToDeploy], 0 ;if bot3 need to deploy 
	je @@Bot3Set;set random x 
	
	jmp @@Cont;if not finish
	
@@Bot3Set:
	mov bx, 10
	mov dx, 279
	call RandomByCsWord;Do random x to bot3
	;save the random x in ax 

	
@@Check3to1:
	
	cmp [bot1onscreen], 1;check if bot 1 is on screen
	jne @@Check3to2 ;if not on screen check bot 2
	
	mov bx, [bot1x]  ;mov bot1x to bx 
	cmp bx, ax 
	jb @@CheckBot3to1above;if bot3 random x bigger then bot 1 x
	
	cmp bx, ax 
	je @@Bot3Set ;if bot3 random x equal to bot1 x random again 
	
	jmp @@CheckBot3to1below;if bot3 random x smaller then bot 1

	
@@CheckBot3to1above: ;if random x bigger then bot 1 x 
	mov dx, ax ;mov random x to dx 
	sub dx, bx ;sub from random x bot 1 x 
	cmp dx, 40 ; if it bigger then 40 (space from topleft bot3 to topleft bot1 is 40), (its good)
	ja @@Check3to2;check bot 3 to bot 2

	jmp @@Bot3Set ;if not random x again 
	
@@CheckBot3to1below: ;if random x smaller then bot 2x 
	sub bx, ax ;sub from bot2x random x 
	cmp bx, 40 	; if it bigger then 40 (space from topleft bot1 to topleft bot3 is 40), (its good)
	ja @@Check3to2 ;check bot 1 to bot 3
	
	jmp @@Bot3Set ;if not random again 
	
	
	
@@Check3to2:
	
	cmp [bot2onscreen], 1;check if bot 2 is on screen
	jne @@Bot3Do ;if not on screen random is good 
	
	mov bx, [bot2x]  ;mov bot2x to bx 
	cmp bx, ax 
	jb @@CheckBot3to2above;if bot3 random x bigger then bot 2 x
	
	cmp bx, ax 
	je @@Bot3Set ;if bot3 random x equal to bot2 x random again 
	
	jmp @@CheckBot3to2below;if bot3 random x smaller then bot 2

	
@@CheckBot3to2above: ;if random x bigger then bot 2 x 
	mov dx, ax ;mov random x to dx 
	sub dx, bx ;sub from random x bot 2 x 
	cmp dx, 40 ; if it bigger then 40 (space from topleft bot1 to topleft bot2 is 40), (its good)
	ja @@Bot3Do ;change variable of bot 1 

	jmp @@Bot3Set ;if not random x again 
	
@@CheckBot3to2below: ;if random x smaller then bot 2x 
	sub bx, ax ;sub from bot2x random x 
	cmp bx, 40 	; if it bigger then 40 (space from topleft bot2 to topleft bot1 is 40), (its good)
	ja @@Bot3Do ;change variable of bot 1
	
	jmp @@Bot3Set ;if not random again 
	
	
@@Bot3Do:
;[botTimeToDeploy] = 5  + [botonscreen]=1
	mov [bot3x], ax 
	mov [bot3TimeToDeploy], 5
	mov [bot3onscreen], 1
	

@@Cont: 

	ret 
endp 


;Draw Bots on screen
;if  [botonscreen] =1, == Draw 
proc DrawBots

@@Bot1:

	cmp [bot1onscreen], 1 ;if bot 1 is on screan draw 
	jne @@Bot2 ;if not go to the next bot 
	
	call DrawBot1
	
@@Bot2: 

	cmp [bot2onscreen], 1
	jne @@Bot3 
	
	call DrawBot2

@@Bot3: 

	cmp [bot3onscreen], 1
	jne @@Cont 
	
	call DrawBot3


@@Cont: 

	ret 
endp 


;move bots
;if [botonscreen] = 1 && [bot1Destroyed] ==0  == move bots (add to y 5) 
proc MoveBots

	cmp [bot1onscreen], 1
	jne @@Bot2 
	cmp [bot1Destroyed], 0
	jne @@MoveBot1less
	
	mov ax, [bot1y] 
	add ax, [botsspeed]
	mov [bot1y], ax 
	jmp @@Bot2
	
@@MoveBot1less:
	mov ax, [botsspeed]
	mov bl, 2
	div bl 
	mov ah, 0
	add ax, [bot1y]
	mov [bot1y], ax 
	
	
	
@@Bot2: 	
	cmp [bot2onscreen], 1
	jne @@Bot3
	cmp [bot2Destroyed], 0
	jne @@MoveBot2less
	mov ax, [bot2y] 
	add ax, [botsspeed]
	mov [bot2y], ax 
	jmp @@Bot3
	
@@MoveBot2less:
	 
	mov ax, [botsspeed]
	mov bl, 2
	div bl 
	mov ah, 0
	add ax, [bot2y]
	mov [bot2y], ax 
	
@@Bot3: 
	cmp [bot3onscreen], 1
	jne @@Cont 
	cmp [bot3Destroyed], 0
	jne @@MoveBot3less
	mov ax, [bot3y] 
	add ax, [botsspeed]
	mov [bot3y], ax 
	jmp @@Cont
	
@@MoveBot3less:
	 
	mov ax, [botsspeed]
	mov bl, 2
	div bl 
	mov ah, 0
	add ax, [bot2y]
	mov [bot2y], ax 
	
@@Cont: 

	ret 
endp 


; get random travel distance and direction to move
;if [botmove] = 0 && 10% == [botdirection] 1 or 2 , [botTravelDistance] = 10 - 255
proc SetBotsMoveXAxisRandom 


@@Bot1:
	cmp [bot1onscreen], 1
	jne @@Bot2
	cmp [bot1y], 60
	jnb @@Bot2 
	cmp [bot1move], 0 ;if bot is moving or moved next bot 
	jne @@Bot2 
	mov bl, 1
	mov bh, 16
	call RandomByCs
	cmp al, 10 ;if random number not equal 10 dont set random distance and direction 
	jne @@Bot2
	mov bl, 1
	mov bh, 2
	call RandomByCs
	mov [bot1direction], al ;random direction 
	mov bl, 10
	mov bh, 100
	call RandomByCs
	mov [bot1TravelDistance], al ;random TravelDistnce
	
	mov [bot1move], 1
	

@@Bot2:
	cmp [bot2onscreen], 1
	jne @@Bot3
	cmp [bot2y], 60
	jnb @@Bot3 
	cmp [bot2move], 0 ;if bot is moving or moved next bot 
	jne @@Bot3
	mov bl, 1
	mov bh, 20
	call RandomByCs
	cmp al, 10 ;if random number not equal 10 set random distance and direction 
	jne @@Bot3
	mov bl, 1
	mov bh, 2
	call RandomByCs
	mov [bot2direction], al ;random direction 
	mov bl, 10
	mov bh, 100
	call RandomByCs
	mov [bot2TravelDistance], al ;random TravelDistnce
	
	mov [bot2move], 1
	
@@Bot3:
	cmp [bot3onscreen], 1
	jne @@Cont 
	cmp [bot3y], 60
	jnb @@Cont 
	cmp [bot3move], 0 ;if bot is moving or moved cont 
	jne @@Cont  
	mov bl, 1
	mov bh, 20
	call RandomByCs
	cmp al, 10 ;if random number not equal 10 set random distance and direction 
	jne @@Cont
	mov bl, 1
	mov bh, 2
	call RandomByCs
	mov [bot3direction], al 
	mov bl, 10
	mov bh, 100
	call RandomByCs
	mov [bot3TravelDistance], al

	mov [bot3move], 1

@@Cont: 


	ret 
endp 


	

;[botTravelDistance] > 0 ==move to [botdirection]
;dec [botTravelDistance] 
;if bot enter other bot column or touch bounderys stop moving in x axis 
proc MoveBotsXAxis 

@@Bot1:
	cmp [bot1onscreen], 1
	jne @@JmpBot2 
	
	cmp [bot1TravelDistance], 0 ;if no travel distance check bot2 
	je @@JmpBot2

	cmp [bot1direction], 1 ;if move direction is 1 check for left move
	je @@Bot1Left
	
	jmp @@Bot1Right; if move direction is 2 check for right move 
	
	
@@Bot1Left:

	

@@Bot1LeftBounderys:
	mov ax, [bot1x]
	sub ax, 5
	cmp ax, 10
	jnbe @@Check1to2Left ;;;;

	jmp @@Bot1Stop

@@Check1to2Left:
	
	cmp [bot2onscreen], 1;check if bot 2 is on screen
	jne @@Check1to3left ;if not on screen check bot 1 to bot 3
	
	mov bx, [bot2x]  ;mov bot2x to bx 
	mov ax, [bot1x] ; mov bot1x to ax 
	cmp ax, bx 
	jna @@Check1to3Left;if bot2 is right to bot1 check 1 to 3 

	sub ax, 5 ;sub from "bot1x" 5 (5 x per move)
	sub ax, bx ;sub from bot1x bot2x to check if bot1 not in bot 2 column 
	cmp ax, 40
	jnae @@Bot1Stop ;if not good stop bot 1 from going left 
	

@@Check1to3left:
	cmp [bot3onscreen], 1;check if bot 3 is on screen
	jne @@Bot1DoLeft;if not on screen its good
	
	mov bx, [bot3x]  ;mov bot3x to bx 
	mov ax, [bot1x] ; mov bot1x to ax 
	cmp ax, bx 
	jna @@Bot1DoLeft;if bot3 is right to bot1 its good 

	sub ax, 5 ;sub from "bot1x" 5 (5 x per move)
	sub ax, bx ;sub from bot1x bot3x to check if bot1 not in bot 3 column 
	cmp ax, 40
	jnae @@Bot1Stop ;if not good stop bot 1 from going left 
	
	
	jmp @@Bot1DoLeft
	
@@JmpBot2:
	jmp @@Bot2 ;Cant jump far use this point to get to bot2 

@@Bot1Right:


@@Bot1RightBounderys:
	mov ax, [bot1x]
	add ax, 5
	cmp ax, 278
	jna @@Check1to2Right

	jmp @@Bot1Stop

@@Check1to2Right:
	
	cmp [bot2onscreen], 1;check if bot 2 is on screen
	jne @@Check1to3Right ;if not on screen check bot 1 to bot 3
	
	mov bx, [bot2x]  ;mov bot2x to bx 
	mov ax, [bot1x] ; mov bot1x to ax 
	cmp ax, bx 
	ja @@Check1to3Right;if bot2 is left to bot1 check 1 to 3 

	add ax, 5 ;add to "bot1x" 5 (5 x per move)
	sub bx, ax ;sub from bot2x bot1x to check if bot1 not in bot 2 column 
	cmp bx, 40
	jnae @@Bot1Stop ;if not good stop bot 1 from going right 
	

@@Check1to3Right:
	cmp [bot3onscreen], 1;check if bot 3 is on screen
	jne @@Bot1DoRight;if not on screen its good
	
	mov bx, [bot3x]  ;mov bot3x to bx 
	mov ax, [bot1x] ; mov bot1x to ax 
	cmp ax, bx 
	ja @@Bot1DoRight;if bot3 is left to bot1 its good 

	add ax, 5 ;add to "bot1x" 5 (5 x per move)
	sub bx, ax ;sub from bot3x bot1x to check if bot1 not in bot 3 column 
	cmp bx, 40
	jnae @@Bot1Stop ;if not good stop bot 1 from going Right
	
	
	jmp @@Bot1DoRight


	
@@Bot1Stop:
;Bot 1 got to other bot or bounderys stop his move
	mov [bot1direction], 0
	mov [bot1TravelDistance], 0

	jmp @@Bot2
@@Bot1DoLeft:
;Move Bot1 x to left 

	cmp [bot1Destroyed], 0 ;if bot1 is getting destroyed move him slower 
	jne @@Bot1DoLeftSlower
	mov ax, [bot1x]
	sub ax, 5
	mov [bot1x], ax 
	
	mov al, [bot1TravelDistance]
	sub al, 5 
	mov [bot1TravelDistance], al
	jmp @@Bot2 
@@Bot1DoLeftSlower:
	mov ax, [bot1x]
	sub ax, 3
	mov [bot1x], ax 
	
	mov al, [bot1TravelDistance]
	sub al, 3
	mov [bot1TravelDistance], al
	
	jmp @@Bot2 

@@Bot1DoRight:
;Move bot1 x to right 

	cmp [bot1Destroyed], 0 ;if bot1 is getting destroyed move him slower 
	jne @@Bot1DoRightSlower
	
	mov ax, [bot1x]
	add ax, 5
	mov [bot1x], ax 
	
	mov al, [bot1TravelDistance]
	sub al, 5 
	mov [bot1TravelDistance], al

	jmp @@Bot2 
	
@@Bot1DoRightSlower:
	mov ax, [bot1x]
	add ax, 3
	mov [bot1x], ax 
	
	mov al, [bot1TravelDistance]
	sub al, 3
	mov [bot1TravelDistance], al

	jmp @@Bot2 
	
@@Bot2:	
;;bot 2

	cmp [bot2onscreen], 1
	jne @@JmpBot3
	
	cmp [bot2TravelDistance], 0 ;if no travel distance check bot3
	je @@JmpBot3

	cmp [bot2direction], 1 ;if move direction is 1 check for left move
	je @@Bot2Left
	
	jmp @@Bot2Right; if move direction is 2 check for right move 
	
	
@@Bot2Left:

	

@@Bot2LeftBounderys:
	mov ax, [bot2x]
	sub ax, 5
	cmp ax, 10
	jnbe @@Check2to1Left ;;;;

	jmp @@Bot2Stop

@@Check2to1Left:
	
	cmp [bot1onscreen], 1;check if bot 2 is on screen
	jne @@Check2to3left ;if not on screen check bot 1 to bot 3
	
	mov bx, [bot1x]  ;mov bot2x to bx 
	mov ax, [bot2x] ; mov bot1x to ax 
	cmp ax, bx 
	jna @@Check2to3Left;if bot2 is right to bot1 check 1 to 3 

	sub ax, 5 ;sub from "bot1x" 5 (5 x per move)
	sub ax, bx ;sub from bot1x bot2x to check if bot1 not in bot 2 column 
	cmp ax, 40
	jnae @@Bot2Stop ;if not good stop bot 1 from going left 
	

@@Check2to3left:
	cmp [bot3onscreen], 1;check if bot 3 is on screen
	jne @@Bot2DoLeft;if not on screen its good
	
	mov bx, [bot3x]  ;mov bot3x to bx 
	mov ax, [bot2x] ; mov bot1x to ax 
	cmp ax, bx 
	jna @@Bot2DoLeft;if bot3 is right to bot1 its good 

	sub ax, 5 ;sub from "bot1x" 5 (5 x per move)
	sub ax, bx ;sub from bot1x bot3x to check if bot1 not in bot 3 column 
	cmp ax, 40
	jnae @@Bot2Stop ;if not good stop bot 1 from going left 
	
	
	jmp @@Bot2DoLeft
	
@@JmpBot3:
	jmp @@Bot3 ;Cant jump far use this point to get to bot2 

@@Bot2Right:


@@Bot2RightBounderys:
	mov ax, [bot2x]
	add ax, 5
	cmp ax, 278
	jna @@Check2to1Right

	jmp @@Bot2Stop

@@Check2to1Right:
	
	cmp [bot1onscreen], 1;check if bot 2 is on screen
	jne @@Check2to3Right ;if not on screen check bot 1 to bot 3
	
	mov bx, [bot1x]  ;mov bot2x to bx 
	mov ax, [bot2x] ; mov bot1x to ax 
	cmp ax, bx  ;;;;;;;;;;;;;;;;;
	ja @@Check2to3Right;if bot2 is left to bot1 check 1 to 3 

	add ax, 5 ;add to "bot1x" 5 (5 x per move)
	sub bx, ax ;sub from bot2x bot1x to check if bot1 not in bot 2 column 
	cmp bx, 40
	jnae @@Bot2Stop ;if not good stop bot 1 from going right 
	

@@Check2to3Right:
	cmp [bot3onscreen], 1;check if bot 3 is on screen
	jne @@Bot2DoRight;if not on screen its good
	
	mov bx, [bot3x]  ;mov bot3x to bx 
	mov ax, [bot2x] ; mov bot1x to ax 
	cmp ax ,bx 
	ja @@Bot2DoRight;if bot3 is left to bot1 its good 

	add ax, 5 ;add to "bot1x" 5 (5 x per move)
	sub bx, ax ;sub from bot3x bot1x to check if bot1 not in bot 3 column 
	cmp bx, 40
	jnae @@Bot2Stop ;if not good stop bot 1 from going Right
	
	
	jmp @@Bot2DoRight


	
@@Bot2Stop:
;Bot 1 got to other bot or bounderys stop his move
	mov [bot2direction], 0
	mov [bot2TravelDistance], 0

	jmp @@Bot3
@@Bot2DoLeft:
;Move Bot1 x to left 
	cmp [bot2Destroyed], 0
	jne @@Bot2DoLeftSlower
	mov ax, [bot2x]
	sub ax, 5
	mov [bot2x], ax 
	
	mov al, [bot2TravelDistance]
	sub al, 5 
	mov [bot2TravelDistance], al
	
	jmp @@Bot3
	
@@Bot2DoLeftSlower:
	
	mov ax, [bot2x]
	sub ax, 3
	mov [bot2x], ax 
	
	mov al, [bot2TravelDistance]
	sub al, 3
	mov [bot2TravelDistance], al
	
	jmp @@Bot3

@@Bot2DoRight:
;Move bot1 x to right 
	cmp [bot2Destroyed], 0
	jne @@Bot2DoRightSlower
	mov ax, [bot2x]
	add ax, 5
	mov [bot2x], ax 
	
	mov al, [bot2TravelDistance]
	sub al, 5 
	mov [bot2TravelDistance], al

	jmp @@Bot3
	
@@Bot2DoRightSlower:
	
	mov ax, [bot2x]
	add ax, 3
	mov [bot2x], ax 
	
	mov al, [bot2TravelDistance]
	sub al, 3
	mov [bot2TravelDistance], al

	jmp @@Bot3
	

@@Bot3: 
;;bot 3

	cmp [bot3onscreen], 1
	jne @@JmpCont
	
	cmp [bot3TravelDistance], 0 ;if no travel distance check bot3
	je @@JmpCont

	cmp [bot3direction], 1 ;if move direction is 1 check for left move
	je @@Bot3Left
	
	jmp @@Bot3Right; if move direction is 2 check for right move 
	
	
@@Bot3Left:

	

@@Bot3LeftBounderys:
	mov ax, [bot3x]
	sub ax, 5
	cmp ax, 10
	jnbe @@Check3to1Left ;;;;

	jmp @@Bot3Stop

@@Check3to1Left:
	
	cmp [bot1onscreen], 1;check if bot 2 is on screen
	jne @@Check3to2left ;if not on screen check bot 1 to bot 3
	
	mov bx, [bot1x]  ;mov bot2x to bx 
	mov ax, [bot3x] ; mov bot1x to ax 
	cmp ax, bx 
	jna @@Check3to2Left;if bot2 is right to bot1 check 1 to 3 

	sub ax, 5 ;sub from "bot1x" 5 (5 x per move)
	sub ax, bx ;sub from bot1x bot2x to check if bot1 not in bot 2 column 
	cmp ax, 40
	jnae @@Bot3Stop ;if not good stop bot 1 from going left 
	

@@Check3to2left:
	cmp [bot2onscreen], 1;check if bot 3 is on screen
	jne @@Bot3DoLeft;if not on screen its good
	
	mov bx, [bot2x]  ;mov bot3x to bx 
	mov ax, [bot3x] ; mov bot1x to ax 
	cmp ax, bx 
	jna @@Bot3DoLeft;if bot3 is right to bot1 its good 

	sub ax, 5 ;sub from "bot1x" 5 (5 x per move)
	sub ax, bx ;sub from bot1x bot3x to check if bot1 not in bot 3 column 
	cmp ax, 40
	jnae @@Bot3Stop ;if not good stop bot 1 from going left 
	
	
	jmp @@Bot3DoLeft
	
@@JmpCont:
	jmp @@Cont ;Cant jump far use this point to get to bot2 

@@Bot3Right:


@@Bot3RightBounderys:
	mov ax, [bot3x]
	add ax, 5
	cmp ax, 278
	jna @@Check3to1Right

	jmp @@Bot3Stop

@@Check3to1Right:
	
	cmp [bot1onscreen], 1;check if bot 2 is on screen
	jne @@Check3to2Right ;if not on screen check bot 1 to bot 3
	
	mov bx, [bot1x]  ;mov bot2x to bx 
	mov ax, [bot3x] ; mov bot1x to ax 
	cmp ax, bx 
	ja @@Check3to2Right;if bot2 is left to bot1 check 1 to 3 

	add ax, 5 ;add to "bot1x" 5 (5 x per move)
	sub bx, ax ;sub from bot2x bot1x to check if bot1 not in bot 2 column 
	cmp bx, 40
	jnae @@Bot3Stop ;if not good stop bot 1 from going right 
	

@@Check3to2Right:
	cmp [bot2onscreen], 1;check if bot 3 is on screen
	jne @@Bot3DoRight;if not on screen its good
	
	mov bx, [bot2x]  ;mov bot3x to bx 
	mov ax, [bot3x] ; mov bot1x to ax 
	cmp ax, bx 
	ja @@Bot3DoRight;if bot3 is left to bot1 its good 

	add ax, 5 ;add to "bot1x" 5 (5 x per move)
	sub bx, ax ;sub from bot3x bot1x to check if bot1 not in bot 3 column 
	cmp bx, 40
	jnae @@Bot3Stop ;if not good stop bot 1 from going Right
	
	
	jmp @@Bot3DoRight


	
@@Bot3Stop:
;Bot 1 got to other bot or bounderys stop his move
	mov [bot3direction], 0
	mov [bot3TravelDistance], 0

	jmp @@Cont
@@Bot3DoLeft:
;Move Bot1 x to left 
	cmp [bot3Destroyed], 0
	jne @@Bot3DoLeftSlower
	mov ax, [bot3x]
	sub ax, 5
	mov [bot3x], ax 
	
	mov al, [bot3TravelDistance]
	sub al, 5 
	mov [bot3TravelDistance], al
	
	jmp @@Cont
	
@@Bot3DoLeftSlower:
	
	mov ax, [bot3x]
	sub ax, 3
	mov [bot3x], ax 
	
	mov al, [bot3TravelDistance]
	sub al, 3
	mov [bot3TravelDistance], al
	
	jmp @@Cont

@@Bot3DoRight:
;Move bot1 x to right 
	cmp [bot3Destroyed], 0
	jne @@Bot3DoRightSlower
	mov ax, [bot3x]
	add ax, 5
	mov [bot3x], ax 
	
	mov al, [bot3TravelDistance]
	sub al, 5 
	mov [bot3TravelDistance], al

	jmp @@Cont
	
@@Bot3DoRightSlower:
	
	mov ax, [bot3x]
	add ax, 3
	mov [bot3x], ax 
	
	mov al, [bot3TravelDistance]
	sub al, 3
	mov [bot3TravelDistance], al

	jmp @@Cont
	
@@Cont:


	ret 
endp  

;Hide bot if they get to end (y)
;if bot get to end, == [botonscreen]=0  + reset  y  
proc HideBotsIfGetToEnd

@@Bot1:

	mov ax, [bot1y]
	cmp ax, 162
	jae @@Bot1Hide 
	
	jmp @@Bot2
	
@@Bot1Hide: 
	mov [bot1y], 0
	mov [bot1onscreen], 0
	mov [bot1move], 0
	mov [bot1direction], 0
	mov [bot1TravelDistance], 0
@@Bot2:

	mov ax, [bot2y]
	cmp ax, 162
	jae @@Bot2Hide 
	
	jmp @@Bot3
	
@@Bot2Hide: 
	mov [bot2y], 0
	mov [bot2onscreen], 0
	mov [bot2move], 0
	mov [bot2direction], 0
	mov [bot2TravelDistance], 0
@@Bot3:

	mov ax, [bot3y]
	cmp ax, 162
	jae @@Bot3Hide 
	
	jmp @@Cont 
	
@@Bot3Hide: 
	mov [bot3y], 0
	mov [bot3onscreen], 0
	mov [bot3move], 0
	mov [bot3direction], 0
	mov [bot3TravelDistance], 0
	
@@Cont:



	ret 
endp 


;Print explotions of bots after everything chnage variables back to waiting for spawn 
proc PrintExplosions

	;if not on screen and didn't got shot check next bot 
	cmp [bot1onscreen], 0 
	je @@Bot2

	cmp [bot1Destroyed], 0 
	je @@Bot2
	
	inc [Bot1ExCounter]
	
	cmp [bot1Destroyed], 1
	je @@B1Ex1
	
	
	cmp [bot1Destroyed], 2
	je @@B1Ex2
	
	cmp [bot1Destroyed], 3
	je @@B1Ex3
	
	cmp [bot1Destroyed], 4
	je @@B1Ex4
	
	
@@B1Ex1:
	mov [BmpColSize], 40
	mov [BmpRowSize], 39
	mov ax, [bot1x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot1y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP1FileName
	call MyBmp


	jmp @@EndBot1Ex
@@B1Ex2:
	mov [BmpColSize], 45
	mov [BmpRowSize], 45
	mov ax, [bot1x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot1y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP2FileName
	call MyBmp


	jmp @@EndBot1Ex
@@B1Ex3:
	mov [BmpColSize], 52
	mov [BmpRowSize], 52
	mov ax, [bot1x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot1y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP3FileName
	call MyBmp


	jmp @@EndBot1Ex
@@B1Ex4:
	mov [BmpColSize], 60
	mov [BmpRowSize], 55
	mov ax, [bot1x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot1y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP4FileName
	call MyBmp
	
	
	
	jmp @@EndBot1Ex
	
	
	
@@EndBot1Ex:

	cmp [Bot1ExCounter], 3
	je @@Bot1Change
	
	inc [Bot1ExCounter]
	
	jmp @@Bot2 
	
	
@@Bot1Change:
	mov [Bot1ExCounter], 0
	cmp [bot1Destroyed], 4
	je @@StopBot1
	
	inc [bot1Destroyed]
	jmp @@Bot2 
@@StopBot1:
	mov [bot1Destroyed], 0
	mov [bot1onscreen], 0 
	mov [bot1TimeToDeploy], 5
	mov [bot1y], 0
	mov [bot1move], 0
	mov [bot1direction], 0
	mov [bot1TravelDistance], 0
	
	

@@Bot2:

	;if not on screen and didn't got shot check next bot 
	cmp [bot2onscreen], 0 
	je @@Bot3

	cmp [bot2Destroyed], 0 
	je @@Bot3
	
	inc [Bot2ExCounter]
	
	cmp [bot2Destroyed], 1
	je @@B2Ex1
	
	
	cmp [bot2Destroyed], 2
	je @@B2Ex2
	
	cmp [bot2Destroyed], 3
	je @@B2Ex3
	
	cmp [bot2Destroyed], 4
	je @@B2Ex4
	
	
@@B2Ex1:
	mov [BmpColSize], 40
	mov [BmpRowSize], 39
	mov ax, [bot2x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot2y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP1FileName
	call MyBmp


	jmp @@EndBot2Ex
@@B2Ex2:
	mov [BmpColSize], 45
	mov [BmpRowSize], 45
	mov ax, [bot2x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot2y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP2FileName
	call MyBmp


	jmp @@EndBot2Ex
@@B2Ex3:
	mov [BmpColSize], 52
	mov [BmpRowSize], 52
	mov ax, [bot2x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot2y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP3FileName
	call MyBmp


	jmp @@EndBot2Ex
@@B2Ex4:
	mov [BmpColSize], 60
	mov [BmpRowSize], 55
	mov ax, [bot2x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot2y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP4FileName
	call MyBmp
	
	
	
	jmp @@EndBot2Ex
	
	
	
@@EndBot2Ex:

	cmp [Bot2ExCounter], 3
	je @@Bot2Change
	
	inc [Bot2ExCounter]
	
	jmp @@Bot3
	
	
@@Bot2Change:
	mov [Bot2ExCounter], 0
	cmp [bot2Destroyed], 4
	je @@StopBot2
	
	inc [bot2Destroyed]
	jmp @@Bot3
@@StopBot2:
	mov [bot2Destroyed], 0
	mov [bot2onscreen], 0 
	mov [bot2TimeToDeploy], 5
	mov [bot2y], 0
	mov [bot2move], 0
	mov [bot2direction], 0
	mov [bot2TravelDistance], 0

@@Bot3:
	;if not on screen and didn't got shot check next bot 
	cmp [bot3onscreen], 0 
	je @@Cont

	cmp [bot3Destroyed], 0 
	je @@Cont
	
	inc [Bot3ExCounter]
	
	cmp [bot3Destroyed], 1
	je @@B3Ex1
	
	
	cmp [bot3Destroyed], 2
	je @@B3Ex2
	
	cmp [bot3Destroyed], 3
	je @@B3Ex3
	
	cmp [bot3Destroyed], 4
	je @@B3Ex4
	
	
@@B3Ex1:
	mov [BmpColSize], 40
	mov [BmpRowSize], 39
	mov ax, [bot3x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot3y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP1FileName
	call MyBmp


	jmp @@EndBot3Ex
@@B3Ex2:
	mov [BmpColSize], 45
	mov [BmpRowSize], 45
	mov ax, [bot3x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot3y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP2FileName
	call MyBmp


	jmp @@EndBot3Ex
@@B3Ex3:
	mov [BmpColSize], 52
	mov [BmpRowSize], 52
	mov ax, [bot3x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot3y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP3FileName
	call MyBmp


	jmp @@EndBot3Ex
@@B3Ex4:
	mov [BmpColSize], 60
	mov [BmpRowSize], 55
	mov ax, [bot3x]
	sub ax, 7
	mov [BmpLeft], ax
	mov ax, [bot3y]
	sub ax, 4
	mov [BmpTop], ax 
	mov dx, offset EXP4FileName
	call MyBmp
	
	
	
	jmp @@EndBot3Ex
	
	
	
@@EndBot3Ex:

	cmp [Bot3ExCounter], 3
	je @@Bot3Change
	
	inc [Bot3ExCounter]
	
	jmp @@Cont
	
	
@@Bot3Change:
	mov [Bot3ExCounter], 0
	cmp [bot3Destroyed], 4
	je @@StopBot3
	
	inc [bot3Destroyed]
	jmp @@Cont
@@StopBot3:
	mov [bot3Destroyed], 0
	mov [bot3onscreen], 0 
	mov [bot3TimeToDeploy], 5
	mov [bot3y], 0
	mov [bot3move], 0
	mov [bot3direction], 0
	mov [bot3TravelDistance], 0
	
	
@@Cont:



	ret 
endp


;Draw bot1	
proc DrawBot1

	mov [BmpColSize], 40
	mov [BmpRowSize], 39 
	mov ax, [bot1y]
	mov [BmpTop], ax 
	mov ax, [bot1x]
	mov [BmpLeft], ax 

	mov dx, offset BotFileName
	call MyBmp
	

	ret 
endp 
	
;Draw bot2	
proc DrawBot2

	mov [BmpColSize], 40
	mov [BmpRowSize], 39 
	mov ax, [bot2y]
	mov [BmpTop], ax 
	mov ax, [bot2x]
	mov [BmpLeft], ax 

	mov dx, offset BotFileName
	call MyBmp
	

	ret 
endp 

;Draw bot3
proc DrawBot3

	mov [BmpColSize], 40
	mov [BmpRowSize], 39 
	mov ax, [bot3y]
	mov [BmpTop], ax 
	mov ax, [bot3x]
	mov [BmpLeft], ax 

	mov dx, offset BotFileName
	call MyBmp
	

	ret 
endp 


; __   __            
;|  \ |__)  /\  |  | 
;|__/ |  \ /~~\ |/\| 
                    	
	
;Draw Everything 
;draw bots over player becuase touch is checked by colors 
proc DrawEverything
	
	call DrawBackGround;first draw background (spaceships over it)
	call PrintAllLasMag
	call DrawPlayer
	call DrawBots
	call PrintLasers
	call PrintExplosions
	
	
	
	
	;print points 
	
	mov ah,2 
	mov bh, 0
	mov dh, 0
	mov dl, 0
	int 10h
	mov al, [points]
	mov ah, 0
	call ShowAxDecimal
	
	

	ret 
endp 



; __        __        __   __   __             __  
;|__)  /\  /  ` |__/ / _` |__) /  \ |  | |\ | |  \ 
;|__) /~~\ \__, |  \ \__> |  \ \__/ \__/ | \| |__/ 
                                                  

;Draw BackGround 
proc DrawBackGround
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov [BmpTop], 0
	mov [BmpLeft], 0

	mov dx, offset BackGround
	call OpenShowBmp
 
	
	
	ret 
endp
	



; __	 __            __     __   
;|__) |     /\  \ / |__  |__) 
;|    |___ /~~\  |  |___ |  \ 
                             
	
	
	
proc MovePlayerAllaxis

	call PlayerMove
	call PlayerMoveYaxis


	ret 
endp 
	
;DrawPlayer (main spaceship)
proc DrawPlayer
	mov [BmpColSize], 40
	mov [BmpRowSize], 46 
	mov ax, [yplayer]
	mov [BmpTop], ax 
	mov ax, [xplayer]
	mov [BmpLeft], ax 

	mov dx, offset PlayerFileName
	call MyBmp
	
	ret 
endp 

;Check If key pressed and move the player by the key 
;include bounderys
proc PlayerMove

	mov ah, 1
	int 16h 
	jz @@Cont 
	mov ah, 0
	int 16h 
	
	cmp ah, 4Dh;If right 
	je @@ChangeRight
	
	cmp ah, 4Bh;If left
	je @@ChangeLeft
	
	cmp al, 20h;if spacebar shoot laser 
	je @@ShootLaser
	
	cmp al, 27 ;if escape key was pressed go to end screen game
	je @@ExitGame 
	
	
	
	jmp @@Cont
	
@@ChangeRight:
	;check for bounderys 
	mov ax, [xplayer]
	add ax, 12
	cmp ax, 280d 
	ja @@Cont
	
	;if good do 
	mov ax, [xplayer]
	add ax, 12
	mov [xplayer], ax 
	
	jmp @@Cont

	
@@ChangeLeft:
	;check for bounderys 
	mov ax, [xplayer]
	sub ax, 12
	cmp ax, 10d
	jb @@Cont
	

	;if good do 
	mov ax, [xplayer]
	sub ax, 12
	mov [xplayer], ax 
	jmp @@Cont 
	
@@ExitGame:

	mov [Touch], 1

	jmp @@Cont 
	
@@ShootLaser:
	mov ax, 1
	call ShowAxDecimal
	call Shootlaser
	
	
@@Cont:

	ret 
endp 
	

;Move Player randomly at y axis (not much) 
proc PlayerMoveYaxis
	
	
	
	mov bx, 1
	mov dx, 2
	call RandomByCsWord
	
	cmp ax, 1
	je @@GoDown
	
	jmp @@GoUp
	
@@GoUp:
	mov bx, [yplayer]
	sub bx, 1
	cmp bx, 135
	jbe @@GoDown
	
	mov [yplayer], bx
	jmp @@Cont
@@GoDown:
	mov bx, [yplayer]
	add bx, 1
	cmp bx, 142
	jae @@GoUp
	
	mov [yplayer], bx

@@Cont: 

	ret 
endp 


;CheckTouchByPixelsOnPlayer
proc CheckTouch
	

	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [xplayer]
	add cx, 18
	mov dx, [yplayer]
	add dx, 9
	int 10h
	
	

	cmp al, 73
	jne @@Touch

	
	
	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [xplayer]
	add cx, 5
	mov dx, [yplayer]
	add dx, 26
	int 10h
	
	
	

	cmp al, 82
	jne @@Touch
	
	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [xplayer]
	add cx, 32
	mov dx, [yplayer]
	add dx, 26
	int 10h

	cmp al, 82
	jne @@Touch
	
	
	
	
	;new 1
	mov ah, 0Dh
	mov bh, 0
	mov cx, [xplayer]
	add cx, 15
	mov dx, [yplayer]
	add dx, 29
	int 10h

	cmp al, 91
	jne @@Touch
	
	
	
	
	;new 2
	mov ah, 0Dh
	mov bh, 0
	mov cx, [xplayer]
	add cx, 22
	mov dx, [yplayer]
	add dx, 29
	int 10h

	cmp al, 92
	jne @@Touch 
	
	
	jmp @@Cont 
@@Touch:



	mov [touch], 1
	
	
@@Cont:
	
	ret 
endp 


; _    __    __  ___ ___  
;| |  /  \ /' _/| __| _ \ 
;| |_| /\ |`._`.| _|| v / 
;|___|_||_||___/|___|_|_\ 

;Shoot laser (if at least 1 laser left) 
;call after input 
proc ShootLaser


	cmp [NumberofLasersLeft], 0 ;if no lasers left jmp end 
	je @@Cont 
	

	cmp [las1onscreen], 1 ;if laser 1 in use check laser 2
	je @@Las2 
	
	
@@Las1:
	mov [las1onscreen], 1
	mov ax, [xplayer]
	add ax, 2
	mov [las1x], ax
	mov ax, [yplayer]
	sub ax, 2
	mov [las1y], ax 
	dec [NumberofLasersLeft]
	
	jmp @@Cont 

@@Las2:
	cmp [las2onscreen], 1 ;if laser 1 in use check laser 2
	je @@Las3
	
	mov [las2onscreen], 1
	mov ax, [xplayer]
	add ax, 2
	mov [las2x], ax
	mov ax, [yplayer]
	add ax, 2
	mov [las2y], ax 
	dec [NumberofLasersLeft]
	
	
	jmp @@Cont 
@@Las3:
	mov [las3onscreen], 1
	mov ax, [xplayer]
	add ax, 2
	mov [las3x], ax
	mov ax, [yplayer]
	mov [las3y], ax 
	add ax, 2 
	dec [NumberofLasersLeft]



@@Cont:
	ret 
endp 

;Print lasers that are on screen ([las1onscreen]=1)
proc PrintLasers

	cmp [las1onscreen], 0
	je @@Las2
	
	mov [BmpColSize], 35
	mov [BmpRowSize], 35
	mov ax, [las1x]
	mov [BmpLeft], ax
	mov ax, [las1y]
	mov [bmptop], ax 
	mov dx, offset LaserFileName
	call MyBmp
	
@@Las2:
	cmp [las2onscreen], 0
	je @@Las3
	
	mov [BmpColSize], 35
	mov [BmpRowSize], 35
	mov ax, [las2x]
	mov [BmpLeft], ax
	mov ax, [las2y]
	mov [bmptop], ax 
	mov dx, offset LaserFileName
	call MyBmp
	
	
	
@@Las3:
	cmp [las3onscreen], 0
	je @@Cont
	
	mov [BmpColSize], 35
	mov [BmpRowSize], 35
	mov ax, [las3x]
	mov [BmpLeft], ax
	mov ax, [las3y]
	mov [bmptop], ax 
	mov dx, offset LaserFileName
	call MyBmp


@@Cont:
	


	ret 
endp


;mov lasers (dec y)
;If get to end hide 
proc MoveLasers

	 
	

	
	
	
@@Las1:
	cmp [las1onscreen], 0 
	je @@Las2 
	
	mov ax, [las1y]
	sub ax, [laserspeed]
	
	cmp ax, 0
	jbe @@HideLas1
	
	cmp ax, 153
	jae @@Hide2Las1
	
	mov [las1y], ax
	jmp @@Las2
@@HideLas1:
	mov [las1onscreen], 0
	
@@Hide2Las1:
	mov [las1onscreen], 0
	
	
@@Las2:
	cmp [las2onscreen], 0 
	je @@Las3
	
	mov ax, [las2y]
	sub ax, [laserspeed]
	
	cmp ax, 0
	jbe @@HideLas2
	
	cmp ax, 153
	jae @@Hide2Las2
	
	mov [las2y], ax
	jmp @@Las3
@@HideLas2:
	mov [las2onscreen], 0

@@Hide2Las2:
	mov [las2onscreen], 0
	
	
@@Las3:
	cmp [las3onscreen], 0
	je @@Cont
	
	mov ax, [las3y]
	sub ax, [laserspeed]
	
	cmp ax, 0
	jbe @@HideLas3
	
	cmp ax, 153
	jae @@Hide2Las3
	

	mov [las3y], ax
	jmp @@Cont
	
@@HideLas3:
	mov [las3onscreen], 0

@@Hide2Las3:
	mov [las3onscreen], 0


@@Cont:


	ret 
endp

;Check if laser touch bots if yes put in [botDestroyed] = 1
proc CheckTouchLaser
	mov ax, 0

@@Bot1:
	;mov ah, 0
	;int 16h
	cmp [bot1onscreen], 1 ;if bot 1 not on screen go check bot 2
	jne @@Bot2 
	
	
	cmp [bot1Destroyed], 0
	jne @@Bot2
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot1x]
	add cx, 5
	mov dx, [bot1y]
	add dx, 37
	int 10h
	
	cmp al, 163
	jne @@5CheckBlack
	
	jmp @@y5
@@5CheckBlack:
	cmp al, 0
	jne @@Destroybot1
@@y5:
	
	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot1x]
	add cx, 30
	mov dx, [bot1y]
	add dx, 37
	int 10h
	
	cmp al, 163
	jne @@Destroybot1
	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot1x]
	add cx, 4
	mov dx, [bot1y]
	add dx, 19
	int 10h
	
	cmp al, 81
	jne @@1CheckBlack
	
	jmp @@y3
@@1CheckBlack:
	cmp al, 0
	jne @@Destroybot1
@@y3:

	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot1x]
	add cx, 31
	mov dx, [bot1y]
	add dx, 19
	int 10h
	
	cmp al, 73
	jne @@3CheckBlack
	
	jmp @@y4
@@3CheckBlack:
	cmp al, 0
	jne @@Destroybot1
@@y4:

	
	
	
	jmp @@t1
	
@@JmpBot2:
	jmp @@Bot2
	
	
@@t1:
	
	
	

	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot1x]
	add cx, 17
	mov dx, [bot1y]
	add dx, 14
	int 10h
	
	cmp al, 154
	jne @@2CheckBlack
	
	jmp @@y1 
@@2CheckBlack:
	cmp al, 0
	jne @@Destroybot1

@@y1:
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot1x]
	add cx, 12
	mov dx, [bot1y]
	add dx, 14
	int 10h
	
	cmp al, 237
	jne @@Destroybot1
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot1x]
	add cx, 23
	mov dx, [bot1y]
	add dx, 14
	int 10h
	
	cmp al, 237
	jne @@Destroybot1
	
	
	jmp @@Bot2
	
@@Destroybot1:
	
	

	
	
	mov [bot1Destroyed], 1
	
	

@@Bot2:


	cmp [bot2onscreen], 1 ;if bot 1 not on screen go check bot 2
	jne @@JmpBot3
	
	cmp [bot2Destroyed], 0
	jne @@Bot3
	
	

	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot2x]
	add cx, 5
	mov dx, [bot2y]
	add dx, 37
	int 10h
	
	cmp al, 163
	jne @@5CheckBlack2
	
	jmp @@y52
@@5CheckBlack2:
	cmp al, 0
	jne @@Destroybot2
@@y52:
	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot2x]
	add cx, 30
	mov dx, [bot2y]
	add dx, 37
	int 10h
	
	cmp al, 163
	jne @@Destroybot2
	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot2x]
	add cx, 4
	mov dx, [bot2y]
	add dx, 19
	int 10h
	
	cmp al, 81
	jne @@1CheckBlack2
	
	jmp @@y32
@@1CheckBlack2:
	cmp al, 0
	jne @@Destroybot2
@@y32:

	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot2x]
	add cx, 31
	mov dx, [bot2y]
	add dx, 19
	int 10h
	
	cmp al, 73
	jne @@3CheckBlack2
	
	jmp @@y42
@@3CheckBlack2:
	cmp al, 0
	jne @@Destroybot2
@@y42:

	
	
	
	jmp @@t12
	
@@JmpBot3:
	jmp @@Bot3
	
	
@@t12:
	
	
	

	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot2x]
	add cx, 17
	mov dx, [bot2y]
	add dx, 14
	int 10h
	
	cmp al, 154
	jne @@2CheckBlack2
	
	jmp @@y12 
@@2CheckBlack2:
	cmp al, 0
	jne @@Destroybot2

@@y12:
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot2x]
	add cx, 12
	mov dx, [bot2y]
	add dx, 14
	int 10h
	
	cmp al, 237
	jne @@Destroybot2
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot2x]
	add cx, 23
	mov dx, [bot2y]
	add dx, 14
	int 10h
	
	cmp al, 237
	jne @@Destroybot2
	
	
	
	
	
	
	jmp @@Bot3
	
@@Destroybot2:
	
	

	
	mov [bot2Destroyed], 1






@@Bot3: 


	cmp [bot3onscreen], 1 ;if bot 1 not on screen go check bot 2
	jne @@JmpCont 
	
	cmp [bot3Destroyed], 0
	jne @@Cont 
	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot3x]
	add cx, 5
	mov dx, [bot3y]
	add dx, 37
	int 10h
	
	cmp al, 163
	jne @@5CheckBlack3
	
	jmp @@y53
@@5CheckBlack3:
	cmp al, 0
	jne @@Destroybot3
@@y53:
	
	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot3x]
	add cx, 30
	mov dx, [bot3y]
	add dx, 37
	int 10h
	
	cmp al, 163
	jne @@Destroybot3
	
	
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot3x]
	add cx, 4
	mov dx, [bot3y]
	add dx, 19
	int 10h
	
	cmp al, 81
	jne @@1CheckBlack3
	
	jmp @@y33
@@1CheckBlack3:
	cmp al, 0
	jne @@Destroybot3
@@y33:

	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot3x]
	add cx, 31
	mov dx, [bot3y]
	add dx, 19
	int 10h
	
	cmp al, 73
	jne @@3CheckBlack3
	
	jmp @@y43
@@3CheckBlack3:
	cmp al, 0
	jne @@Destroybot3
@@y43:

	
	
	
	jmp @@t13
	
@@JmpCont:
	jmp @@Cont
	
	
@@t13:
	
	
	

	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot3x]
	add cx, 17
	mov dx, [bot3y]
	add dx, 14
	int 10h
	
	cmp al, 154
	jne @@2CheckBlack3
	
	jmp @@y13
@@2CheckBlack3:
	cmp al, 0
	jne @@Destroybot3

@@y13:
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot3x]
	add cx, 12
	mov dx, [bot3y]
	add dx, 14
	int 10h
	
	cmp al, 237
	jne @@Destroybot3
	
	
	mov ah, 0Dh
	mov bh, 0
	mov cx, [bot3x]
	add cx, 23
	mov dx, [bot3y]
	add dx, 14
	int 10h
	
	cmp al, 237
	jne @@Destroybot3
	
	
	
	
	 
	
	jmp @@Cont
	
@@Destroybot3:
	
	

	mov [bot3Destroyed], 1
	
	
@@Cont:
	
	ret 
endp



;Print on screen How many laser you have (on bottom right) 
proc PrintAllLasMag

	cmp [NumberofLasersLeft], 1
	jae @@PrintLaser1mag
	
	jmp @@Cont 
	
	
@@PrintLaser1mag:
	
	
	mov [BmpColSize] ,7
	mov [BmpRowSize] ,9
	mov [BmpLeft], 311
	mov [BmpTop], 189
	
	mov dx, offset LaserMagFileName
	call OpenShowBmp
	cmp [NumberofLasersLeft], 2
	jae @@PrintLaser2mag
	
	jmp @@Cont 
	
	
	
@@PrintLaser2mag:

	
	mov [BmpColSize] ,7
	mov [BmpRowSize] ,9
	mov [BmpLeft], 311
	mov [BmpTop], 179
	mov dx, offset LaserMagFileName
	call OpenShowBmp
	cmp [NumberofLasersLeft], 3
	jae @@PrintLaser3mag
	
	jmp @@Cont 
	
@@PrintLaser3mag:

	
	mov [BmpColSize] ,7
	mov [BmpRowSize] ,9
	mov [BmpLeft], 311
	mov [BmpTop], 169
	mov dx, offset LaserMagFileName
	call OpenShowBmp
	
	

	
	jmp @@Cont 
	
@@Cont:

	ret 
endp 

; __   ___  __                  __      __   __   __   __  
;|__) |__  / _` |  | |     /\  |__)    |__) |__) /  \ /  ` 
;|  \ |___ \__> \__/ |___ /~~\ |  \    |    |  \ \__/ \__, 
                                                          
;put in dx offset of filename 
	
	
;put in dx offset of FileName
;doesn't draw the color black 
proc MyBmp
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call  ShowBMPWithoutcolor ;black 
	
	 
	call CloseBmpFile

@@ExitProc:
	ret



endp 

;put in dx offset of filename 
proc OpenShowBmp near
	
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call  ShowBmp
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp


; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile

	
; output file dx filename to open
proc CreateBmpFile	near						 
	 
	
CreateNewFile:
	mov ah, 3Ch 
	mov cx, 0 
	int 21h
	
	jnc Success
@@ErrorAtOpen:
	mov [ErrorFile],1
	jmp @@ExitProc
	
Success:
	mov [ErrorFile],0
	mov [FileHandle], ax
@@ExitProc:
	ret
endp CreateBmpFile





proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette

 
proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 


;Same Like ShowBMp but you dont show spesific color 
proc ShowBMPWithoutcolor
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScrLine

@@Copying:
	cmp [byte ds:si], 0 ;color not drawing 
	je @@Transperant
	jmp @@MovsbLabel
	
@@Transperant:
	inc si
	inc di
	jmp @@LoopLabel

@@MovsbLabel:
	movsb ; Copy line to the screen
		;mov [es:di], [ds:si]
		;inc si
		;inc di
@@LoopLabel:
	loop @@copying

	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp 

	

; Read 54 bytes the Header
proc PutBmpHeader	near					
	mov ah,40h
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp PutBmpHeader
 



proc PutBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	mov ah,40h
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp PutBmpPalette


 
proc PutBmpDataIntoFile near
			
    mov dx,offset OneBmpLine  ; read 320 bytes (line) from file to buffer
	
	mov ax, 0A000h ; graphic mode address for es
	mov es, ax
	
	mov cx,[BmpRowSize]
	
	cld 		; forward direction for movsb
@@GetNextLine:
	push cx
	dec cx
										 
	mov si,cx    ; set si at the end of the cx line (cx * 320) 
	shl cx,6	 ; multiply line number twice by 64 and by 256 and add them (=320) 
	shl si,8
	add si,cx
	
	mov cx,[BmpColSize]    ; line size
	mov di,dx
    
	 push ds 
     push es
	 pop ds
	 pop es
	 rep movsb
	 push ds 
     push es
	 pop ds
	 pop es
 
	
	
	 mov ah,40h
	 mov cx,[BmpColSize]
	 int 21h
	
	 pop cx ; pop for next line
	 loop @@GetNextLine
	
	
	
	 ret 
endp PutBmpDataIntoFile

   
proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic

proc SetTextMod
	mov ax, 03h  ; 80 x 25 text mode
	int 10h      ; BIOS video interrupt to set the video mode
	ret

endp 
 
	

	

	
	
proc Loop100MiliSec
	push cx
	mov cx, 100
@@Self1:
	push cx
	mov cx, 3000
@@Self2:
	loop @@Self2
	pop cx
	loop @@Self1
	pop cx
	ret 
endp

proc Loop100MiliSec3000cycles
	push cx
	mov cx, 100
@@Self1:
	push cx
	mov cx, 30000
@@Self2:
	loop @@Self2
	pop cx
	loop @@Self1
	pop cx
	ret 
endp
	
proc ClearScreen 
	
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 2
	mov bh, 0
	mov dh, 0
	mov dl, 0
	int 10h
		
	
	mov cx, 64000
	
	mov ah, 2
	mov bh, 0
	mov dh, 0
	mov dl, 0
	int 10h
@@Print:
	
	
	
	mov dl, ' '
	mov ah, 2
	int 21h
	
	loop @@Print
	
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret 
endp


endp
	;================================================
; Description - Write on screen the value of ax (decimal)
;               the practice :  
;				Divide AX by 10 and put the Mod on stack 
;               Repeat Until AX smaller than 10 then print AX (MSB) 
;           	then pop from the stack all what we kept there. 
; INPUT: AX
; OUTPUT: Screen 
; Register Usage: AX  
;================================================
proc ShowAxDecimal
	   push ax
       push bx
	   push cx
	   push dx
	   
	   ; check if negative
	   test ax,08000h
	   jz PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack

	   cmp ax,0
	   jz pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
		
	   ;mov dl, ','
       ;mov ah, 2h
	   ;int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal
; Description  : get RND between any bl and bh includs (max 0 -255)
; Input        : 1. Bl = min (from 0) , BH , Max (till 255)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        Al - rnd num from bl to bh  (example 50 - 150)
; More Info:
; 	Bl must be less than Bh 
; 	in order to get good random value again and agin the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCs
    push es
	push si
	push di
	
	mov ax, 40h
	mov	es, ax
	
	sub bh,bl  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp bh,0
	jz @@ExitP
 
	mov di, [word RndCurrentPos]
	call MakeMask ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
RandLoop: ;  generate random number 
	mov ax, [es:06ch] ; read timer counter
	mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs)
	xor al, ah ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	cmp di,(EndOfCsLbl - start - 1)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	cmp al,bh    ;do again if  above the delta
	ja RandLoop
	
	add al,bl  ; add the lower limit to the rnd num
		 
@@ExitP:	
	pop di
	pop si
	pop es
	ret
endp RandomByCs


; Description  : get RND between any bl and bh includs (max 0 - 65535)
; Input        : 1. BX = min (from 0) , DX, Max (till 64k -1)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
; More Info:
; 	BX  must be less than DX 
; 	in order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCsWord
    push es
	push si
	push di
 
	
	mov ax, 40h
	mov	es, ax
	
	sub dx,bx  ; we will make rnd number between 0 to the delta between bx and dx
			   ; Now dx holds only the delta
	cmp dx,0
	jz @@ExitP
	
	push bx
	
	mov di, [word RndCurrentPos]
	call MakeMaskWord ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
@@RandLoop: ;  generate random number 
	mov bx, [es:06ch] ; read timer counter
	
	mov ax, [word cs:di] ; read one word from memory (from semi random bytes at cs)
	xor ax, bx ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	inc di
	cmp di,(EndOfCsLbl - start - 2)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	
	cmp ax,dx    ;do again if  above the delta
	ja @@RandLoop
	pop bx
	add ax,bx  ; add the lower limit to the rnd num
		 
@@ExitP:
	
	pop di
	pop si
	pop es
	ret
endp RandomByCsWord

; make mask acording to bh size 
; output Si = mask put 1 in all bh range
; example  if bh 4 or 5 or 6 or 7 si will be 7
; 		   if Bh 64 till 127 si will be 127
Proc MakeMask    
    push bx

	mov si,1
    
@@again:
	shr bh,1
	cmp bh,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop bx
	ret
endp  MakeMask


Proc MakeMaskWord    
    push dx
	
	mov si,1
    
@@again:
	shr dx,1
	cmp dx,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop dx
	ret
endp  MakeMaskWord








	
	
	
	
	
EndOfCsLbl:

	
	
	
	
END start


