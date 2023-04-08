#SingleInstance, Force
 ;不检索同名文件
^+Home::
    IsSame:=False ;当前标题与循环的文件标题是否相同
    WinGetText, NowText, A
    WinGetTitle,Title,A
    NewTitle:=StrReplace(SubStr(Title,1,InStr(Title,".")-1),"*","")
    ;MsgBox,% NewTitle
    NewText:=StrReplace(NowText, "`r`n", "`r`n`r`n") ;增加段后行后的数据
    Loop,Files,C:*.txt,R ;\SYOUSEZI*.*,R
    {
        ArrayOne:=StrSplit(NewTitle)
        NewLoopName:=SubStr(A_LoopFileName,1,InStr(A_LoopFileName,".")-1)
        ArrayTwo:=StrSplit(NewLoopName)
        ;MsgBox,% NewLoopName
        Flag:=true ;是否继续内循环
        SameCount:=0 ;字符串中匹配字符成功的次数
        FilePath:="" ;找到文件的全路径
        Loop,% StrLen(NewTitle)>StrLen(NewLoopName)?StrLen(NewTitle):StrLen(NewLoopName)
        {
            ;MsgBox,% ArrayOne[A_Index] ArrayTwo[A_Index]
            If ArrayOne[A_Index]=ArrayTwo[A_Index]
            {
                SameCount+=1
                ; MsgBox,% SameCount
                If % SameCount=StrLen(NewTitle) ;如果两个文件名称完全相同
                {
                    IsSame:=True ;找到目标文件
                    FilePath:=A_LoopFileLongPath
                    ; MsgBox,% A_LoopFileFullPath ;报告找到的文件全路径
                }
            }
            Else
            {
                ; MsgBox,NotSame ;报告与当前循环的匹配情况
                Flag:=False ;停止对同一个文件的匹配
            }
        }Until !Flag ;进入下一个文件的匹配
    }Until IsSame=True
    If IsSame ;找到文件后进行文件替换工作
    {
        ; FoundFile:=FileOpen(FilePath, "w", UTF-8)
        ; If (!IsObject(FoundFile))
        ; FoundFile.Write(NewText)
        ; FoundFile.Close()
        MsgBox,% FilePath
    }
Return