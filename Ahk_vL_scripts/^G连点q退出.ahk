#NoEnv  
;#Persistent
#SingleInstance Force
CoordMode, Mouse,Screen
^g::
Loop 
{
Click,,,Left
;Sleep,10
}
return

^q::
Pause,Toggle
Return