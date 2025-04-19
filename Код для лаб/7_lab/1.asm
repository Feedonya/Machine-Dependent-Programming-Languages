extrn ExitProcess : proc,
MessageBoxA : proc,
GetUserNameA : proc,
GetComputerNameA : proc,
GetTempPathA : proc,
wsprintfA : proc

.data

cap db 'Вывод информации о компьютере', 0; заголовок окна
fmt db 'Username: %s', 0Ah,
'Computer name: %s', 0Ah,
'TMP Path: %s', 0Ah
szMAX_COMP_NAME equ 16; максимальный размер строки имени компьютера(equ - директива)
szUNLEN equ 257; максимальный размер имени пользователя
szMAX_PATH equ 261; максимальный размер строки с путём к директории temp

.code
Start proc
local _msg[1024] : byte,
_username[szUNLEN] : byte,
_compname[szMAX_COMP_NAME] : byte,
_temppath[szMAX_PATH] : byte,
_size : dword

sub RSP, 8 * 5; смещение указателя стека(4 аргумента по 8 байт = 32 байта + адрес возврата 8 байт = 40 байт)
and SPL, 0F0h; выравнивание стека

mov _size, szUNLEN
lea RCX, _username
lea RDX, _size
call GetUserNameA; функция для получения имени пользователя

mov _size, szMAX_COMP_NAME
lea RCX, _compname
lea RDX, _size
call GetComputerNameA; функция для получения имени компьютера

mov _size, szMAX_PATH
lea RCX, _size
lea RDX, _temppath
call GetTempPathA; вызываем функцию возвращающую путь к директории temp

lea RCX, _msg; поместили адрес строки - сообщения
lea RDX, fmt; адрес строки форматирования
lea R8, _username; адрес строки имени пользователя
lea R9, _compname; адрес строки имени компа
lea R10, _temppath; адрес строки пути до папки temp, который мы потом отправим в стек
mov qword ptr[RSP + 20h], R10; отправляем в стек(qword - 8 байт) (затем 28h, 30h())
call wsprintfA; Первые аргументы для форматирования помещаются в регистры по соглашению __fastcall, а остальные - в стек

xor RCX, RCX; записываем 0 в RCX(родительское окно - рабочий стол)
lea RDX, _msg; в RDX передаем адрес строки, для вывода на экран(_msg)
lea R8, cap; адрес заголовка
xor R9, R9; записываем 0 в R9(отвечает за показ кнопки Ok)
call MessageBoxA; вызов процедуры вывода диалогового окна

xor RCX, RCX
call ExitProcess; программа завершена без ошибок(если 0, то программа завершилась без ошибок)

Start endp
end
