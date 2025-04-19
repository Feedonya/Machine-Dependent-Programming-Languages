extrn ExitProcess :proc    ; внешн€€ функци€ ExitProcess
extrn MessageBoxA :proc    ; внешн€€ функци€ MessageBoxA

.data
caption db '»нфо!', 0      ; заголовок окна
message db 'Musatov Fedor', 0  ; сообщение

.code
Start proc
    sub RSP, 8 * 5         ; выравнивание стека (об€зательно дл€ x64)

    xor RCX, RCX           ; hWnd = NULL
    lea RDX, message       ; lpText (текст сообщени€)
    lea R8, caption        ; lpCaption (заголовок окна)
    xor R9, R9             ; uType = 0 (тип окна)

    call MessageBoxA       ; вызываем MessageBoxA

    xor RCX, RCX           ; код завершени€ (exit code = 0)
    call ExitProcess       ; завершаем программу
Start endp
end