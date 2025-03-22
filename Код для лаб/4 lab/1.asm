.model small
.stack 100h

.data
array       dw 20 dup(0)    ; Массив из 20 слов (16 бит)
buffer      db 6 dup('$')   ; Буфер для чисел (максимум 5 цифр)
newline     db 13,10,'$'    ; Перевод строки

.code
start:
    mov ax, @data
    mov ds, ax
    mov es, ax

    ; Заполнение нечетных чисел (1,3,...,19)
    mov cx, 10
    mov ax, 1
    lea di, array
fill_odds:
    stosw           ; Записываем AX в [DI] и увеличиваем DI на 2
    add ax, 2
    loop fill_odds

    ; Заполнение квадратов
    mov cx, 10
    lea si, array   ; Указатель на нечетные числа
    lea di, array+20; Указатель на вторую половину (10*2=20 байт)
fill_squares:
    lodsw           ; Загружаем число в AX
    mul ax          ; AX = AX * AX (результат в DX:AX)
    stosw           ; Записываем AX (старшая часть DX игнорируется)
    loop fill_squares

    ; Вывод массива
    mov cx, 20
    lea si, array
    xor bx, bx      ; Счетчик элементов

print_loop:
    lodsw           ; Загружаем число в AX

    ; Сохраняем CX
    push cx

    ; Преобразование AX в строку
    lea di, buffer + 5
    mov byte ptr [di], '$'
    mov cx, 10
convert:
    xor dx, dx
    div cx          ; AX = DX:AX / 10
    add dl, '0'
    dec di
    mov [di], dl
    test ax, ax
    jnz convert

    ; Восстанавливаем CX
    pop cx

    ; Удаляем ведущие нули
    cmp byte ptr [di], '0'
    jne print
    mov byte ptr [di], ' '

print:
    ; Вывод числа
    mov ah, 09h
    mov dx, di      ; Адрес начала числа в буфере
    int 21h

    ; Вывод разделителя
    inc bx
    mov dl, 9
    cmp bx, 10
    je print_nl
    cmp bx, 20
    je print_nl
    jmp print_cont

print_nl:
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    jmp next

print_cont:
    mov ah, 02h
    int 21h

next:
    loop print_loop

    ; Завершение
    mov ax, 4C00h
    int 21h
end start