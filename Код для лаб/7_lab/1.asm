extrn ExitProcess : proc,
MessageBoxA : proc,
GetUserNameA : proc,
GetComputerNameA : proc,
GetTempPathA : proc,
wsprintfA : proc

.data

cap db '����� ���������� � ����������', 0; ��������� ����
fmt db 'Username: %s', 0Ah,
'Computer name: %s', 0Ah,
'TMP Path: %s', 0Ah
szMAX_COMP_NAME equ 16; ������������ ������ ������ ����� ����������(equ - ���������)
szUNLEN equ 257; ������������ ������ ����� ������������
szMAX_PATH equ 261; ������������ ������ ������ � ���� � ���������� temp

.code
Start proc
local _msg[1024] : byte,
_username[szUNLEN] : byte,
_compname[szMAX_COMP_NAME] : byte,
_temppath[szMAX_PATH] : byte,
_size : dword

sub RSP, 8 * 5; �������� ��������� �����(4 ��������� �� 8 ���� = 32 ����� + ����� �������� 8 ���� = 40 ����)
and SPL, 0F0h; ������������ �����

mov _size, szUNLEN
lea RCX, _username
lea RDX, _size
call GetUserNameA; ������� ��� ��������� ����� ������������

mov _size, szMAX_COMP_NAME
lea RCX, _compname
lea RDX, _size
call GetComputerNameA; ������� ��� ��������� ����� ����������

mov _size, szMAX_PATH
lea RCX, _size
lea RDX, _temppath
call GetTempPathA; �������� ������� ������������ ���� � ���������� temp

lea RCX, _msg; ��������� ����� ������ - ���������
lea RDX, fmt; ����� ������ ��������������
lea R8, _username; ����� ������ ����� ������������
lea R9, _compname; ����� ������ ����� �����
lea R10, _temppath; ����� ������ ���� �� ����� temp, ������� �� ����� �������� � ����
mov qword ptr[RSP + 20h], R10; ���������� � ����(qword - 8 ����) (����� 28h, 30h())
call wsprintfA; ������ ��������� ��� �������������� ���������� � �������� �� ���������� __fastcall, � ��������� - � ����

xor RCX, RCX; ���������� 0 � RCX(������������ ���� - ������� ����)
lea RDX, _msg; � RDX �������� ����� ������, ��� ������ �� �����(_msg)
lea R8, cap; ����� ���������
xor R9, R9; ���������� 0 � R9(�������� �� ����� ������ Ok)
call MessageBoxA; ����� ��������� ������ ����������� ����

xor RCX, RCX
call ExitProcess; ��������� ��������� ��� ������(���� 0, �� ��������� ����������� ��� ������)

Start endp
end
