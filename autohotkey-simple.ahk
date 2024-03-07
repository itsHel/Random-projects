#SingleInstance force								; ALT+s - Instant Google
#Persistent
;#InstallKeybdHook
;#UseHook 
#HotkeyModifierTimeout -1
#NoEnv
setkeydelay -1
SendMode EVENT

SetScrollLockState, off								; ALT+w - Search
setnumlockstate, on
coordmode, mouse									; ALT+d - Copy + Search Google
setmousedelay ,-1									; CTRL+Wheel - Sound
setcontroldelay -1									; ALT+f - url open  (mouse)
SetTitleMatchMode 2									; ALT+e - Save + Reaload (Notepad++)
mouseblockon := true

GroupAdd, non_sound, ahk_class CEFCLIENT
GroupAdd, non_sound, ahk_class Notepad++

GroupAdd, turn_off, ahk_class grcWindow

GroupAdd, browsers, ahk_exe Chrome.exe
GroupAdd, browsers, ahk_exe Opera.exe

HotKey Rbutton, mine										
HotKey Rbutton, off										

inc()
poz:="Novy textovy dokument"

a:=0
keep:=false
rightclick := false
;nextalarm := -1
;SetTimer, alarm, 1595 ;55
;return

; --------------------------------------------						 --------------------------------------------

~!tab::
	sleep 200
	SetCapsLockState, off
	return
	
;!capslock::return

;alarm:
;	if(A_hour*100 + A_min = nextalarm)
;	{
;		msgbox % 0, Alarm, %nextalarm%
;		nextalarm := -1
;	}
;	return

F6:: 
	Winset, Alwaysontop, , A ; ctrl + space
	msgbox, Window set to always on top (F6)
	return

!F2:: 
	if (rightclick = true)
	{
		rightclick := false
		HotKey, RButton, off
		return
	}
	else
	{
		rightclick := true
		HotKey, RButton, on
		return
	}

	
!F12::sendinput,{WheelDown}
!F11::sendinput,{WheelUp}

mine:
	sendinput,{MButton}
	return

XButton1::del
;	Suspend
;	sendinput,{Del}
;sendinput,p
;	return
XButton2::Home
NumpadEnter::tab

;$!c::send,console.log()`;{left}{left}
;sendinput
;!NumpadMult::sendplay,`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*{Space 2}`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*`*{Left 52}

^b::
	oldc := clipboard
	sendinput ^c
	sleep 40
	newc := clipboard
	clipboard := oldc
	sendinput ^v
	sleep 40
	clipboard := newc
	return

^!p::
	if (mouseblockon = true)
	{
		BlockInput MouseMove
		mouseblockon := false
	}
	else
	{
		BlockInput MouseMoveOff
		mouseblockon := true
	}
return

/*
!F2::
	if (rightclick = true)
	{
		rightclick := false
	}
	else
	{
		rightclick := true
	}
return
RButton::
	if (rightclick = true)
	{
		sendinput,{MButton}
	}
	else
	{
		sendinput,{RButton}
	}
	return
*/

;#NoTrayIcon
;listvars											!v	?		keylooger threads?

scrolllock::
	suspend
	if(getkeystate("scrolllock", "T"))
		SetScrollLockState off
	else
		SetScrollLockState on
	return
	
^esc::reload
#esc::pause
;!esc::shutdown,1											; ALT+f - Copy + run

													
:*:__get::$_GET[""]{Left 2}
:*:__pos::$_POST[""]{Left 2}
:*:__ses::$_SESSION[""]{Left 2}
:*:__p::
    sendinput,<?php  ?>
    sendinput,{Left 3}
    return

:*:for__::for(let i = 0`; i < `; i{+}{+}){Left 6}
:*:req__::request({{}{Enter}method: "GET",{Enter}json:{Enter}url:{Down}{Left}, (err, resp, data) => {{}{Enter}{Tab}if(err){Enter}{Tab}return console.error(err)`;{Enter}{Enter}{}}{Left}{Backspace 2}{Right 2}`;{Up}{Tab}
:*:form__::<form action= method=>{Enter}{Tab}<input type=submit name= value=>{Enter}{Backspace}</form>

:*:ma_::marek.b188@gmail.com

::lorem::
{
	old_clip = %clipboard%      ;save the clipboard contents
	clipboard = ""
	clipboard = Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
	ClipWait, 2
	send ^v
	sleep 100
	clipboard = %old_clip%      ;restore the clipboard contents
	return
	}
					
#IfWinActive ahk_class Photo_Lightweight_Viewer
{
	XButton2::F11
	MButton::sendinput,{Space}
}#IfWinActive
	
NumpadDot::.

;-------caps--------
;CapsLock::Enter
CapsLock::
	KeyWait, CapsLock
	If (A_PriorKey=="CapsLock")
		;sendinput,{Enter}
		;send,{Enter up}{Enter down}
		;sendPLAY,{Enter up}{Enter down}
		send,{Enter}
	Return

#If, GetKeyState("CapsLock", "P")
	q::sendinput,!{Left}
	e::Backspace
	w::Up
	a::Left
	s::Down
	d::Right
#If
	
;F7::
;o:=500
;loop
;{
;	sendinput % o
;	sendinput,{enter}
;	sleep 1000
;	o:= o-1
;}


;!^c::
;	FileReadLine,line,ini.txt,1
;	stringsplit,lineS,line
;	loop,16
;	{
;		sendinput,% chr(ord(lineS%A_index%)+7)
;	}
;	return

	
^!o::sendinput,{insert}
	
^F3::
	gui, font,, Arial
	Gui, Color, white
	r=18
	loop %max%
	{
		yy:=r+23*A_index-26
		gui, font,s11
		gui,add,text,x33 y%yy% ,% s%A_index%
		gui,add,text,x155 y%yy% cRED, -
		yy:=yy+2
		gui, font,s9
		Gui, Add, Button,x212 y%yy% w80 h18 ,% b%A_index%
		if (A_Index==6||A_Index==12)
			r:=r+13
	}
	yy:=yy+33
	gui,add,button,default x117 y%yy% w80 h22,OK
	yy:=yy+41
	Gui, Show, w327 h%yy%,Help
	return
ButtonOK:
GUI, DESTROY
Return

/*
!^a:: 															;keylogger
	fileappend,`n,d:\lenovo\log.dtp
	WinGettitle, title, A
	fileappend,%title%,d:\lenovo\log.dtp 
	HotKey Numpad0, zapisc										;numpad0
	HotKey % "~" . Chr(32), zapis								;space
	HotKey % "~" . Chr(13), zapis								;enter	
	loop 9
		HotKey Numpad%A_Index%, zapisc	
;	HotKey % "~" . Chr(A_Index+47), zapis						;top nums
	loop 26														;loop aktivovan pres kazdy stiknuty key??
		HotKey % "~" . Chr(A_Index+96), zapis
	HotKey Tab, a												;tab		
	return
a:
		suspend, on												;pozastavi vse ostatni
		sendinput,{vk09}
		suspend, off	
		fileappend,-, d:\lenovo\log.dtp
		return
zapis:
		StringTrimLeft,key,A_ThisHotkey,1
		fileappend,%key%, d:\lenovo\log.dtp
		return
zapisc:
		StringTrimLeft,key,A_ThisHotkey,6
		send,%key%
		fileappend,%key%, d:\lenovo\log.dtp
		return
*/
;!v::
;	sendinput
;	return

!t::
	if(regexmatch("25","[a-z]|-|\+"))
		msgbox,yes
	else
		msgbox,no
	return

^!s::												; Window info
{
	wingetclass, classs, A
	WinGetTitle, title, A
	WinGet, activeprocess, ProcessName, A
	clipboard = ahk_class %classs%
	MsgBox,,(copied),  Class: %classs%`nTitle: %title%`nExe: %activeprocess%`n
	return
	}


#IfWinActive ahk_class Notepad++
{
	!g::sendinput,/`*{end}`*/
	^q::sendinput,^+t  
	
}#IfWinActive

#IfWinActive ahk_exe Code.exe						;vscode
{
	$!r::
		realText := ": """ clipboard """"
		sleep 50
		sendinput,^c
		sleep 50
		rowToReplace := clipboard

		RegExMatch(rowToReplace, ":\s*"".+""", out_var)

		if(out_var == null) {
			msgbox, Not Found
			return
		}

		newRow := RegExReplace(rowToReplace, ":\s*"".+""", realText)

		clipboard := newRow

		sleep 50
		sendinput,^v
		return
}#IfWinActive

#ifWinactive ahk_class mintty						;gitbash
{
	^v::
		SetKeyDelay,1
		loop, parse, clipboard
		{
		if(thisKey == "`n")
		continue
			StringLower, thisKey, A_LoopField
			sendraw, %thisKey%
			sleep 1
		}
		SetKeyDelay,-1
		return
}#IfWinActive

#IfWinActive ahk_class CEFCLIENT
{
	!v::
		sendinput,border:1px solid red;
		return
}#IfWinActive

$!^WheelUp::^WheelUp
$!^WheelDown::^Wheeldown

$!WheelUp::sendinput,{Blind}{WheelUp 6}
$!WheelDown::sendinput,{Blind}{WheelDown 6}

;#ifWinNotActive ahk_class gdkWindowToplevel
;{
	^WheelUp::soundset +5
	^WheelDown::soundset -5
;}#ifWinNotActive

#ifWinNotActive ahk_group non_sound
{
	^+up::soundset +8
	^+down::soundset -8
}

#IfWinactive ahk_group browsers
{
	!sc003::sendinput,^+i
	!sc004::sendinput,^+o
	;xbutton2::sendinput,!{left}
	xbutton1::sendinput,!{left}
	!r::send,^l											;go to bar
	^q::send,^+t
	;^a::send,^+i
	F10::send,^w
	#If A_IsPaused
	RButton::Pause, Off
	#If
	
	^space::send, !{left}
	
	!q::send,^{F5}
}#IfWinactive
						
#ifWinNotActive ahk_group turn_off
{
	SC00B::=
	+SC00B::0
	SC003::\
	+SC003::2
	;+SC004::3
	;SC004::\
	SC005::$
	+SC005::4
	SC006::[
	+SC006::5
	SC007::^
	+SC007::6
	SC008::#
	+SC008::7
	SC009::sendinput,``
	+SC009::8
	SC00A::]
	+SC00A::9
	!SC002::
	
	$wheelup::
		sendinput,{wheelup}
		sleep 1
		sendinput,{wheelup}
		return
	$wheeldown::
		sendinput,{wheeldown}
		sleep 1
		sendinput,{wheeldown}
		return
}#ifWinNotActive

!i::
	inputbox,vstup,slovnik,,,160,122,			
	If ((ErrorLevel == 1) || (vstup=="")) 	
		return	
	WinActivateBottom , ahk_exe opera.exe
	sendinput,^t
	clipboard=https://slovnik.seznam.cz/en/?q=%vstup%  			;https://slovnik.seznam.cz/cz-en/?q=%vstup%
	sleep 100
	sendinput,^v{Enter}
	return

$!w:: 
	sleep 40
	WinActivatebottom , ahk_exe opera.exe
	sleep 10
	send,^t
	sleep 80
	return
$!Space::sendinput,{backspace}
;!q::WinActivateBottom, ahk_class Notepad++
!u::
	inputbox,vstup,Uloz.to,,,160,122,			
	If ((ErrorLevel == 1) || (vstup=="")) 	
		return	
	WinActivateBottom , ahk_exe opera.exe
	sendinput,^t
	clipboard=https://www.uloz.to/hledej?q=%vstup%
	sleep 100
	sendinput,^v{Enter}
	return

!z::
	inputbox,vstup,youtube,,,160,122,			
	If ((ErrorLevel == 1) || (vstup=="")) 	
		return	
	WinActivateBottom , ahk_exe opera.exe
	sendinput,^t
	clipboard=https://www.youtube.com/results?search_query=%vstup%
	sleep 100
	sendinput,^v{Enter}
	return
	/*
!d::
	sleep 75
	sendinput,^c
	sleep 75
	WinActivateBottom , ahk_exe opera.exe
	sendinput,^t
	sleep 75
	sendinput,^v{Enter}
	return

F9::
	gui,add,button,x10	y20 w80 default,start
	gui,add,button,x100 y20 w80,end
	Gui ,Show,,copy
	return
buttonstart:
	;Run, %comspec% /k echo ahoj
	run G:\php\old\start.bat
	gui,destroy
	return
buttonend:
	run G:\php\old\end.bat
	gui,destroy
	return
	*/
#ifWinactive ahk_class AutoHotkeyGUI
{
	esc::gui,destroy
}#ifWinactive



!^d::
{
	mousegetpos,xx,yy
	clipboard:=xx ", " yy
	msgbox x, y = %xx%, %yy%
	return
}

#IfWinactive ahk_exe chrome.exe
{
	RButton::
		keywait, RButton
		if (A_PriorKey=="RButton")
			click right
		return
		
;	#If ((GetKeyState("RButton", "P")))
;		;LButton::sendinput,!{Left}
;	#If
		
}#IfWinactive
/*
#IfWinactive ahk_class vguiPopupWindow
{
	!d::
		sendinput,username76545
		sendinput,{tab}
		sleep 20
		sendinput,7654576545
		sleep 20
		sendinput,{enter}
		return
}*/

;#SuspendExempt  ; Exempt the following hotkey from Suspend.
;#Esc::Suspend -1
;#SuspendExempt False 

;---------tab---------
;Tab::
;	KeyWait, Tab
;	If (A_PriorKey=="Tab")
;		sendinput,{Tab}
;Return

;#If, GetKeyState("Tab", "P")
;	;q::sendinput,!{Left}
;	sc004::sendinput,{Backspace 3}
;	sc003::sendinput,{Up 3}
;	q::sendinput,{Left 3}
;	w::sendinput,{Down 3}
;	e::sendinput,{right 3}
;#If
	


;			reminder, used for thunder bets		- doubletap sets alarm for next hour - 5 mins
/*
F3::
	if (A_PriorHotkey != "F3" or A_TimeSincePriorHotkey > 400)		;DOUBLETAP
	{
		nextalarm := A_hour*100 + 56
		return
	}
	else 
	{
	inputbox,cas_bonus,SetAlarm:,,,138,112
		If (cas_bonus = "")
			return
		else
			if(inStr(cas_bonus,"m"))
			{
				stringTrimRight, cas_bonus, cas_bonus, 1
				nextalarm := ((Floor((cas_bonus + A_min)/60) + A_Hour))*100 + Mod((A_min + Mod(cas_bonus,60)),60)
			}
			else
				nextalarm := (A_Hour + cas_bonus)*100 + 56
		msgbox % nextalarm ;0, NextAlarm, % substr(nextalarm,1,2) ":" substr(nextalarm,3,2)
	}
	return
!F3::msgbox % nextalarm ;0, NextAlarm, % substr(nextalarm,1,2) ":" substr(nextalarm,3,2)
*/	

; 			clicker, used for thunder bets
/*
^F1::
	click 356, 448
	sleep 77
	click 1242, 336
	sleep 88
	sendinput,5
	sleep 82
	click 1185, 682
	return
^F2::
	click 545, 442
	sleep 77
	click 1242, 336
	sleep 88
	sendinput,5
	sleep 82
	click 1185, 682
	return
#F1::
	click 356, 448
	sleep 77
	click 1242, 336
	sleep 88
	sendinput,25
	sleep 82
	click 1185, 682
	return
#F2::
	click 545, 442
	sleep 77
	click 1242, 336
	sleep 88
	sendinput,25
	sleep 82
	click 1185, 682
	return
*/

;setkeydelay pro postupne psani znaku



;		% - Forced Expression (scitani uvnitr etc)
;		$ - send ignoruje ostatni hotkeye
;		~ - necha base key projit
;		* - muzou byt stisknuty i jine znaky

;		CopyOfVar = %Var% 		; CopyOfVar := Var			;variable = literal string			;variable := "literal string"
;		:= expression mode
;		Var := MyArray%A_Index% 

;!t::
;	setkeydelay -1	    											   ; funkcni pokud neni minimalized
;	controlclick,x90 y50,ahk_class Chrome_WidgetWin_1,,left,1,,,,NA    ; aktualizace     
;	return

!^u::																	; MsgBox s volbou
	{
	msgbox,3, ahoj
	ifmsgbox no
		sendinput,4
	ifmsgbox yes
		sendinput,5
	return
	}
	
/*
~Esc::																; <-- DOUBLE TAP
if (A_PriorHotkey <> "~Esc" or A_TimeSincePriorHotkey > 400)
{
	KeyWait, Esc
	return
}
	msgbox "esc byl doubletapnut"
	return

;#d::controlsend,,^w,ahk_exe opera.exe 					;funkcni v aktivnim okne	
/*
i::																;keylogger
SetFormat, Integer, H
Loop, 0x7f
	Hotkey, % "*~" . chr(A_Index), LogKey
	Return
	
LogKey:
	Key := RegExReplace(asc(SubStr(A_ThisHotkey,0)),"^0x")
	FileAppend, % (StrLen(Key) == 1 ? "0" : "") . Key, d:\c.log
	Return
!F4::
	x:={x1:"dass",x2:122}
	x.x1 := "fffffffff"
	x["x1"] := "dddddd"
	msgbox % x.x1	
	*/
	

inc()
{
	global
		
	s1:="Copy run"
	b1:="ALT+d"
	s2:="Insta Google"
	b2:="ALT+s"
	s3:="Youtube"
	b3:="ALT+y"
	s4:="Slovnik"
	b4:="ALT+e"
	s5:="Ulozto"
	b5:="ALT+u"
	s6:="Youtube dl"
	b6:="F6"

	s7:="Suspend"
	b7:="WIN+esc"
	s8:="Reload"
	b8:="CTRL+`;"

	s9:="Window info"
	b9:="CTRL+ALT+s"
	s10:="Mouse pos"
	b10:="CTRL+ALT+d"
	s11:="Keylogger"
	b11:="CTRL+ALT+a"
	s12:="ahk.txt"
	b12:="Win+a"

	s13:="hmail"
	b13:="_he"
	s14:="mmail"
	b14:="_ma"
	s16:="ahk.txt"
	b16:="Win+a"
	s15:="Copy save"
	b15:="Win+s"
	s16:="reopen"
	b16:="CTRL+q"
	
	max=16
}
