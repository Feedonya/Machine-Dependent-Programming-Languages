extrn ExitProcess : proc, ; выводим наше сообщение в windows форме
MessageBoxA : proc; (вызов WinApi)




.data
caption db '»нфо!', 0; создаем строку дл€ заголовка окна(вместо $ используем 0)
message db Musatov Fedor', 0   ; создаем строку дл€ выводимого текста (вместо $ используем 0)

.code
Start proc
sub RSP, 8 * 5; выравнивание стека

xor RCX, RCX; устанавливаем первый параметр(hWnd = NULL)
lea RDX, message; устанавливаем второй параметр(lpText)
lea R8, caption; устанавливаем третий параметр(lpCaption)
xor R9, R9; устанавливаем четвертый параметр(uType = 0)

call MessageBoxA; вызываем диалоговое окно

xor RCX, RCX; дл€ завершени€ работы обнул€ем регистр RCX

call ExitProcess; вызываем функцию завершени€ приложени€
Start endp
end
