; ������� ��������� � �������
extern ExitProcess : proc,
    GetStdHandle : proc,
    WriteConsoleA : proc,
    ReadConsoleA : proc,
    lstrlenA : proc

; ������� ��� ������ �� ������
STACKALLOC macro arg
    push R15 ; ����������� ����
    mov R15, RSP ; ������� ������� R15, � ������� ����� ��������� ��������� �� "������" ����
    sub RSP, 8 * 4 ; �������� � ��������� ������� �������� RSP
    if arg ; ���� ����� ���������� ������� �� ����� ����, �� ��������� ����� � ��� ���.
        sub RSP, 8 * arg
    endif
    and SPL, 0F0h ; ����������� ���� �� 16-�������� �������
endm

STACKFREE macro
    mov RSP, R15 ; ����������� ���������� ������
    pop R15 ; ������� � ������� RSP ��������, ����������� � �������� R15
endm

NULL_FIFTH_ARG macro
    mov qword ptr [RSP + 32], 0 ; ��������� ������ ��������� � ����
endm

STD_OUTPUT_HANDLE = -11
STD_INPUT_HANDLE = -10

.data
    ; ������ ������
    astr db 'A = ', 0
    bstr db 'B = ', 0
    ans db '450Ch - A + B = ', 0
    maxs db 'Max = ', 0
    newline db 0Ah, 0
    outstr db 'Press any button to exit program...', 0

    hStdInput dq 0
    hStdOutput dq 0
    sum dq 0
    maxnumb dq 0

    ; ������ ��� �����/������
    readStr db 64 dup(0)
    bytesRead dd 0
    numberStr db 22 dup(0)

    ; ������
    formaterror db 'Input format error', 0
    aerror db 'Number A out of range', 0
    berror db 'Number B out of range', 0

.code
Start proc
    sub RSP, 8 * 4
    and SPL, 0F0h

    ; ��������� ������������
    mov RCX, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov hStdOutput, RAX

    mov RCX, STD_INPUT_HANDLE
    call GetStdHandle
    mov hStdInput, RAX

    ; ���� A
    lea RAX, astr
    push RAX
    call OutputProc

    call InputProc
    cmp R10, 1
    jz err ; ������ �������
    cmp R10, 2
    jz erra ; ������ ���������
    mov AL, BL ; ��������� ��������� � 8-������ �������
    movsx R8, AL ; ��������� A ��� 64-������ �����

    ; ���� B
    lea RAX, bstr
    push RAX
    call OutputProc

    call InputProc
    cmp R10, 1
    jz err ; ������ �������
    cmp R10, 2
    jz errb ; ������ ���������
    mov AL, BL ; ��������� ��������� � 8-������ �������
    movsx R9, AL ; ��������� B ��� 64-������ �����

    ; ���������� F = 450Ch - A + B
    xor RAX, RAX
    mov RAX, 450Ch ; 450Ch = 17676
    sub RAX, R8
    add RAX, R9
    mov sum, RAX

    ; ���������� ���������
    cmp R8, R9
    jg first
    mov maxnumb, R9
    jmp continue

first:
    mov maxnumb, R8

continue:
    ; ����� ���������
    lea RAX, ans
    push RAX
    call OutputProc

    ; ����� F
    push sum
    call OutputNum

    ; ����� ����� ������
    lea RAX, newline
    push RAX
    call OutputProc

    ; ����� "Max = "
    lea RAX, maxs
    push RAX
    call OutputProc

    ; ����� ���������
    push maxnumb
    call OutputNum

    ; �������� �����
    call ExpectInput

    jmp final

err:
    lea RAX, formaterror
    push RAX
    call OutputProc
    jmp final

erra:
    lea RAX, aerror
    push RAX
    call OutputProc
    jmp final

errb:
    lea RAX, berror
    push RAX
    call OutputProc
    jmp final

final:
    xor RCX, RCX
    call ExitProcess

Start endp

; ��������� ������ ������
OutputProc proc uses RAX RCX RDX R8 R9, string: qword
    local bytesWritten: qword

    STACKALLOC 1

    ; �������� ����� ������
    mov RCX, string
    call lstrlenA

    ; �������� WriteConsoleA
    mov RCX, hStdOutput
    mov RDX, string
    mov R8, RAX
    lea R9, bytesWritten
    NULL_FIFTH_ARG
    call WriteConsoleA

    STACKFREE
    ret 8
OutputProc endp

; ��������� ����� �����
InputProc proc uses RAX RCX RDX R8 R9
    STACKALLOC 2

    ; ������ ������
    mov RCX, hStdInput
    lea RDX, readStr
    mov R8, 64
    lea R9, bytesRead
    NULL_FIFTH_ARG
    call ReadConsoleA

    ; ������������ ������
    xor RCX, RCX
    mov ECX, bytesRead
    cmp ECX, 2
    jl error   ; ������ ������
    sub ECX, 2 ; ������� CR/LF
    cmp ECX, 0
    jle error ; ������ ������ ����� �������� CR/LF

    lea RSI, readStr
    xor RBX, RBX ; �����
    xor R10, R10 ; ���� ������: 0 - ��� ������, 1 - ������, 2 - ��������
    xor R11, R11 ; ���� �������������� �����
    xor R12, R12 ; ������� ����

    ; �������� ������� �������
    mov AL, [RSI]
    cmp AL, '-'
    jz process_negative
    cmp AL, '+'
    jz skip_sign
    ; �������� �����
    cmp AL, '0'
    jl error
    cmp AL, '9'
    jg error
    sub AL, '0'
    mov RBX, RAX
    inc R12
    inc RSI
    dec ECX
    jmp process_digits

skip_sign:
    inc RSI
    dec ECX
    jmp process_digits

process_negative:
    inc RSI
    dec ECX
    cmp ECX, 0
    jle error ; ������ �����
    inc R11 ; ���� �������������� �����

process_digits:
    xor RAX, RAX ; �����������
process_digit:
    cmp ECX, 0
    jle done_processing ; �����, ���� ������� �����������
    mov AL, [RSI]
    cmp AL, '0'
    jl error
    cmp AL, '9'
    jg error
    inc R12 ; ������� ����
    sub AL, '0'
    ; �������������� ������ � �����
    imul RBX, RBX, 10
    jo error_overflow
    add RBX, RAX
    jo error_overflow
    inc RSI
    dec ECX
    jmp process_digit

done_processing:
    cmp R12, 0
    je error ; ��� ����

    ; �������� ���������
    cmp R11, 0
    jnz check_negative
    cmp RBX, 127
    jg error_overflow
    jmp done

check_negative:
    cmp RBX, 128
    jg error_overflow
    neg RBX
    cmp RBX, -128
    jl error_overflow

done:
    mov RAX, RBX
    STACKFREE
    ret 8 * 2

error_overflow:
    mov R10, 2 ; ������ ���������
    STACKFREE
    ret 8 * 2

error:
    mov R10, 1 ; ������ �������
    STACKFREE
    ret 8 * 2

InputProc endp

; ��������� ������ �����
OutputNum proc uses RAX RCX RDX R8 R9 R10 R11, number: qword
    STACKALLOC 1

    xor R8, R8 ; ������� ��������
    mov RAX, number
    cmp RAX, 0
    jge pos

negate:
    lea RDX, numberStr
    mov byte ptr [RDX + R8], '-'
    inc R8
    neg RAX ; ������ �������������

pos:
    mov RBX, 10
    xor RCX, RCX ; ���������� ����

read:
    xor RDX, RDX
    cqo ; �������� ����������
    idiv RBX ; ������� � ������ �����
    add RDX, '0' ; ����� -> ������
    push RDX
    inc RCX ; �������
    cmp RAX, 0
    jne read

    ; ��������� ����
    cmp RCX, 0
    je zero_case

write:
    pop RDX
    lea RAX, numberStr
    mov byte ptr [RAX + R8], DL
    inc R8
    loop write
    jmp done

zero_case:
    mov byte ptr [numberStr], '0'
    inc R8

done:
    lea RAX, numberStr
    mov byte ptr [RAX + R8], 0 ; ����-����������
    lea RAX, numberStr
    push RAX
    call OutputProc

    STACKFREE
    ret 8
OutputNum endp

; ��������� �������� �����
ExpectInput proc uses RAX RCX RDX R8 R9 R10 R11
    STACKALLOC 1

    lea RAX, outstr
    push RAX
    call OutputProc

    mov RCX, hStdInput
    lea RDX, readStr
    mov R8, 1
    lea R9, bytesRead
    NULL_FIFTH_ARG
    call ReadConsoleA

    STACKFREE
    ret
ExpectInput endp

end