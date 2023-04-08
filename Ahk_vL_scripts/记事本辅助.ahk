; # 脚本使用
; - 脚本功能：
;     * 运行时的实时ToolTip。
;     * 一些改善的热键和热字串。
;     * 报告此次工作性质，表现为关闭文件后弹出。
;     * 自动备份，可自定义备份间隔时间。
;     * 保存日志，将运行时间，增加字数，备份次数，备份原因，工作性质记录。

; - 包含的热键功能：
;     * Esc具有三个功能：
;         + 显示临时ToolTip时可退出PopUp效果
;         + 关闭窗口时在常驻ToolTip尚未消失时可手动保存日志文件
;         + 显示工作报告时可手动关闭报告。
;     * 自动补全中文成对符号：“” ‘’ （）《》，同时按住ctrl可切换为英文符号
;     * 段后行：
;         + CTRL ALT HOME\END快捷添加与移除段后行
;     * 高效BS TAB ENTER DELETE
;     * 快速移动光标，具体自行阅读下方热键群
;     * 热字串：
;         + [d]发送日期与时间

; # 注意
; - 显示第几章与章名请按格式码字：第一行写第几章(或第几日等等)和章名，序号与章名间需要用空格分开，空格的多少由下方自定义变量的序号长度决定。

; - 此脚本显示的ToolTip适合底，侧部任务栏，若无法适应其他布局(顶部)则自行修改脚本尾端的PopUpStr函数的X坐标参数。

; - **此脚本仅在单文件时不会出错，多文件会出现以下问题：已码字数变负数，备份错误的文件。**

; - 不决定对多文件进行处理(在得到此功能的同时会失去更多的功能)，对此设置了clean按钮(右键脚本图标)，当因切换文件导致出现上述错误时可点击(或切换回原文件)以刷新变量。 

; - 对于多文件，可参考另一篇的多文件信息记录示例。

; - 如果发现错误可以反馈。

;  **@daohe**

#NoEnv
#SingleInstance, Force ;单例

SetBatchLines, -1 ;全速率运行，保证计时的准确性，或删去此行，就settimer改为990ms
CoordMode,ToolTip,Screen ;坐标模式改为屏幕
;===============================全局变量
;=========自定义变量
Global DoNotShowToolTip:=["Recover","写作日志"] ;添加不使用此脚本的文本，添加标题的部分字符串即可
Global OnlyPopupOnStart:=True ;是否只在窗口开始时显示Pop效果
Global LogEveryTime:=False ;是否每次都保存日志，此选项会覆盖其他设置
Global LogWhenClose:=True ;是否在关闭文件时记录日志，需满足下条
Global ConditionOfAutoLog:=6 ;关闭文件记录日志需要满足的工作时长
Global LogIntervalTime:=6 ;打开文件多少分钟后才能手动保存日志文件，如果打开了每次都记录日志，此条无效
Global LeftSpace:=A_Tab A_Tab A_Space A_Space A_Space A_Space ;日志文件对齐的空格数量，此条适配幼圆字体，微软雅黑删去两个空格，其他自行更改
Global WhichChapterLength:=8 ;章节序号的最大长度
Global ChapterNameLength:=20 ;章名的最大长度
Global ShowWhichChapterAndChapterName:=True ;是否显示第几章与章名
Global ShowTapNum:=True ;是否显示已码多少字
Global ConditionOfAutoBackup:=50 ;自动备份需要码满的字，每次备份都会更新
Global AutoBackupTime:=15 ;自动备份的间隔时间，指定为整数分钟
Global CoverFile:=False ;是否覆盖旧备份
Global BackupWhenClose:=True ;是否在关闭窗口时自动备份(需码满字，建议打开)
Global DoNotAutoBackup:=False ;是否关闭自动备份，同时关闭备份相关ToolTip，此选项会覆盖其他设置
Global DoNotCareMe:=False ;是否关闭暖心语句
Global AwalysShowWorkReport:=False ;是否每次关闭文件后都进行报告
Global WorkReportIntervalTime:=1 ;必须打开文件多少分钟后才显示工作报告(自动)，如果打开了每次都报告，此条无效
;更多自定义内容详见代码，如tooltip上的话，备份文件存储位置，日志名……
;=========不可更改变量
Global Token:=True ;是否记录共码了多少字
Global Flag:=True ;是否记录时间
Global IsPop:=True ;是否弹出字符串
Global TokenA:=TokenB:=False ;是否显示工作报告
Global TokenC:=False ;是否显示了常驻ToolTip
Global IsLog:=False ;是否保存日志文件
Global ExitWorkReportThead:=False ;是否强制退出写作报告
Global TokenD:=False ;是否处于WorkReport进程中
Global TapNum:=0 ;记录已码字数
Global TokenE:=False ;是否备份文件，与窗口是否活跃无关
Global WorkType:="" ;此次工作的性质
Global FileIndex:=1 ;备份文件下标
Global BackupNum:=0 ;备份的次数
Global IntervalHour:=IntervalMin:=IntervalSec:=0 ;计时器变量
Global ShareTitle:="" ;全局共享的活跃窗口标题
Global BackupMin:=BackupSec:=0 ;备份计时变量
Global NextBackupMin:=NextBackupSec:=0 ;距离下次备份的时间
Global IsBackup:=False ;是否满足备份条件
Global BackupReason:="" ;记录自动备份的原因
Global SameFileCount:=0 ;已经有多少当前文件的备份
Global LastBackupTapNum:=0 ;上次备份时已码的字数
Global AddLineToggle:=True ;是否插入空行或移除空行
Global IsIdle ;鼠标是否处于idle状态
Global IsInput ;是否处于输入状态

Menu,Tray,Icon,%A_Desktop%/Icon图集/Notepad.ico ;修改为自己的路径
Menu,Tray,NoStandard
Menu,Tray,Add,Clean,X_ClearTapNum ;切换文件后，或变成负数请点击此清零已码字数
Menu,Tray,Add,&Exit,X_MenuExit

#IfWinActive Ahk_Class Notepad
    {
        ;====================启用计时器
        SetTimer,MouseIdleTimer,10 ;检测鼠标是否处于IDLE状态
        SetTimer,GetPriorPos,10 ;使用两个计时器的目的：优化光标显隐的效果，一旦退出码字模式则立即显示光标，但进入隐藏光标模式需要一定时间。
        SetTimer,HideCursor,7500 ;隐藏光标
        SetTimer,ShowNoteTips,10 ;显示提示
        SetTimer,IntervalTime,1000 ;计时器
        SetTimer,AutoBackUpTime,1000 ;备份时间倒计时
        ;==========================高效TAB
        Ctrl & Enter::
            Send,% A_Space A_Space A_Space A_Space A_Space A_Space A_Space A_Space
        Return
        ;==========================高效BS
        Ctrl & BS::
            Send,{BS}{BS}{BS}{BS}
        Return
        ;==========================高效Del
        Ctrl & Delete::
            Send,{Delete}{Delete}{Delete}{Delete}
        Return
        ;==========================快速前删后删
        Ctrl & Insert::
            Send,{BS}{Delete}
        Return
        ;==========================快捷移动光标
        Ctrl & Left::
            Send,{Left}{Left}{Left}{Left}
        Return
        Ctrl & Right::
            Send,{Right}{Right}{Right}{Right}
        Return
        ;==========================发送分隔符
        ^+=::
            Send,============
        Return
        ;==========================发送日期和时间
        ::[d]::
            FormatTime, CurrentDateTime,,yyyy/MM/dd_HH:mm:ss_tt
            SendInput,%CurrentDateTime%
        Return
        ;==========================自动补全成对符号，适配小鹤音形，其他输入法可以调整为更简单形式
        *'::
            If !GetKeyState("Ctrl")
                Send,‘’{Left}
            Else ;因为输入法的特殊性需要借助剪贴版
            {
                ClipBoard:="''"
                Send,^v{Left}
                ClipBoard:=""
            }
        Return
        *"::
            If !GetKeyState("Ctrl")
                Send,“”{Left}
            Else
            {
                ClipBoard:=""""""
                Send,^v{Left}
                ClipBoard:=""
            }
        Return
        *(::
            If !GetKeyState("Ctrl")
                Send,（）{Left}
            Else
            {
                ClipBoard:="()"
                Send,^v{Left}
                ClipBoard:=""
            }
        Return
        *<::
            If !GetKeyState("Ctrl")
                Send,《》{Left}
            Else
            {
                ClipBoard:="<>"
                Send,^v{Left}
                ClipBoard:=""
            }
        Return
        ;======================插入段后行
        ^#Home::
            If !AddLineToggle ;每次都应先移除后才能插入
            {
                WinGetText,TextOne, Ahk_Class Notepad
                TextOne:=StrReplace(TextOne, "`r`n", "`r`n`r`n") ;增加段后行
                Send,^a
                Send,{BS}
                ClipBoard:=""
                ClipBoard:=TextOne
                ClipWait
                Send,^v
                AddLineToggle:=True
            }
        Return
        ;=====================移除段后行
        ^#End::
            If AddLineToggle
            {
                WinGetText, TextTwo, Ahk_Class Notepad
                Loop
                {
                    TextTwo:= StrReplace(TextTwo, "`r`n`r`n", "`r`n", Count)
                }Until Count=0
                Send,^a
                Send,{BS}
                ClipBoard:=""
                ClipBoard:=TextTwo
                ClipWait
                Send,^v
                AddLineToggle:=False
            }
        Return
    }
#IfWinActive

~Esc:: ;Esc在不同阶段的功能，不要放到上方热键群中
    If (!WinExist("Ahk_Class Notepad") AND TokenA AND !TokenD AND IntervalMin>=LogIntervalTime) ;记事本已关闭且在程序运行时,且不与第三个功能冲突
    {
        IsLog:=True ;手动确认写入
    }
    If IsPop AND WinActive("Ahk_Class Notepad") ;如果打开了记事本，且弹出效果为真，退出弹出效果
    {
        IsPop:=False
    }
    If (!WinExist("Ahk_Class Notepad") AND TokenA AND TokenD) ;强制退出写作报告
    {
        ExitWorkReportThead:=True
    }
Return
;==========================记事本ToolTip
{
ShowNoteTips:
    If WinExist("Ahk_Class Notepad") ;排除某些文件
    {
        WinGetTitle,ExcludeTitle,A
        Loop,% DoNotShowToolTip.Length()
        {
            If InStr(ExcludeTitle,DoNotShowToolTip[A_Index])
                Return
        }
    }
    If WinActive("Ahk_Class Notepad")
    {
        Flag:=True ;开始记时
        TokenA:=TokenB:=True ;条件一成立，条件二不成立
        WinGetText, NoteText, A
        WinGetTitle,ShareTitle,A ;用于多处判断与作为函数参数使用
        NewText:= StrReplace(StrReplace(StrReplace(NoteText, A_Space, ""),A_Tab,""),"`r`n`","",LineCount) ;获取Text
        Num:= StrLen(NewText) ;实时记录当前总字数
        Sleep,10
        If Token ;开始记录字数条件
        {
            StartNum:=Num
        }
        Token:=False ;条件更新
        TapNum:=Token?0:Num-StartNum ;刷新已码字数
        WhichChapter:=StrReplace(Trim(SubStr(SubStr(NoteText,1,InStr(NoteText,"`r`n")),1,WhichChapterLength)),"`r`n","") ;获取序号
        ChapterName:=StrReplace((SubStr(LTrim(SubStr(NoteText,InStr(NoteText,A_Space),InStr(NoteText,"`r`n")-2)),1,ChapterNameLength)), "`r`n","") ;获取章名
        ;==========================启动时的字符串弹出效果
        If (WinExist("Ahk_Class Notepad") AND IsPop AND OnlyPopupOnStart) ;记事本存在且弹出效果为真
        {
            TokenC:=False ;未显示常驻ToolTip
            P_PosY:=50
            Str1:="总共有：" . Num . "字"
            PopUpStr(Str1,0,0,1,100)
            If (!WinExist("Ahk_Class Notepad") OR !WinActive("Ahk_Class Notepad") OR !IsPop) ;为了能够随时退出此部分
                Goto Clear ;使用Goto更好实现逻辑
            Str2:="总共有：" . LineCount . "行"
            PopUpStr(Str2,0,25,2,100)
            If (!WinExist("Ahk_Class Notepad") OR !WinActive("Ahk_Class Notepad") OR !IsPop)
                Goto Clear
            If ShowWhichChapterAndChapterName
            {
                Str3:="当前为：" . WhichChapter
                PopUpStr(Str3,0,P_PosY,3,100)
                P_PosY+=25
                If (!WinExist("Ahk_Class Notepad") OR !WinActive("Ahk_Class Notepad") OR !IsPop)
                    Goto Clear
                Str4:="标题为：" . ChapterName
                PopUpStr(Str4,0,P_PosY,4,100)
                P_PosY+=25
                If (!WinExist("Ahk_Class Notepad") OR !WinActive("Ahk_Class Notepad") OR !IsPop)
                    Goto Clear
            }
            If !DoNotCareMe
            {
                Str5:="今天也请继续码字~"
                PopUpStr(Str5,0,P_PosY,5,100)
                If (!WinExist("Ahk_Class Notepad") OR !WinActive("Ahk_Class Notepad") OR !IsPop)
                    Goto Clear
            }
            Sleep,1500 ;适当停顿
            Clear:
                ToolTip,,,,1
                Sleep,150
                ToolTip,,,,2
                Sleep,150
                ToolTIp,,,,3
                Sleep,150
                ToolTip,,,,4
                Sleep,150
                ToolTip,,,,5
                Sleep,150
                ; ToolTip,,,,6
                ; Sleep,150
                IsPop:=False ;关闭弹出效果
            Return
        }
        TokenC:=True ;运行到此则显示了常驻ToolTip
        L_Str1:="总共有：" . Num . "字"
        GetToolTip(L_Str1,0,0,20,100)
        L_Str2:="总共有：" . LineCount . "行"
        GetToolTip(L_Str2,0,25,19,100)
        L_Str3:="已运行：" . IntervalHour . "时" . IntervalMin . "分" . IntervalSec . "秒"
        GetToolTip(L_Str3,0,50,18,100)
        L_PosY:=75
        If ShowWhichChapterAndChapterName
        {
            L_Str4:="当前为：" . WhichChapter
            GetToolTip(L_Str4,0,L_PosY,17,100)
            L_PosY+=25
            L_Str5:="标题为：" . ChapterName
            GetToolTip(L_Str5,0,L_PosY,16,100)
            L_PosY+=25
            If ShowTapNum
            {
                BackupTip:=DoNotAutoBackup?"":(IsBackup?"，满足备份条件":"，不满足备份条件")
                L_Str6:="已经码：" . TapNum . "字" . BackupTip
                GetToolTip(L_Str6,0,L_PosY,15,100)
                L_PosY+=25
            }
        }
        Else If ShowTapNum
        {
            BackupTip:=DoNotAutoBackup?"":(IsBackup?"，满足备份条件":"，不满足备份条件")
            L_Str6:="已经码：" . TapNum . "字" . BackupTip
            GetToolTip(L_Str6,0,L_PosY,15,100)
            L_PosY+=25

        }
        If !DoNotAutoBackup
        {
            L_Str7:="已备份：" . BackupNum . "次☆~"
            GetToolTip(L_Str7,0,L_PosY,14,100)
            L_PosY+=25
            L_Str8:="将备份：" . NextBackupMin . "分" . NextBackupSec . "秒"
            GetToolTip(L_Str8,0,L_PosY,13,100)
            L_PosY+=25
            TempNum:=(ConditionOfAutoBackup-(TapNum-LastBackupTapNum))>0?(ConditionOfAutoBackup-(TapNum-LastBackupTapNum)):0
            L_Str9:="离备份：" . TempNum . "字" ;我一般尽量少使用临时变量
            GetToolTip(L_Str9,0,L_PosY,12,100)
            L_PosY+=25
        }
        If !DoNotCareMe
        {
            L_Str10:="绝好赞~~~ 👍°∇<)"
            GetToolTip(L_Str10,0,L_PosY,11,100)
        }
    }Else {
        If !OnlyPopupOnStart ;移除Pop效果
            IsPop:=True ;弹出效果为真
        Flag:=False ;停止记录时间
        ClearLongToolTip(150) ;清除常驻ToolTip
    }
    If !WinExist("Ahk_Class Notepad") ;关闭记事本后的操作
    {
        Flag:=True ;可开始记时
        IsPop:=True ;下次打开有Pop效果
        Token:=True ;可开始记录字数
        TokenB:=False ;条件二成立(此条语句位置不可变，只能在下条IF的上面)
        If (TokenA AND !TokenB) ;实现在关闭记事本时不会重复触发
        {
            Str:="工作了：" . IntervalHour . "时" . IntervalMin . "分" . IntervalSec . "秒"
            If TokenC ;显示了常驻ToolTip
                ClearLongToolTip(150) ;清除常驻ToolTip，防止ToolTip重叠
            Ranking(TapNum)
            If (BackupWhenClose AND !DoNotAutoBackup AND TapNum>=ConditionOfAutoBackup) ;退出时进行备份
                AutoBackup(NoteText,ShareTitle)
            If (IsLog OR LogEveryTime OR (LogWhenClose AND IntervalMin>=ConditionOfAutoLog)) ;记录日志
                CreatWorkingLog(SubStr(Str,5),ShareTitle)
            If (IntervalMin>=WorkReportIntervalTime OR AwalysShowWorkReport) ;时间过短不进行报告
                WorkReport(Str,IntervalMin) ;报告工作情况 因为Ahk的Bug?只能通过传值解决
            ClearShortToolTip(150) ;清除临时ToolTip
            SystemCursor("On") ;确保退出时鼠标为显示状态
        }
        TokenA:=False ;条件更新
        IsLog:=False ;不可记录日志
        TokenD:=False ;报告工作已完成
        Num:=TapNum:=0 ;清除已码字数相关
        ExitWorkReportThead:=False ;ESC将不对后续报告造成影响
        BackupMin:=BackupSec:=0 ;自动备份变量重置
        WhichChpater:=ChapterName:="" ;清空变量
        IntervalHour:=IntervalMin:=IntervalSec:=0 ;计时器重置
        FileIndex:=1 ;重置备份文件下标
        SameFileCount:=0 ;重置同名备份文件
        BackupNum:=0 ;备份次数重置
        LastBackupTapNum:=0 ;重置字数
        NextBackupMin:=NextBackupSec:=0 ;下次备份时间重置
    }
    Return
}

;============================以下为单独的Label

IntervalTime: ;运行时间计时器
    If Flag
    {
        If(IntervalMin=60)
            IntervalHour+=1,IntervalMin:=0
        If(IntervalSec=60)
            IntervalMin+=1,IntervalSec:=0
        IntervalSec+=1
    }
Return
AutoBackUpTime: ;自动备份计时器，不可与上方整合在一起
    If (WinExist("Ahk_Class Notepad") AND !DoNotAutoBackup)
    {
        If (TokenE) ;必须处于新增状态才自动备份
            AutoBackUp(NoteText,ShareTitle)
        TokenE:=False
        If TapNum-LastBackupTapNum>=ConditionOfAutoBackup
            IsBackup:=True
        Else
            IsBackup:=False
        If (!TokenD AND ShareTitle) ;关闭记事本后与未获取到文件标题不会开始计时
        {
            If(Mod(BackupMin,AutoBackUpTime)=0 AND BackupMin!=0) ;15Min自动备份
            {
                If (TapNum-LastBackupTapNum>=ConditionOfAutoBackup AND IsBackup) ;只有满足字数始终在增加才会备份
                    TokenE:=True ;备份条件为真
                LastBackupTapNum:=TapNum ;记录当前已码字数,更新字数要求
                BackupMin:=0 ;重置计时
            }
            If(BackupSec=60)
            {
                BackupMin+=1
                BackupSec:=0
            }
            BackupSec+=1
        }
        NextBackupMin:=AutoBackupTime-BackupMin-1 ;剩余备份时间更新
        NextBackupSec:=60-BackupSec
    }
Return
;=====================AboutHideCursor
HideCursor:
    If (IsIdle AND IsInput AND WinActive("Ahk_Class Notepad"))
        SystemCursor("Off")
Return

GetPriorPos:
    MouseGetPos,PriorPosX,PriorPosY
Return
MouseIdleTimer:
    SetTimer,MouseIdleTimer, %MouseIdleIntervalTimer%
    MouseGetPos,NowPosX,NowPosY
    If(PriorPosX=NowPosX And PriorPosY=NowPosY)
    {
        IsIdle:=True
    }Else
    {
        IsIdle:=False
        PriorPosX:=NowPosX,PriorPosY:=NowPosY
    }
    If(A_CaretX="")
        IsInput:=False
    Else IsInput:=True
        If(!(IsIdle And IsInput)) ;显示光标
        SystemCursor("On")
Return
X_ClearTapNum:
    Token:=True
Return
X_MenuExit:
ExitApp
;=========================================Function
PopUpStr(String,PosX,PosY,Weight,Speed) ;ToolTip弹出效果
{
    ClipLenth:=2
    Loop,% StrLen(StrReplace(String, A_Space, ""))
    {
        SplitStr:=SubStr(String,1,CLiplenth)
        ToolTip,%SplitStr%,%PosX%,%PosY%,%Weight% ;将0改为其他适应坐标
        ClipLenth+=1
        Sleep,50
    }
    Sleep,% StrLen(String)*Speed
Return
}

GetToolTip(String,PosX,PosY,Weight,SleepTime) ;显示ToolTip
{
    ToolTip,%String%,%PosX%,%PosY%,%Weight%
    Sleep,%SleepTime%
}

ClearShortToolTip(SleepTime) ;清除临时ToolTip
{
    ToolTip,,,,1
    Sleep,%SleepTime%
    ToolTip,,,,2
    Sleep,%SleepTime%
    ToolTIp,,,,3
    Sleep,%SleepTime%
    ToolTip,,,,4
    Sleep,%SleepTime%
    ToolTip,,,,5
    Sleep,%SleepTime%
    ToolTip,,,,6
    Sleep,%SleepTime%
    ToolTip,,,,7
    Sleep,%SleepTime%
Return
}
ClearLongToolTip(SleepTime) ;清除常驻ToolTip
{
    If !DoNotCareMe
    {
        ToolTip,,,,11
        Sleep,%SleepTime%
    }
    If !DoNotAutoBackup
    {
        ToolTip,,,,12
        Sleep,%SleepTime%
        ToolTip,,,,13
        Sleep,%SleepTime%
        ToolTip,,,,14
        Sleep,%SleepTime%
    }
    If ShowTapNum
    {
        ToolTip,,,,15
        Sleep,%SleepTime%
        If ShowWhichChapterAndChapterName
        {
            ToolTip,,,,16
            Sleep,%SleepTime%
            ToolTip,,,,17
            Sleep,%SleepTime%
        }
    }Else If ShowWhichChapterAndChapterName
    {
        ToolTip,,,,16
        Sleep,%SleepTime%
        ToolTip,,,,17
        Sleep,%SleepTime%
    }
    ToolTip,,,,18
    Sleep,%SleepTime%
    ToolTip,,,,19
    Sleep,%SleepTime%
    ToolTip,,,,20
    Sleep,%SleepTime%
Return
}

Ranking(TapNum)
{
    If TapNum=0 ;决定此次工作的性质，更据喜好更改
        WorkType:="浏览"
    Else If TapNum<=100
        WorkType:="修改"
    Else If TapNum<=1000
        WorkType:="马马虎虎"
    Else If TapNum<=2000
        WorkType:="值得表扬"
    Else If TapNum<=3000
        WorkType:="做得很棒"
    Else WorkType:="惊为天人！"
        Return
}

WorkReport(Str,Min)
{
    TokenD:=True
    W_Str1:="工作报告生成中……"
    PopUpStr(W_Str1,0,0,1,80)
    If ExitWorkReportThead ;可随时停止此次报告
        Return
    W_Str2:=Str
    PopUpStr(W_Str2,0,25,2,80)
    If ExitWorkReportThead
        Return
    W_Str3:="总共码：" . TapNum . "字"
    PopUpStr(W_Str3,0,50,3,80)
    If ExitWorkReportThead
        Return
W_Str4:=(IsLog OR LogEveryTime OR (LogWhenClose AND Min>=ConditionOfAutoLog))?"本次已写入日志文件":"本次未写入日志文件"
    PopUpStr(W_Str4,0,75,4,80)
    If ExitWorkReportThead
        Return
    W_Str5:="此次为：" . WorkType
    PopUpStr(W_Str5,0,100,5,80)
    If ExitWorkReportThead
        Return
    W_PosY:=125
    If !DoNotAutoBackup
    {
        W_Str6:="已备份：" . BackupNum . "次"
        PopUpStr(W_Str6,0,W_PosY,6,80)
        W_PosY+=25
        If ExitWorkReportThead
            Return
    }
    If !DoNotCareMe
    {
        W_Str7:="生活愉快~"
        PopUpStr(W_Str7,0,W_PosY,7,80)
        If ExitWorkReportThead
            Return
    }
    W_Str1:="工作报告生成完毕"
    ToolTip,%W_Str1%,0,0,1
    If ExitWorkReportThead
        Return
    Sleep,2500 ;停留的时间
Return
}

CreatWorkingLog(Str,ShareTitle) ;创造工作日志
{
    WhyBackup()
    FileName:=A_Desktop . "\写作日志.txt"
    ShareTitle:=StrReplace(ShareTitle,"*","")
    WorkRecordFile:=FileOpen(FileName,"a" "`r", UTF-8)
    FormatTime,CurrentDateTime,, yyyy/MM/dd HH:mm:ss tt
    SubOne:= CurrentDateTime . "在：" . "【" . ShareTitle . "】" . "中`r`n"
    SubTwo:=LeftSpace . "工作了：" . "【" . Str . "】" . "`r`n"
    SubThree:=LeftSpace . "共码了：" . "【" . TapNum . "】" . "字`r`n"
    SubFour:=LeftSpace . "此次为：" . "【" . WorkType . "】" . "`r`n"
    SubFive:=LeftSpace . "备份了：" . "【" . BackupNum . "】" . "次`r`n"
    SubSix:=LeftSpace . "原因是：" . "【" . BackupReason . "】" . "`r`n`r`n"
    WrittingLog:=SubOne . SubTwo . SubThree . SubFour . SubFive . SubSix ;整合
    WorkRecordFile.Write(WrittingLog) ;写入
    WorkRecordFile.Close()
}

AutoBackup(Source,ShareTitle)
{
    BackupNum+=1 ;备份次数
    IsSameFile:=False
    SameFileCount:=0
    FormatTime,DateAndTime,, yyyy-MM-dd_HHmmss ;获取此时日期与时间
    If !FileExist(A_Desktop . "\自动备份文件")
    {
        FileCreateDir, % A_DeskTop . "\自动备份文件"
        If (ErrorLevel = 1)
            MsgBOx,创建文件夹失败！
    }
    ShareTitle:=StrReplace(SubStr(ShareTitle,1,InStr(ShareTitle, ".")-1),"*","") ;裁剪标题
    Loop,Files,%A_Desktop%\自动备份文件\*%ShareTitle%*.txt ;扫描文件并保存下标
    {
        SameFileCount+=1
        IsSameFile:=True
    }
    FileIndex:=IsSameFile?(FileIndex+SameFileCount):1 ;如果存在下标加相应数，否则为一
    If CoverFile ;打开覆盖文件文件选项则不使用下标，已存在的备份文件不会被覆盖
        FileIndex:=""
    FileName:=A_Desktop . "\自动备份文件\" . ShareTitle . FileIndex . "_" . DateAndTime . "_Recover.Txt"
    RecoverFile:=FileOpen(FileName,"w" "`r",UTF-8)
    RecoverFile.Write(Source) ;写入
    RecoverFile.Close()
}

WhyBackup() ;说明备份的原因
{
    If (BackupWhenClose AND !DoNotAutoBackup AND TapNum>=ConditionOfAutoBackup)
        BackupReason:="关闭时自动备份"
    Else
        BackupReason:="码满字后的备份"
    If (BackupNum>1)
        BackupReason:="关闭时与满时长"
}

SystemCursor(OnOff=1) ; 初始化 = "I", "Init"; 隐藏 = 0, "Off"; 切换 = -1,"T", "Toggle"; 显示 = 其他
{
    static AndMask, XorMask, $, h_cursor
    ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; 系统指针
    , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13 ; 空白指针
    , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13 ; 默认指针的句柄
    if (OnOff = "Init" or OnOff = "I" or $ = "") ; 在请求或首次调用时进行初始化
    {
        $ := "h" ; 活动的默认指针
        VarSetCapacity( h_cursor,4444, 1 )
        VarSetCapacity( AndMask, 32*4, 0xFF )
        VarSetCapacity( XorMask, 32*4, 0 )
        system_cursors := "32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650"
        StringSplit c, system_cursors, `,
        Loop %c0%
        {
            h_cursor := DllCall( "LoadCursor", "Ptr",0, "Ptr",c%A_Index% )
            h%A_Index% := DllCall( "CopyImage", "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0 )
            b%A_Index% := DllCall( "CreateCursor", "Ptr",0, "Int",0, "Int",0
            , "Int",32, "Int",32, "Ptr",&AndMask, "Ptr",&XorMask )
        }
    }
    if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
        $ := "b" ; 使用空白指针
    else
        $ := "h" ; 使用保存的指针

    Loop %c0%
    {
        h_cursor := DllCall( "CopyImage", "Ptr",%$%%A_Index%, "UInt",2, "Int",0, "Int",0, "UInt",0 )
        DllCall( "SetSystemCursor", "Ptr",h_cursor, "UInt",c%A_Index% )
    }
}