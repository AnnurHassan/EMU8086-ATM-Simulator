.MODEL SMALL 

printMsg macro msg
    ;Welcome Prompt Start
    MOV AH, 09H 
    LEA DX, b1
    INT 21H
    lineBreak
    
    MOV AH, 09H
    LEA DX, b2
    INT 21H
    lineBreak        
    
    MOV AH, 09H
    LEA DX, b3
    INT 21H
    lineBreak
    
    MOV AH, 09H 
    LEA DX, msg
    INT 21H
    lineBreak 
    
    MOV AH, 09H
    LEA DX, b4
    INT 21H
    lineBreak
    
    MOV AH, 09H
    LEA DX, b5
    INT 21H
    lineBreak   
    
    MOV AH, 09H
    LEA DX, b6
    INT 21H
    lineBreak
    ; Welcome Prompt end 
endm   

lineBreak macro
    MOV AH, 02
    MOV DL, 10
    INT 21H
    
    MOV AH,02
    MOV DL, 13
    INT 21H  
    
endm 

printMenu macro
    LEA DX, atm_menu_head
    MOV AH, 09H
    INT 21H
    lineBreak
    
    LEA DX, atm_menu_1
    MOV AH, 09H
    INT 21H
    lineBreak
    
    LEA DX, atm_menu_2
    MOV AH, 09H
    INT 21H
    lineBreak
    
    LEA DX, atm_menu_3
    MOV AH, 09H
    INT 21H
    lineBreak
    
    LEA DX, atm_menu_4
    MOV AH, 09H
    INT 21H
    lineBreak
    
    LEA DX, atm_menu_5
    MOV AH, 09H
    INT 21H
    lineBreak
    
    LEA DX, atm_menu_6
    MOV AH, 09H
    INT 21H
    lineBreak
    
    LEA DX, atm_menu_0
    MOV AH, 09H
    INT 21H
    lineBreak
    
    LEA DX, atm_menu_foot
    MOV AH, 09H
    INT 21H
    lineBreak

endm  


.STACK 100H

.DATA  

; declare variables here  

;Welcome Message
b1 db "* * * * * * * * * * * * * * * * * * * * * * * $"
b2 db "* * * * * * * * * * * * * * * * * * * * * * * $" 
b3 db "* *                                       * * $"
Welcome_msg db "* *   Welcome to Mayer Dowa ATM Machine   * * $"
b4 db "* *                                       * * $"
b5 db "* * * * * * * * * * * * * * * * * * * * * * * $"
b6 db "* * * * * * * * * * * * * * * * * * * * * * * $"  

; Pin Verification
pin_Prompt db "Enter 5-digit PIN: $"
pin db "12345" 
pin_input db 5 dup(?)  
tryAgain_Prompt db "!Pin Rejected! Please try again$"
valid_pinPrompt db "Pin Accepted$"
invalid_pinPrompt db "Access Locked! Terminating Session.....$"
new_pin_prompt db "Enter new 5-digit PIN: $"
pin_change_success db "PIN changed successfully!$"      

; ATM menu
atm_menu_head db "----- ATM Menu -----$"
atm_menu_1 db "1. Balance Inquiry$"
atm_menu_2 db "2. Deposit Money$"
atm_menu_3 db "3. Withdraw Money$"
atm_menu_4 db "4. Change PIN$"
atm_menu_5 db "5. Loan Money$"
atm_menu_6 db "6. Account Details$"
atm_menu_0 db "0. Exit$"
atm_menu_foot db "--------------------$"
menu_choice db "Choose an option: $" 
invalid_choice db "Invalid Choice! Try again.$"

;Variables
current_balance db "Current Balance: $"
balance dw 0000
insufficient_funds_msg db "Insufficient funds!$"                                 
TEMP dw ? 
ask_amount db "Enter amount: $"
amount dw ?                     
tran_complete db "Transaction successful!$"   
not_enough_funds db "Insufficient funds!$"
processing db "Processing Request..............$"
exit_msg db "* *   Thanks for Using Our ATM Machine    * * $"
account_prompt_head db "-----Account Details-----$"
account_prompt_foot db "-------------------------$"  
account_name db "Name: Jack Ryan$"
account_number db "Account No: 34587921654$"
account_type db "Account Type: Savings$"


.CODE 
MAIN PROC  
    
; initialize DS  

MOV AX,@DATA
MOV DS,AX            

; enter your code here  

printMsg Welcome_msg      

 
Menu:
    lineBreak
    lineBreak
    
    printMenu 
    
    lineBreak
    lineBreak
    
    LEA DX, menu_choice
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01
    INT 21H
    
    CMP AL, "1"
    JE Balance_check
    
    CMP AL, "2"
    JE Deposit
    
    CMP AL, "3"
    JE Withdraw
    
    CMP AL, "4"
    JE Change_pin
    
    CMP AL, "5"
    JE Loan    
    
    CMP AL, "6"
    JE Account_Details
    
    CMP AL, "0"
    JE exit 
    
    lineBreak
    lineBreak
    
    LEA DX, invalid_choice
    MOV AH, 09H
    INT 21H
    JMP Menu
  

exit:      
    lineBreak
    lineBreak
    lineBreak
    
    printMsg exit_msg



;exit to DOS    

MOV AX,4C00H
INT 21H       


MAIN ENDP   


;------- Verify Pin Proc ----------
Verify_Pin PROC
    MOV CX, 3     ; 3 attempts

try_pin:
    lineBreak
    lineBreak 
    
    LEA DX, pin_Prompt
    MOV AH, 09H  
    INT 21H 

    MOV SI, 0
    take_input:
        MOV AH, 08H     ; Read char without echo
        INT 21H 
    
        MOV pin_input[SI], AL
    
        MOV AH, 02H
        MOV DL, "*"
        INT 21H
    
        INC SI
        CMP SI, 5
        JNE take_input 
    
        lineBreak
    
        MOV SI, 0
    compare_pin:
        MOV AL, pin[SI]
        MOV BL, pin_input[SI]
        CMP AL, BL
        JNE invalid_pin
    
        INC SI
        CMP SI, 5
        JNE compare_pin
    
        
        RET           ; if pin valid ret to func call
    
    invalid_pin:
        CMP CX, 1
        JE outOfAttempts
    
        LEA DX, tryAgain_Prompt
        MOV AH, 09H
        INT 21H  
    
        LOOP try_pin
    
    outOfAttempts:
        lineBreak
        
        LEA DX, invalid_pinPrompt
        MOV AH, 09H
        INT 21H    
        JMP exit  ; Force exit

Verify_Pin ENDP

; -------- Display Number Procedure --------
Display_number PROC
    MOV BX, 10      ; Divisor
    MOV CX, 0       ; Digit counter
    
    ; Handle 0 case specially
    CMP AX, 0
    JNE Divide_loop
    MOV AH, 2
    MOV DL, '0'
    INT 21H
    RET
    
Divide_loop:
    ; Check if number is 0
    CMP AX, 0
    JE Display_loop
    
    ; Get remainder when divided by 10
    MOV DX, 0
    DIV BX  ; AX = quotient, DX = remainder
    
    ; Convert to ASCII and push onto stack
    ADD DL, '0'
    PUSH DX
    INC CX
    
    JMP Divide_loop
    
Display_loop:
    ; Check if we have displayed all digits
    CMP CX, 0
    JE End_display
    
    ; Pop a digit and display it
    POP DX
    MOV AH, 2
    INT 21H
    DEC CX
    
    JMP Display_loop
    
End_display:
    RET
    
Display_number ENDP 

; -------- Read Number Procedure --------
Read_number PROC
    ; Initialize result to 0
    MOV AX, 0
    MOV TEMP, AX
    
Read_digit:
    ; Read a digit
    MOV AH, 1
    INT 21H
    
    ; Check if end of input (Enter key)
    CMP AL, 0DH
    JE End_read
    
    ; Check if it's a digit
    CMP AL, '0'
    JB Invalid_digit
    CMP AL, '9'
    JA Invalid_digit
    
    ; Convert ASCII to number
    SUB AL, '0'
    MOV AH, 0
    
    ; Multiply current result by 10
    MOV BX, 10
    MOV CX, AX  ; Save the digit
    MOV AX, TEMP
    MUL BX      ; AX = AX * 10
    
    ; Add new digit
    ADD AX, CX
    MOV TEMP, AX
    
    JMP Read_digit
    
Invalid_digit:
    JMP Read_digit
    
End_read:
    MOV AX, TEMP
    RET
    
Read_number ENDP 

;--------- Balance Check ----------
Balance_check PROC  
    CALL Verify_Pin
    
    lineBreak
    lineBreak 
    
    LEA DX, processing
    MOV AH, 09H
    INT 21H
    
    lineBreak
    lineBreak
      
    LEA DX, current_balance
    MOV AH, 09H
    INT 21H 
   
    MOV AX, balance
    CALL Display_number 
    
    JMP Menu

Balance_check ENDP

; -------- Deposit Money Procedure --------
Deposit PROC
    lineBreak
    lineBreak
    
    LEA DX, processing
    MOV AH, 09H
    INT 21H
    
    lineBreak
    lineBreak
    
    
    ; Ask for deposit amount
    LEA DX, ask_amount
    MOV AH, 9
    INT 21H
    
    ; Get amount
    CALL READ_NUMBER
    MOV amount, AX
    
    ; Add amount to balance
    MOV AX, amount
    ADD balance, AX
    
    ; Display success message
    LEA DX, tran_complete
    MOV AH, 9
    INT 21H
    
    JMP MENU
    
Deposit ENDP 

; -------- Withdraw Money Procedure --------
Withdraw PROC
    CALL Verify_Pin
    
    lineBreak
    lineBreak
    
    LEA DX, processing
    MOV AH, 09H
    INT 21H
    
    lineBreak
    lineBreak
    
    ; Ask for withdrawal amount
    LEA DX, ask_amount
    MOV AH, 9
    INT 21H
    
    ; Get amount
    CALL READ_NUMBER
    MOV amount, AX
    
    ; Check if sufficient balance
    MOV AX, balance
    CMP AX, amount
    JB Insuff_funds
    
    ; Subtract amount from balance
    MOV AX, amount
    SUB balance, AX
    
    ; Display success message
    LEA DX, tran_complete
    MOV AH, 9
    INT 21H
    
    JMP MENU
    
Insuff_funds:
    ; Display insufficient funds message
    LEA DX, not_enough_funds
    MOV AH, 9
    INT 21H
    
    JMP MENU
    
Withdraw ENDP

;---------- Pin Change ------------

Change_PIN PROC
    CALL Verify_Pin 
    
    lineBreak
    
    LEA DX, new_pin_prompt
    MOV AH, 09H
    INT 21H

    MOV SI, 0 
        
    get_new_pin:
        MOV AH, 08H
        INT 21H 
        
        MOV pin[SI], AL 
        
        MOV AH, 02H
        MOV DL, '*'
        INT 21H
        
        INC SI
        CMP SI, 5
        JNE get_new_pin 
        
        lineBreak
        lineBreak
        lineBreak
    
        LEA DX, pin_change_success
        MOV AH, 09H
        INT 21H
    
        JMP Menu

Change_PIN ENDP 

;------- Loan ---------

Loan PROC 
    CALL Verify_Pin
    
    lineBreak
    lineBreak

    LEA DX, processing
    MOV AH, 09H
    INT 21H

    lineBreak
    lineBreak

    ; Ask for loan amount
    LEA DX, ask_amount
    MOV AH, 09H
    INT 21H

    ; Get amount
    CALL READ_NUMBER
    MOV amount, AX

    ; Add loan to balance
    MOV AX, amount
    ADD balance, AX

    ; Display success message
    LEA DX, tran_complete
    MOV AH, 09H
    INT 21H

    JMP Menu

Loan ENDP

; ------ Account Details -------

Account_Details PROC 
    CALL Verify_Pin
    
    lineBreak
    lineBreak
    
    LEA DX, processing
    MOV AH, 09H
    INT 21H
    
    lineBreak
    lineBreak 
    
    LEA DX, account_prompt_head
    MOV AH, 09H
    INT 21H
    
    lineBreak
    lineBreak

    LEA DX, account_name
    MOV AH, 09H
    INT 21H
    
    lineBreak

    LEA DX, account_number
    MOV AH, 09H
    INT 21H 
    
    lineBreak
    
    LEA DX, account_type
    MOV AH, 09H
    INT 21H 
    
    lineBreak
    lineBreak
    
    LEA DX, account_prompt_foot
    MOV AH, 09H
    INT 21H  
    

    JMP Menu  
    
Account_Details ENDP


END MAIN