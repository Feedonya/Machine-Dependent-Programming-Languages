extrn ExitProcess : proc, ; ������� ���� ��������� � windows �����
MessageBoxA : proc; (����� WinApi)




.data
caption db '����!', 0; ������� ������ ��� ��������� ����(������ $ ���������� 0)
message db Musatov Fedor', 0   ; ������� ������ ��� ���������� ������ (������ $ ���������� 0)

.code
Start proc
sub RSP, 8 * 5; ������������ �����

xor RCX, RCX; ������������� ������ ��������(hWnd = NULL)
lea RDX, message; ������������� ������ ��������(lpText)
lea R8, caption; ������������� ������ ��������(lpCaption)
xor R9, R9; ������������� ��������� ��������(uType = 0)

call MessageBoxA; �������� ���������� ����

xor RCX, RCX; ��� ���������� ������ �������� ������� RCX

call ExitProcess; �������� ������� ���������� ����������
Start endp
end
