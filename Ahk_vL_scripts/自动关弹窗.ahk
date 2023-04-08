#SingleInstance,Force
#Persistent

CoordMode,Mouse,Screen
CoordMode,Pixel,Screen

SetTimer,ClosePopUpWin,700

ClosePopUpWin:
WinGetTItle,Title,A
If WinActive("Ahk_Exe msEdge.exe")
{
If(InStr(Title,"知乎"))
{
BlockInput,MouseMove
ImageSearch,outPutx,outPutY,1500,240,1590,400,*15 %A_Desktop%/脚本搜索图/知乎CloseBtn1.jpg
If ErrorLevel=0
{
MouseGetPos,PosX,PosY
Sleep,200
MouseClick,Left,% outPutX,outPutY+20
MouseMove,%PosX%,%PosY%
}
ImageSearch,outPutx,outPutY,1730,710,1810,780,*15 %A_Desktop%/脚本搜索图/知乎CloseBtn2.jpg
If ErrorLevel=0
{
MouseGetPos,PosX,PosY
Sleep,200
MouseClick,Left,% outPutX+20,outPutY+20
MouseMove,%PosX%,%PosY%
}
BlockInput,MouseMoveOff
Return
}
}
Return