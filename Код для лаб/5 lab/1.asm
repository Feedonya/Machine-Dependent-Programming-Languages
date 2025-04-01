.model small
.stack 100h
.data
first_symbol db 45h ; ��� ������� 'E'
coloring     db 05h ; ������� ����� (���)

.code
start:
    mov ax, @data
    mov ds, ax       ; ��������� �������� ������
    
    mov ax, 0b800h   ; ��������� �� �����������
    mov es, ax
    
    ; ��������� ���������� ������
    mov ah, 00h
    mov al, 03h
    int 10h
    
    ; ��������� �������� ��������
    mov ah, 05h
    mov al, 00h
    int 10h
    
    call B10DISPLAY   ; ����� ������� ������
    
    ; ���������� ���������
    mov ax, 4c00h
    int 21h

B10DISPLAY proc
    push ax
    push cx
    push dx
    push si
    push di
    push es            ; ���������� ���������
    
    mov al, first_symbol
    mov ah, coloring
    mov di, 1640      ; ��������� ����� � ����������� (((10*80)+20)*2) = 1640
    mov cx, 10        ; ���������� �����
    
Row:
    push cx          ; ��������� ������� �����
    mov cx, 20       ; ���������� �������� � ������
    
Col:
    mov es:[di], ax  ; ������ ������� � ��������
    add di, 2        ; ������� � ���������� �������
    loop Col         ; ��������� ��� ���� ��������
    
    add di, 120      ; ������� �� ����� ������ (80*2 - 20*2 = 120)
    pop cx           ; ������������ ������� �����
    inc al           ; ��������� ������
    inc ah           ; ��������� ����� (���� �����)
    
    loop Row         ; ��������� ��� ���� �����
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop ax             ; �������������� ���������
    ret
B10DISPLAY endp

end start