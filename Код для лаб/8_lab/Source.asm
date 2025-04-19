; Внешние процедуры и функции
extern ExitProcess : proc,
GetStdHandle : proc,
WriteConsoleA : proc,
ReadConsoleA : proc,
lstrlenA : proc

; Макросы для работы со стеком
STACKALLOC macro arg
push R15; Выравниваем стек
mov R15, RSP; Возьмем регистр R15, в котором будет храниться указатель на "старый" стек, и занесем значение этого регистра в стек
sub RSP, 8 * 4; Поместим в выбранный регистр значение RSP
if arg; Если число аргументов макроса не равно нулю, то освободим место и для них.
sub RSP, 8 * arg
endif
and SPL, 0F0h; Выравниваем стек(регистр SPL) по 16 - байтовой границе
endm

STACKFREE macro
mov RSP, R15; Освобождаем выделенную память
pop R15; Занесем в регистр RSP значение, сохраненное в регистре R15
; Извлечем из стека старое значение регистра R15(pop R15)
endm

NULL_FIFTH_ARG macro
mov qword ptr[RSP + 32], 0; Установка пятого аргумента в ноль(предназначен для функций ReadConsoleA, WriteConsoleA)
endm

STD_OUTPUT_HANDLE = -11; Номер стандартного потока вывода в WinAPI
STD_INPUT_HANDLE = -10; Номер стандартного потока ввода в WinAPI

.data
; Строки вывода
astr db 'A = ', 0
bstr db 'B = ', 0
ans db '47 + A - B = ', 0
mins db 'Min = ', 0
newline db 0Ah, 0
outstr db 'Press any button to exit program...', 0

hStdInput dq 0
hStdOutput dq 0
sum dq 0
minnumb dq 0

; Ошибки
formaterror db 'Input format error', 0
aerror db 'Number A out of range', 0
berror db 'Number B out of range', 0

.code
Start proc
sub RSP, 8 * 4
and SPL, 0F0h

; Получение дескрипторов для потоков ввода / вывода
mov RCX, STD_OUTPUT_HANDLE
call GetStdHandle
mov hStdOutput, RAX

mov RCX, STD_INPUT_HANDLE
call GetStdHandle
mov hStdInput, RAX

; Вывод строки "A = "
lea RAX, astr
push RAX
call OutputProc

; Ввод числа A
call InputProc
cmp R10, 1
jz err
cmp R8, 127
jg erra
cmp R8, -128
jl erra

; Вывод строки "B = "
lea RAX, bstr
push RAX
call OutputProc

; Ввод числа B
call InputProc
cmp R10, 1
jz err
mov R9, RAX
cmp R9, 127
jg errb
cmp R9, -128
jl errb

; Нахождение минимума
cmp R8, R9
jg first
mov minnumb, R8
jmp continue

first:
mov minnumb, R9

continue :
    ; Подсчет выражения 47 + A - B
    add sum, 47
    add sum, R8
    sub sum, R9

    ; Вывод результата выражения
    push sum
    call OutputNum

    ; Вывод новой строки
    lea RAX, newline
    push RAX
    call OutputProc

    ; Вывод строки "Min = "
    lea RAX, mins
    push RAX
    call OutputProc

    ; Вывод значения минимального числа
    push minnumb
    call OutputNum

    ; Вывод новой строки
    lea RAX, newline
    push RAX
    call OutputProc

    ; Ожидание нажатия клавиши
    call ExpectInput

    jmp final

    err:
lea RAX, formaterror
push RAX
call OutputProc
jmp final

erra :
    lea RAX, aerror
    push RAX
    call OutputProc
    jmp final

    errb :
    lea RAX, berror
    push RAX
    call OutputProc
    jmp final

    final:
xor RCX, RCX
call ExitProcess

Start endp

; Процедура вывода строки
OutputProc proc uses RAX RCX RDX R8 R9, string: qword
local bytesWritten : qword

STACKALLOC 1

; Получаем длину строки
mov RCX, string
call lstrlenA

; Вызываем WriteConsoleA
mov RCX, hStdOutput
mov RDX, string
mov R8, RAX
lea R9, bytesWritten
NULL_FIFTH_ARG
call WriteConsoleA

STACKFREE

ret 8
OutputProc endp

; Процедура ввода числа
InputProc proc uses RAX RCX RDX R8 R9,
local readStr[64]: BYTE,
bytesRead : DWORD

STACKALLOC 2

mov RCX, hStdInput
lea RDX, readStr
mov R8, 64
lea R9, bytesRead
NULL_FIFTH_ARG
call ReadConsoleA

xor RCX, RCX
mov ECX, bytesRead
sub ECX, 2
mov RBX, RBX

viewer :
dec RCX
cmp RCX, -1
jz scanningcomplete

mov AL, 0
mov AL, readStr[RCX]
cmp AL, '-'
jz stop

eval :
cmp AL, '0'
jl error
cmp AL, '9'
jg error

sub AL, '0'
mul R8
add RBX, RAX
jmp viewer

error :
mov R10, 1
STACKFREE
ret

stop :
neg RBX

scanningcomplete :
mov R10, 0
mov RAX, RBX
STACKFREE
ret 8 * 2
InputProc endp

; Процедура вывода числа
OutputNum proc uses RAX RCX RDX R8 R9 R10 R11,
number: qword

local numberStr[22] : BYTE

xor R8, R8
mov RAX, number
cmp number, 0
jge pos

negate :
mov numberStr[R8], '-'
inc R8

pos :
mov RBX, 10
xor RCX, RCX

read :
xor RDX, RDX
div RBX
add RDX, '0'
push RDX
inc RCX
cmp RAX, 0
jne read

write :
pop RDX
mov numberStr[R8], DL
inc R8
loop write

mov numberStr[R8], 0
lea RAX, numberStr
push RAX
call OutputProc
ret 8
OutputNum endp

; Процедура ожидания ввода
ExpectInput proc uses RAX RCX RDX R8 R9 R10 R11

local readStr : BYTE,
bytesRead : DWORD

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