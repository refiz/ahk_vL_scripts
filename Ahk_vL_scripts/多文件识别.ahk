#SingleInstance, Force

;以存储每个窗口的标题为例

Global Win_Info:={} ;存储每个窗口的信息，键：ID 值：ID
Global Win_Title:={} ;存储每个窗口的标题，键：ID 值：Tite

SetTimer,DetectiveWindow,200

DetectiveWindow:
    For Key,Value in Win_Info ;删除不存在的窗口数据
    {
        If !WinExist("Ahk_id" Value)
        {
            msgbox,删除了id
            Win_Info.Delete(Value)
            Win_Title.Delete(Value)
        }
    }
    If WinExist("Ahk_Class Notepad")
    { 
        WinGetTitle,Title,A
        If (Instr(Title,"记事本"))
        {
            WinGet,WinID,Id,A ;获取窗口唯一ID
            If Win_Info.HasKey(WinID) ;如果当前窗口已经记录，则返回
            {
                Return
            }
            Else 
            {
                msgbox,记录id
                Win_Info[WinID]:= WinID ;记录ID
                Win_Title[WinID]:=Title ;记录标题
            }
        }
    }
Return

!g:: ;显示记录的标题
    For key,value in Win_Title
        str .= value
    MsgBox,% str
    str := ""
Return