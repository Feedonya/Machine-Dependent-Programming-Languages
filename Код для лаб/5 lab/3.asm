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
    
    MOV AH,09h ;��������� ����� (� ��������� ������)
    MOV AL,2Ah ;��������� ������
    MOV BH,0   ;�������� 0
    MOV BL,48h ;������� ���, ����� �������
    MOV CX,8  ;����� ��������� ��������
    INT 10h    ;������� ���������� ����������
    
    ; ���������� ���������
    mov ax, 4c00h
    int 21h

end start