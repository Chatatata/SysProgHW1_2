        
        ; Bugra Ekuklu
        ; 150120016

        ; Assembly to generating 2D Neumann automata
        ;
        ; STACK PARAMETERS                                          MUTATED?
        ; ebp+8         : Input matrix (int32_t[BUFSIZ][BUFSIZ])          NO    
        ; ebp+12        : Width of the input matrix (int32_t)             NO
        ; ebp+16        : Height of the input matrix (int32_t)            NO
        ; ebp+20        : 32-bit rule buffer (int32_t[BUFSIZ])            NO
        ; ebp+24        : Output matrix (int32_t[BUFSIZ][BUFSIZ])        YES


        segment     .data
        global      generate_r

generate_r:
        push  ebp                ; Save the old base pointer value
        mov   ebp, esp           ; Load stack pointer to base pointer

        xor   eax, eax           ; Initialize EAX
        push  eax                ; Push current axis to the stack
        push  eax                ; Push current ordinate to the stack
        push  eax                ; Push zero as initial sum to the stack

add_center:
        add   esp, 4             ; Forward stack pointer one parameter
        pop   eax                ; Fetch the current ordinate to the stack
        pop   ecx
        push  ecx
        mov   edx, 800           ; Write the offset cofactor to EDX
        mul   edx                ; Make EAX offset
        mov   ebx, [ebp+8]       ; Get input matrix from the stack
        add   ebx, eax           ; Apply the offset
        pop   eax                ; Fetch the current axis to the stack
        mov   eax, [ebx+4*eax]   ; Fetch the element of matrix to the EAX
        mov   edx, 16            ; Write the cofactor to EDX
        mul   edx                ; Apply impact cofactor
        sub   esp, 8             ; Backward stack pointer two parameters
        push  eax                ; Store sum to the EAX
          
north_available:
        add   esp, 4             ; Forward stack pointer one parameter
        pop   eax                ; Fetch the current ordinate to the stack
        sub   esp, 8             ; Backward stack pointer two parameters
        cmp   eax, 0             ; Compare EAX with zero
        je    east_available     ; Jump to east manifest if not available

add_north:
        add   esp, 4             ; Forward stack pointer one parameter
        pop   eax                ; Fetch the current ordinate to the stack
        dec   eax                ; Decrement EAX to get to north
        mov   edx, 800           ; Write the offset cofactor to EDX
        mul   edx                ; Make EAX offset
        mov   ebx, [ebp+8]       ; Get input matrix from the stack
        add   ebx, eax           ; Apply the offset
        pop   eax                ; Fetch the current axis to the EAX
        mov   eax, [ebx+4*eax]   ; Fetch the element of matrix to the EAX
        mov   edx, 8             ; Write the cofactor to EDX
        mul   edx                ; Apply impact cofactor
        sub   esp, 12            ; Backward stack pointer three parameters
        pop   edx                ; Pop the latest sum
        add   eax, edx           ; Add the new impact to the sum
        push  eax                ; Push the current sum

east_available:
        add   esp, 8             ; Forward stack pointer two parameters
        pop   eax                ; Fetch the current axis to the stack
        sub   esp, 12            ; Backward stack pointer three parameters
        mov   edx, [ebp+12]      ; Fetch the matrix width
        dec   edx                ; Decrement width by one
        cmp   eax, edx           ; Compare if two are equal
        je    south_available    ; Jump to south manifest if not available

add_east:
        add   esp, 4             ; Forward stack pointer one parameter
        pop   eax                ; Fetch the current ordinate to the stack
        mov   edx, 800           ; Write the offset cofactor to EDX
        mul   edx                ; Make EAX offset        
        mov   ebx, [ebp+8]       ; Get input matrix from the stack
        add   ebx, eax           ; Apply the offset
        pop   eax                ; Fetch the current axis to the EAX
        inc   eax                ; Increment EAX to get to east
        mov   eax, [ebx+4*eax]   ; Fetch the element of matrix to the EAX
        mov   edx, 8             ; Write the cofactor to EDX
        mul   edx                ; Apply impact cofactor
        sub   esp, 12            ; Backward stack pointer three parameters
        pop   edx                ; Pop the latest sum
        add   eax, edx           ; Add the new impact to the sum
        push  eax                ; Push the current sum

south_available:
        add   esp, 4             ; Forward stack pointer one parameter
        pop   eax                ; Fetch the current ordinate to the stack
        sub   esp, 8             ; Backward stack pointer three parameters
        mov   edx, [ebp+16]      ; Fetch the matrix height
        dec   edx                ; Decrement height by one
        cmp   eax, edx           ; Compare if two are equal
        je    west_available     ; Jump to west manifest if not available

add_south:
        add   esp, 4             ; Forward stack pointer one parameter
        pop   eax                ; Fetch the current ordinate to the stack
        inc   eax                ; Increment EAX to get to south
        mov   edx, 800           ; Write the offset cofactor to EDX
        mul   edx                ; Make EAX offset
        mov   ebx, [ebp+8]       ; Get input matrix from stack
        add   ebx, eax           ; Apply the offset
        pop   eax                ; Fetch the current axis to the stack
        mov   eax, [ebx+4*eax]   ; Fetch the element of matrix to the EAX
        mov   edx, 2             ; Write the cofactor to EDX
        mul   edx                ; Apply impact cofactor
        sub   esp, 12            ; Backward stack pointer three parameters
        pop   edx                ; Pop the latest sum
        add   eax, edx           ; Add the new impact to the sum
        push  eax                ; Push the current sum

west_available:
        add   esp, 8             ; Forward stack pointer two parameters
        pop   eax                ; Fetch the current axis to the stack
        sub   esp, 12            ; Backward stack pointer two parameters
        cmp   eax, 0             ; Check if axis is zero
        je    draw_element       ; Jump to drawer manifest if not available

add_west:
        add   esp, 4             ; Forward stack pointer one parameter
        pop   eax                ; Fetch the current ordinate to the stack
        mov   edx, 800           ; Write the offset cofactor to EDX
        mul   edx                ; Make EAX offset
        mov   ebx, [ebp+8]       ; Get input matrix from stack
        add   ebx, eax           ; Apply the offset
        pop   eax                ; Fetch the current axis to the stack
        dec   eax                ; Decrement EAX to get to west
        mov   eax, [ebx+4*eax]   ; Fetch the element of matrix to the EAX
        sub   esp, 12            ; Backward stack pointer three parameters
        pop   edx                ; Pop the latest sum
        add   eax, edx           ; Add the new impact to the sum
        push  eax                ; Push the current sum

; draw_buffer[ordinate][axis] = rule_buffer[sum]
draw_element:
        pop   eax                ; Fetch the sum of impacts
        mov   ebx, [ebp+20]      ; Fetch the 32-bit rule buffer pointer
        mov   edx, [ebx+4*eax]   ; Get the rule to the EDX
        sub   esp, 4             ; Backward stack pointer one parameter
        push  edx                ; Push the rule to the stack
        mov   ebx, [ebp+24]      ; Fetch the draw buffer
        add   esp, 8             ; Forward stack pointer two parameters
        pop   eax                ; Fetch the current ordinate
        mov   edx, 800           ; Write the offset cofactor to EDX
        mul   edx                ; Make EAX offset
        add   ebx, eax           ; Apply the offset
        pop   eax                ; Fetch the current axis
        sub   esp, 16            ; Backward stack pointer four parameters
        pop   edx                ; Fetch the rule
        mov   [ebx+4*eax], edx   ; Draw the rule to draw buffer

init_sum:
        add   esp, 4             ; Backward stack pointer one parameter
        mov   edx, 0             ; Write 0 to EDX
        push  edx                ; Push it to the stack

set_position:
        mov   eax, [ebp+12]      ; Fetch the input buffer width
        add   esp, 8             ; Backward stack pointer two parameters
        pop   edx                ; Fetch current axis
        dec   eax                ; Decrement width by one
        sub   esp, 12            ; Backward stack pointer three parameters
        cmp   eax, edx           ; Compare current axis and maximum axis
        jne   increment_axis     ; Jump to increment axis if not equal

        mov   eax, [ebp+16]      ; Fetch the input buffer height
        add   esp, 4             ; Backward stack pointer one parameter
        pop   edx                ; Fetch current ordinate
        sub   esp, 8             ; Backward stack pointer two parameters
        dec   eax                ; Decrement height by one
        cmp   eax, edx           ; Compare current axis and maximum axis
        jne   increment_ordinate ; Jump to increment ordinate if not equal
        je    bailout            ; Bailout if all reached maximum         

increment_axis:
        add   esp, 8             ; Forward stack pointer two parameters
        pop   eax                ; Fetch current axis
        inc   eax                ; Increment it by one
        push  eax                ; Push it to the stack
        sub   esp, 8             ; Backward stack pointer two parameters
        jmp   add_center         ; Recall routine

increment_ordinate:
        add   esp, 4             ; Forward stack pointer one parameter
        pop   eax                ; Fetch current ordinate
        pop   ecx                ; Fetch current axis
        inc   eax                ; Increment ordinate by one
        mov   ecx, 0             ; Set EDX to zero
        push  ecx                ; Push axis to the stack
        push  eax                ; Push ordinate to the stack
        sub   esp, 4             ; Backward stack pointer one parameter
        jmp   add_center         ; Recall routine

bailout:
        add   esp, 12            ; Backward stack pointer three parameters
        xor   eax, eax           ; C ABI expects to see 0 in void return
        pop   ebp                ; Restore base pointer
        ret                      ; Return, jump to return address






















