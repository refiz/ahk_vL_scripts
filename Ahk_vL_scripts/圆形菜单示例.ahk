#SingleInstance, Force

CoordMode,ToolTip,Screen

String:=["a","b","c","d","e","f","g","h","i","j","k","l"]

Global PI:=3.1415926
Global Radius:=100
Global Radians:=(PI/180)*Round(360/String.Length())

~LButton::
    MouseGetPos,PosX,PosY
    Loop,% String.Length()
    {
        Y:=PosY+Radius*Cos(radians*A_Index)
        X:=PosX+Radius*Sin(radians*A_Index)
        PopUpStr(String[A_Index],X,Y,A_Index)
    }
Return

PopUpStr(String,PosX,PosY,Weight)
{
    ClipLenth:=2
    Loop,% StrLen(StrReplace(String, A_Space, "")) ;去除空格并获取长度
    {
        SplitStr:=SubStr(String,1,ClipLenth)
        ToolTip,%SplitStr%,%PosX%,%PosY%,%Weight%
        ClipLenth+=1
        Sleep,10
    }
    Sleep,150
Return
}