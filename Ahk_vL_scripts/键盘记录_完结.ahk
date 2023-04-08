;# 脚本说明
;   - 使用前需更改FileName变量的值为自己的文件名
;## 热键
;   - ^Up 开启记录
;   - ^Down 停止记录并添加到本地
;   - #Enter 输出记录
;   - Home 全部输出
;   - End 逐行输入
;## 其他
;   - 钩子仅记录键入字符，中文需用固定词序的输入法（如：小鹤音形）、日语可用KANA模式
;   - 2023/02/17_21:49:40_下午
#NoEnv
#SingleInstance,Force

Global InputString ;保存InputHook记录的输入
Global Flag ;布尔值
Global FileName := "\键盘记录.txt" ;保存钩子记录的文件名，注意保留\
Global LineIndex ;行号

^Up:: ;开始记录
    GetToolTip("Start",2000)
    ih:=InputHook("C V") ;创建输入钩子
    ih.Start()
    Flag:=True
Return

^Down:: ;结束记录
    If(Flag)
    {
        GetToolTip("Over",2000)
        InputString:=ih.Input
        in.Stop() ;关闭
        Flag:=False
        WriteData() ;添加到本地
    }
Return

#Enter:: ;播放记录
    SendRaw, %InputString%
    ih:=""
Return

Home::
    Str := ReadDataAll()
    If(Str != ""){
        SendRaw, %Str%
        Send,{Enter}
    }
Return

End::
    Str := ReadDataLine()
    If(Str != ""){
        SendRaw, %Str%
        Send,{Enter}
    }
Return

#Esc::
    GetToolTip("KbRecorder_Exit",2000)
    Sleep,2000
ExitApp

Return
;====================Func
GetToolTip(String,Time) ;显示ToolTip，参数为显示的文本和显示的持续时间
{
    ToolTip,%String%
    SetTimer,RemoveToolTip,%Time%
}

ReadDataLine() ;逐行读取
{
    LineIndex++
    FileReadLine, ALineData,%A_Desktop%%FileName%, %LineIndex%
    If(ErrorLevel == 1){
        GetToolTip("已到行末",2000)
        LineIndex := 0
        FileReadLine, ALineData,%A_Desktop%%FileName%, %LineIndex%
    }Else{
        GetToolTip("Line:"+LineIndex,1000)
    }
    Return % ALineData
}

ReadDataAll() ;一次性读取
{
    FileRead,AllData,*t %A_Desktop%%FileName%
    If (AllData == ""){
        GetToolTip("文件为空",2000)
        Return
    }
    Return AllData
}

WriteData() ;追加
{
    FilePath := A_Desktop FileName
    File:=FileOpen(FilePath,"a",UTF-8) ;若需覆盖则改为W模式
    If (!File.AtEOF)
        File.Write("`r`n") ;文件不为空时追加空行
    File.Write(InputString)
    File.Close()
}
;====================Label
RemoveToolTip: ;移除ToolTip
    ToolTip
Return