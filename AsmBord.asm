;;nasm -fwin32 AsmBord.asm
;;ALINK -oPE AsmBord WIN32.LIB -entry main
;;関数宣言;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
extern MessageBoxA
extern GetSystemMetrics
extern CreateFontA
extern ExitProcess
extern GetDesktopWindow
extern CreateDCA
extern SetBkMode
extern SelectObject
extern lstrlenA
extern GetTextExtentPoint32A
extern GetClientRect
extern BeginPath
extern TextOutA
extern EndPath
extern SelectClipPath
extern CreateSolidBrush
extern FillRect
extern Sleep
extern ReleaseDC
extern RedrawWindow
extern UpdateWindow
extern GetAsyncKeyState
extern lstrcpyA
extern OpenClipboard
extern EmptyClipboard
extern CloseClipboard
extern GetLocalTime
extern wsprintfA
extern FindWindowA
extern PostMessageA
extern SetActiveWindow





;;構造体定義;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
STRUC SIZE
	.cx		resd	1	;long
	.cy		resd	1	;long
ENDSTRUC

STRUC RECT
	.left	resd	1	;long
	.top	resd	1	;long
	.right	resd	1	;long
	.bottom	resd	1	;long
ENDSTRUC

STRUC SYSTEMTIME
	.wYear	resw	1;WORD
    .wMonth	resw	1;WORD
    .wDayOfWeek	resw	1;WORD
    .wDay	resw	1;WORD
    .wHour	resw	1;WORD
    .wMinute	resw	1;WORD
    .wSecond	resw	1;WORD
    .wMilliseconds	resw	1;WORD
ENDSTRUC

;;変数and定数;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data
display: db 'DISPLAY',0
fontname: db'メイリオ',0
enastr:	db 'ENABLE',0
disstr: db 'DISABLE',0
exit:	db 'CLOSE',0
clipbord: db 'CLEAR CLIPBOARD',0
shutdownstr: db 'Shutdown...',0
shutdowncmd: db 'Shell_TrayWnd',0
timeformat: db '%d:%d:%d@%d/%d',0
helps1: db 'CLIPBORD (CTRL&DOWN)',0
helps2: db 'TIME (CTRL&UP)',0
helps3: db 'SHUTDOWN (LRSHIFT)',0
helps4: db 'HELP (CTRL&SPACE)',0
helps5: db 'ON/OFF (LRCTROL)',0
helps6: db 'EXIT (SHIFT&ESC)',0
size:
ISTRUC SIZE
at SIZE.cx, dd 0
at SIZE.cy, dd 0
IEND
rect:
ISTRUC RECT
at RECT.left,	dd 0
at RECT.top,	dd 0
at RECT.right,	dd 0
at RECT.bottom,	dd 0
IEND
systime:
ISTRUC SYSTEMTIME
at SYSTEMTIME.wYear,	dw	0
at SYSTEMTIME.wMonth,	dw	0
at SYSTEMTIME.wDayOfWeek,	dw	0
at SYSTEMTIME.wDay,	dw	0
at SYSTEMTIME.wHour,	dw	0
at SYSTEMTIME.wMinute,	dw	0
at SYSTEMTIME.wSecond,	dw	0
at SYSTEMTIME.wMilliseconds,	dw	0
IEND
WIDTH: 	dd 1
HEIGHT: dd 1
hfont:	dd 1
hwnd:	dd 1
hdc:	dd 1
flag: 	dd 1

section .bss
buf:	resb	256

;;メインプログラム;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
global main

main:
	;画面サイズ取得--------------------
	push dword 0				;SM_CXSCREEN
	call GetSystemMetrics
	mov  [WIDTH],EAX
	push dword 1				;SM_CYSCREEN
	call GetSystemMetrics
	mov  [HEIGHT],EAX
	
	;フォント生成----------------------
	push dword fontname 		;メイリオ
	push dword 31h				;FIXED_PITCH(1h) | FF_MODERN(30h)
	push dword 2h	 			;PROOF_QUALITY
	push dword 1h				;CLIP_CHARACTER_PRECIS
	push dword 2h				;OUT_CHARACTER_PRECIS
	push dword 80h				;SHIFTJIS_CHARSET
	push dword 0h				;FALSE
	push dword 0h				;FALSE
	push dword 0h				;FALSE
	push dword 190h				;FW_REGULAR (FW_NORMAL)
	push dword 0h				;
	push dword 0h				;
	push dword 0h				;
	push dword 96h				;
	call CreateFontA   			;
	mov [hfont],EAX				;
	
	;メインループ------------------------
	mov [flag],dword 1h
loop:
enable:
	cmp [flag],dword 0h			;enableがfalseかどうか
	je	disable					;FALSEならdisableへジャンプ
	push dword 10h				;VK_SHIFT
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	clip					;クリップボードへ
	push dword 1bh				;VK_ESCAPE
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	clip					;クリップボードへ
	push dword exit				;EXIT
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
	jmp end						;終了
clip:
	push dword 11h				;VK_CONTROL
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	shutdown				;シャットダウンへ
	push dword 28h				;VK_DOWN
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	shutdown				;シャットダウンへ
	push dword 0				;NULL
	call OpenClipboard			;
	test eax,eax				;
	je	shutdown				;
	call EmptyClipboard			;
	call CloseClipboard			;
	push dword clipbord			;
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
shutdown:
	push dword 0xa0				;VK_LSHIFT
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	time					;時刻へ
	push dword 0xa1				;VK_RSHIFT
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	time					;時刻へ
	push 0						;NULL
	push shutdowncmd			;
	call FindWindowA			;
	push 0						;
	push 0						;
	push 10h					;
	push EAX					;
	call PostMessageA			;
	push EAX					;
	call SetActiveWindow		;
	push dword shutdownstr		;
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
time:
	push dword 11h				;VK_CONTROL
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	help					;disableへ
	push dword 26h				;VK_UP
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	help					;disableへ
	push systime				;
	call GetLocalTime			;
	xor EAX,EAX					;EAX初期化
	mov AX,word [systime+SYSTEMTIME.wDay]
	push EAX
	xor EAX,EAX					;EAX初期化
	mov AX,word [systime+SYSTEMTIME.wMonth]
	push EAX
	xor EAX,EAX					;EAX初期化
	mov AX,word [systime+SYSTEMTIME.wSecond]
	push EAX
	xor EAX,EAX					;EAX初期化
	mov AX,word [systime+SYSTEMTIME.wMinute]
	push EAX
	xor EAX,EAX					;EAX初期化
	mov AX,word [systime+SYSTEMTIME.wHour]
	push EAX
	push dword timeformat		;
	push dword buf				;
	call wsprintfA				;
	call DesktopDraw			;
help:
	push dword 11h				;VK_CONTROL
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	disable					;disableへ
	push dword 20h				;VK_SPACE
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	disable					;disableへ
	push dword helps1			;
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
	push dword helps2			;
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
	push dword helps3			;
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
	push dword helps4			;
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
	push dword helps5			;
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
	push dword helps6			;
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
disable:
	push dword 0xa2				;VK_LCONTROL
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je waitnow					;
	push dword 0xa3				;VK_RCONTROL
	call GetAsyncKeyState		;
	test EAX,8000h				;
	je	waitnow					;
	xor [flag],dword 1h			;flagの反転
	cmp [flag],dword 0h			;
	je setdisable				;
	push dword enastr			;ENABLE
	jmp setok					;
setdisable:
	push dword disstr			;DISABLE
setok:
	push dword buf				;
	call lstrcpyA				;
	call DesktopDraw			;
waitnow:
	push dword 100				;
	call Sleep					;
	jmp loop					;
end:
	push dword 187h				;RDW_ALLCHILDREN | RDW_UPDATENOW |RDW_ERASE | RDW_INVALIDATE | RDW_INTERNALPAINT
	push dword 0				;
	push dword 0				;
	push dword 0				;
	call RedrawWindow			;
	push dword 0				;
	call UpdateWindow			;
	push dword 0
	call ExitProcess
	ret
DesktopDraw:
	call GetDesktopWindow
	mov [hwnd],EAX
	push dword 0				;NULL
	push dword 0				;NULL
	push dword 0				;NULL
	push dword display			;DISPLAY
	call CreateDCA				;
	mov	[hdc],EAX
	push dword 1				;TRANSPARENT
	push dword [hdc]			;
	call SetBkMode				;
	push dword [hfont]			;
	push dword [hdc]				;
	call SelectObject
	push dword size				;size
	push dword buf				;buf
	call lstrlenA				;
	push dword EAX				;
	push dword buf				;
	push dword [hdc]			;
	call GetTextExtentPoint32A	;
	push dword rect				;
	push dword [hwnd]			;
	call GetClientRect			;
	;;描画処理20回
	xor ESI,ESI					;ESI=0
for:
	push dword [hdc]				;
	call BeginPath				;
	push dword buf				;buf
	call lstrlenA				;
	push dword EAX				;
	push dword buf				;
	mov EAX,[HEIGHT]			;
	sub EAX,[size+SIZE.cy]		;
	push dword EAX				;HEIGHT-size.cy
	mov EAX,[WIDTH]				;
	sub EAX,[size+SIZE.cx]		;
	sar EAX,1					;÷2
	push dword EAX				;HEIGHT-size.cx
	push dword [hdc]				;
	call TextOutA				;
	push dword [hdc]				;
	call EndPath				;
	push dword 1h				;RGN_AND
	push dword [hdc]			;
	call SelectClipPath			;
	push 00ff00h				;0x00ff00
	call CreateSolidBrush		;
	push dword EAX				;HBRUSH
	push dword rect				;
	push dword [hdc]			;
	call FillRect				;
	push 1Eh					;30
	call Sleep					;
	inc ESI						;EBX++
	cmp ESI,20					;
	jne	for						;
	push dword [hdc]			;
	push dword [hwnd]			;
	call ReleaseDC				;
	push dword 187h				;RDW_ALLCHILDREN | RDW_UPDATENOW |RDW_ERASE | RDW_INVALIDATE | RDW_INTERNALPAINT
	push dword 0				;
	push dword 0				;
	push dword 0				;
	call RedrawWindow			;
	push dword 0				;
	call UpdateWindow			;
	ret							;
