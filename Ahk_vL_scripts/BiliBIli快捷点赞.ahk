#SingleInstance,Force

CoordMode,Mouse,Screen
CoordMode,Pixel,Screen

~`::
WinGetTItle,Title,A
If WinActive("Ahk_Exe msEdge.exe")
{
If(InStr(Title,"哔哩哔哩"))
{
BlockInput,MouseMove
ImageSearch,outPutx,outPutY,620,130,1230,1060,*20 %A_Desktop%/脚本搜索图/哔哩哔哩LikeBtn.jpg
If ErrorLevel=0
MouseClick,Left,% outPutX+20,outPutY+20
BlockInput,MouseMoveOff
Return
}
}
Return