ORG 0000H
MOV P1,#00H 
MOV P2,#05H; MAKING THE MOTOR TO RUN FORWARD
SETB P1.2; MQ3 SENSOR INPUT.SO INITALISING THE PARTICULAR PIN 
ACALL DELAY;CALLING DELAY BECAUSE MICROCONTROLLER IS VERY FAST COMPARED TO LCD 
MOV A,#38H;INTIALISING LCD TO 2 LINES AND 5x7 MATRIX, SENDING THE COMMAND TO A REGISTER AND THEN TO LCD VIA PORT P0
ACALL LCD; SUBROUTINE FOR SENDING THE COMMAND REGISTERING THE LCD
MOV A,#0EH;MAKING THE LCD ON AND CURSOR TO BLINK
ACALL LCD;SIMILAR SUBROUTINE TO SEND THE COMMAND TO LCD VIA PORT P0
MOV A,#01H;CLEARING THE LCD DISPLAY SCREEN
ACALL LCD;SUBROUTINE
MOV A,#82H;FORCING CURSOR TO BLINK IN THE FIRST LINE
ACALL LCD;SIMILAR SUBROUTINE
MOV A,#00H
AGAIN:MOV C,P1.1;Sending the eye blink sensor input to Carry flag
MOV ACC.0,C;sending the carry flag data to the LSB of A register
MOV C,P1.2;Similarly sending the MQ3 Sensor input to Carry flag.
ANL C,ACC.0;Now using AND operation to check whether both the eyeblink sensor and MQ3 gas sensor input are 1 or not
MOV ACC.0,C;Now moving that to LSB of A register
CJNE A,#01H,WAIT;Checking whether LSB of A register is 1 which implies that both the sensor detected alcohol and drowsiness. Or jump to WAIT LABEL
ACALL DELAY;If yes comes down
ACALL TRANS;Subroutine for transmitting Message to concerned members via Serial communication
ACALL DELAY
MOV DPTR,#STRING;Storing DRUNK Message in ROM Location 
BACK:SETB P2.0;Next four lines implies to stop the motor which is connected
SETB P2.1
SETB P2.2
SETB P2.3
SETB P1.0;Switching on the buzzer
MOV A,#00H
MOVC A, @A+DPTR; Moving each character of 'DRUNK' from DPTR to the A register
JZ EXIT; To check whether all the characters are displayed. If it then it will jump to EXIT label
ACALL SHOW;Displaying word by word of the 'DRUNK' message in the LCD via the SHOW subroutine
INC DPTR;Incrementing DPRT
SJMP BACK;Continuing the process
EXIT:MOV A,#01H; Clearing the LCD screen and then displaying otherwise the characters will overlap
ACALL LCD
ACALL DELAY
SJMP AGAIN
WAIT:CJNE A,#00H,AGAIN;If both the sensors didnt detect or either one only detected then the LSB of A register must contain 00h.  
MOV DPTR, #STRING1;Storing NOT DRUNK Message in ROM Location
BACK1:SETB P2.0;Next four lines implies to power the motor or let the car run
CLR P2.1
SETB P2.2
CLR P2.3
CLR P1.0;Clearing the buzzer
MOV A,#00H
MOVC A, @A+DPTR;Similar process done like displaying DRUNK
JZ EXIT1
ACALL SHOW
INC DPTR
SJMP BACK1
EXIT1:MOV A,#01H
ACALL LCD
ACALL DELAY
ACALL DELAY
SJMP AGAIN


LCD:ACALL DELAY;Command registering the LCD
MOV P0,A;P0 is connected to the data pins of LCD ,data is transmitted through it from A
CLR P2.4;making the LCD in write mode
CLR P2.5;Making the LCD in command registering mode
SETB P2.6;Sending a high to low pulse in enable pin of LCD
CLR P2.6
RET

SHOW:ACALL DELAY;Displaying data in LCD
MOV P0,A
SETB P2.4
CLR P2.5
SETB P2.6;Making the LCD in data registering mode
CLR P2.6
RET

TRANS:ACALL DELAY;Transmitting message to the concerned member if alcohol is detected
MOV DPTR,#STRING2;String 2 contains message that is to be sent.
MOV TMOD,#20H;Setting timer 1 in mode 2 for serial communication
MOV SCON,#50H; Setting Serial communication register to mode 2 with REN
MOV TH1,#-3;Setting baud rate to 9600
SETB TR1
MOV R2,#47;Length of the string that is to be sent
AGAIN1:CLR A
MOVC A,@A+DPTR
MOV SBUF,A
HERE1:JNB TI,HERE1;Monitoring the Transmit Flag
CLR TI
INC DPTR
DJNZ R2,AGAIN1


DELAY:MOV R0,#0FFH;Delay subroutine
ONCE:MOV R1,#0FFH
TWICE:DJNZ R1,TWICE
DJNZ R0,ONCE
RET




STRING:DB 'DRUNK',00H;DPTR LOCATIONS OF ALL THE STRING
STRING1:DB 'NOT DRUNK',00H;00H implies that it has completed the whole particular string otherwise it will print all the three strings
STRING2:DB 'ALCOHOL DETECTED, MESSAGE SENT TO +919442130430'

END