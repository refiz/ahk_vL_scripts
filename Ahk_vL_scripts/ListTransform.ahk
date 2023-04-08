; # 说明
; 此脚本用于将选择片段在无序列表、有序列表和普通缩进的行之间相互转换
; 以及：
; - 最多支持两层列表嵌套
; - 可选择是否转换空行（光标所在行仍会转换）
; ---
; ## 热键
; - Ctrl L(无序列表)
;      * 有序->无序
;      * 无序->去除序号
;      * 带缩进的行->无序
; - Ctrl Shift L(有序列表)
;      * 无序->有序
;      * 有序->去除序号
;      * 带缩进的行->有序
; ---
; ## 局限
; - 有序列表仅支持数字序号
; - 不支持混合转换（如若选择片段中包含有序与无序，将视为普通行处理）
; ## 注意
; - 列表形式
;  * 非严格的md列表格式
;      + -   abc 符号与文字间可用任意空格隔开，且嵌套列表一级缩进空格为2-6个，二级为6-10（可自行更改）
;  * 严格的md列表格式
;      + 1. abc 序号与文字间仅用一个空格隔开，一级嵌套缩进空格为4个，二级为8个（见下方Global变量）
; - 选择的片段需为纯粹的无序或有序，否则将视为普通行
; - ***脚本使用CRLF模式非此模式无法正常转换***
; **@HanaTiri**
; 2023/02/25_22:06:43_下午
; 2023/02/26_14:52:07_下午 -addNest
#NoEnv
#SingleInstance, Force

Global UseStictRegEx := False
Global IsConvertBrankLine := False ;是否处理空行，True则空行也会标上序号
Global FirstIndentedSpace := A_Space A_Space A_Space A_Space ;缩进空格数
Global SecIndentedSpace := A_Space A_Space A_Space A_Space A_Space A_Space A_Space A_Space

;unordered list
^l::
    Clipboard := ""
    Sleep, 10
    Send,^c
    ClipWait, 10
    If (Clipboard == "")
        Return
    Else {
        RawText := ClipBoard
        If(IsOlStr(RawText)){
            Clipboard := OlToUl(RawText) ;将有序转换为无序
            GetToolTip("有序转为无序", 1000)
        }Else If(IsUlStr(RawText)){
            ClipBoard := UlToNor(RawText) ;将无序转为普通
            GetToolTip("无序转为普通", 1000)
        }Else{
            ClipBoard := NorToUl(RawText) ;将普通行转为无序列表
            GetToolTip("转为无序列表", 1000)
        }
        Send,^v
        RawText := ""
    }
Return

;ordered list
^+l::
    Clipboard := ""
    Sleep, 10
    Send,^c
    ClipWait, 10
    If (Clipboard == "")
        Return
    Else {
        RawText := ClipBoard
        If(IsUlStr(RawText)){
            Clipboard := UlToOl(RawText) ;将无序转换为有序
            GetToolTip("无序转为有序", 1000)
        }Else If(IsOlStr(RawText)){
            ClipBoard := OlToNor(RawText) ; 将有序转为普通
            GetToolTip("有序转为普通", 1000)
        }Else{
            Clipboard := NorToOl(RawText) ;将普通行转为有序列表Clipboard := 
            GetToolTip("转为有序列表", 1000)
        }
        Send,^v
        RawText := ""
    }
Return

UlToOl(UlStr){
    Return NorToOl(UlToNor(UlStr))
}

OlToUl(OlStr){
    Return NorToUl(OlToNor(OlStr))
}

UlToNor(UlStr){
    MatchA := UseStictRegEx ? "^\s{4}\*\s\w" : "^\s{2,6}\*\s" ;非严格模式的空格匹配数在此修改
    MatchB := UseStictRegEx ? "^\s{8}\+\s\w" : "^\s{6,10}\+\s"
    for Index, t in StrSplit(UlStr,"`r`n"){
        If(RegExMatch(t, MatchA)){ ;一级嵌套
            t := StrReplace(t, "* ", "")
        }Else If(RegExMatch(t, MatchB)){ ; 二级嵌套
            t := StrReplace(t, "+ ", "")
        }Else{
            t := StrReplace(t, "- ", "")
        }
        NorStr .= t . "`r`n"
    }
    Return SubStr(NorStr,1,StrLen(NorStr) - 2)
}

OlToNor(OlStr){
    MatchA := UseStictRegEx ? "^\s{4}\d{1,}\.\s{1}\w" : "^\s{2,6}\d{1,}\.\s"
    MatchB := UseStictRegEx ? "^\s{8}\d{1,}\.\s{1}\w" : "^\s{6,10}\d{1,}\.\s"
    for Index, t in StrSplit(OlStr,"`r`n"){
        If(RegExMatch(t, MatchA)){ ;一级嵌套
            t := FirstIndentedSpace . SubStr(t, InStr(t,".") + 2)
        }Else If(RegExMatch(t, MatchB)){ ; 二级嵌套
            t := SecIndentedSpace . SubStr(t, InStr(t,".") + 2)
        }Else{
            t := SubStr(t, InStr(t,".") + 2)
        }
        NorStr .= t . "`r`n"
    }
    Return SubStr(NorStr,1,StrLen(NorStr) - 2)
}

NorToUl(NorStr){
    t := StrReplace(NorStr, "`r`n", "`r\")
    If(!IsConvertBrankLine){
        t := StrReplace(t, "\`r", "`r")
    }
    for Index, t in StrSplit(t, "\"){
        If (RegExMatch(t, "^\s{2,6}\w")){
            Str .= FirstIndentedSpace . "* " . LTrim(t)
        }Else If(RegExMatch(t, "^\s{6,10}\w")){
            Str .= SecIndentedSpace . "+ " . LTrim(t)
        }Else{
            Str .= "- " . t
        }
    }
    Return Str
}

NorToOl(NorStr){
    t := StrReplace(NorStr, "`r`n", "`r\")
    If(!IsConvertBrankLine){
        t := StrReplace(t, "\`r", "`r") ; 空行不进行转换
    }
    IsANest := IsBNest := False
    NestIndex := ANestIndex := BNestIndex := 0

    for Index, t in StrSplit(t, "\"){
        If (RegExMatch(t, "^\s{2,6}\w")){ ;一级嵌套
            If (!IsANest){
                ANestIndex := 0
            }
            IsANest := True
            IsBNest := False
            NestIndex++
            Str .= FirstIndentedSpace . ++ANestIndex . ". " . LTrim(t) ;统一格式为四个空格开始
        }Else If(RegExMatch(t, "^\s{6,10}\w")){ ;二级嵌套
            If (!IsBNest){
                BNestIndex := 0
            }
            IsBNest := True
            NestIndex++
            Str .= SecIndentedSpace . ++BNestIndex . ". " . LTrim(t) ;统一格式为八个空格开始

        }Else{
            IsANest := False
            Str .= Index - NestIndex . ". " . t
        }
    }
    Return Str
}

IsUlStr(Str){
    MatchA := UseStictRegEx ? "^-\s{1}\w" : "^-\s"
    MatchB := UseStictRegEx ? "^\s{4}\*\s\w" : "^\s{2,6}\*\s"
    MatchC := UseStictRegEx ? "^\s{8}\+\s\w" : "^\s{6,10}\+\s"
    for Index, t in StrSplit(Str,"`r`n"){
        If(t == "") ;跳过空行
            Continue
        If(!RegExMatch(t, MatchA) AND !RegExMatch(t, MatchB) AND !RegExMatch(t, MatchC)){
            Return False
        }
    }
    Return True
}

IsOlStr(Str){
    MatchA := UseStictRegEx ? "^\d{1,}\.\s{1}\w" : "^\d{1,}\.\s"
    MatchB := UseStictRegEx ? "^\s{4}\d{1,}\.\s{1}\w" : "^\s{2,6}\d{1,}\.\s"
    MatchC := UseStictRegEx ? "^\s{8}\d{1,}\.\s{1}\w" : "^\s{6,10}\d{1,}\.\s"
    for Index, t in StrSplit(Str,"`r`n"){
        If(t == "")
            Continue
        If(!RegExMatch(t, MatchA) AND !RegExMatch(t, MatchB) AND !RegExMatch(t, MatchC)){
            Return False
        }
    }
    Return True
}

GetToolTip(String, Time)
{
    ToolTip, %String%, A_CaretX, A_CaretY + 25
    SetTimer, RemoveToolTip, -%Time%
}

RemoveToolTip: ;移除ToolTip
    ToolTip
Return