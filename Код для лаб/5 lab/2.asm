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
    
    MOV AH,09h ;Запросить вывод (в текстовом режиме)
    MOV AL,03h ;Выводимый символ
    MOV BH,0   ;Страница 0
    MOV BL,25h ;Зеленый фон, пурпурные символы
    MOV CX,12  ;Число выводимых символов
    INT 10h    ;Вызвать обработчик прерывания
    
    ; Завершение программы
    mov ax, 4c00h
    int 21h

end start