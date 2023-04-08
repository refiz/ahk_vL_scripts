#SingleInstance Force

Transparent:=250

!Down::
Transparent-=10
WinSet, Transparent,%Transparent%,A ;ahk_class Notepad
Return
!Up::
Transparent+=10
WinSet, Transparent,%Transparent%,A ;ahk_class Notepad
Return
