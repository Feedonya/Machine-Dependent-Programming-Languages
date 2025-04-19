extrn ExitProcess :proc    ; ������� ������� ExitProcess
extrn MessageBoxA :proc    ; ������� ������� MessageBoxA

.data
caption db '����!', 0      ; ��������� ����
message db 'Musatov Fedor', 0  ; ���������

.code
Start proc
    sub RSP, 8 * 5         ; ������������ ����� (����������� ��� x64)

    xor RCX, RCX           ; hWnd = NULL
    lea RDX, message       ; lpText (����� ���������)
    lea R8, caption        ; lpCaption (��������� ����)
    xor R9, R9             ; uType = 0 (��� ����)

    call MessageBoxA       ; �������� MessageBoxA

    xor RCX, RCX           ; ��� ���������� (exit code = 0)
    call ExitProcess       ; ��������� ���������
Start endp
end