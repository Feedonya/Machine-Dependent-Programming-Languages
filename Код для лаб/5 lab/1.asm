.model small
.stack 100h
.data
first_symbol db 45h ; Код символа 'E'
coloring     db 05h ; Атрибут цвета (фон)

.code
start:
    mov ax, @data
    mov ds, ax       ; Установка сегмента данных
    
    mov ax, 0b800h   ; Указатель на видеопамять
    mov es, ax
    
    ; Установка текстового режима
    mov ah, 00h
    mov al, 03h
    int 10h
    
    ; Установка активной страницы
    mov ah, 05h
    mov al, 00h
    int 10h
    
    call B10DISPLAY   ; Вызов функции вывода
    
    ; Завершение программы
    mov ax, 4c00h
    int 21h

B10DISPLAY proc
    push ax
    push cx
    push dx
    push si
    push di
    push es            ; Сохранение регистров
    
    mov al, first_symbol
    mov ah, coloring
    mov di, 1640      ; Начальный адрес в видеопамяти (((10*80)+20)*2) = 1640
    mov cx, 10        ; Количество строк
    
Row:
    push cx          ; Сохраняем счетчик строк
    mov cx, 20       ; Количество символов в строке
    
Col:
    mov es:[di], ax  ; Запись символа и атрибута
    add di, 2        ; Переход к следующему символу
    loop Col         ; Повторить для всех столбцов
    
    add di, 120      ; Переход на новую строку (80*2 - 20*2 = 120)
    pop cx           ; Восстановить счетчик строк
    inc al           ; Следующий символ
    inc ah           ; Изменение цвета (если нужно)
    
    loop Row         ; Повторить для всех строк
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop ax             ; Восстановление регистров
    ret
B10DISPLAY endp

end start