;此脚本仅在单文件时不会出错，多文件会出现以下问题：已码字数错误，自动备份的文件错误。
;脚本使用：Esc具有三个功能，显示临时ToolTip时可退出PopUp效果
;                         关闭窗口时在常驻ToolTip尚未消失时可手动保存日志文件
;                         显示工作报告时可手动关闭报告。
;脚本功能：自动备份，保存日志，报告此次工作性质，评级等。
;
;包含的热键功能：自动补全中文成对符号：“” ‘’ （）《》 
;               CTRL ALT HOME\END快捷添加与移除段后行
;              高效BS TAB ENTER DELETE
;       热字串：[d]发送日期与时间
;显示第几章与章名请按格式码字：第一行写第几章(或第几日等等)和章名
#NoEnv 
#SingleInstance, Force ;单例

SetBatchLines, -1 ;全速率运行，保证计时的准确性
CoordMode,ToolTip,Screen ;坐标模式改为屏幕
;===============================全局变量
;=========自定义变量
Global DoNotShowToolTip:=["Recover","写作日志"] ;添加不使用ToolTip的文件，添加标题的部分字符串即可
Global OnlyPopupOnStart:=True ;是否只在窗口开始时显示Pop效果
Global LogEveryTime:=False ;是否每次都保存日志
Global LogIntervalTime:=1 ;打开文件多少分钟后才能手动保存日志文件，如果打开了每次都记录日志，此条无效
Global LeftSpace:=A_Tab A_Tab A_Space A_Space A_Space ;日志文件对齐的空格数量，此条适配幼圆字体，微软雅黑删去两个空格
Global WhichChapterLength:=8 ;章节序号的最大长度
Global ChapterNameLength:=20 ;章名的最大长度
Global ShowWhichChapterAndChapterName:=True ;是否显示第几章与章名
Global ShowTapNum:=True ;是否显示已码多少字
Global ConditionOfAutoBackup:=100 ;自动备份需要码满的字
Global AutoBackupTime:=15 ;自动备份的间隔时间，指定为整数15分钟
Global CoverFile:=False ;是否覆盖旧备份
Global BackupWhenClose:=True ;是否在关闭窗口时自动备份
Global DoNotAutoBackup:=False ;是否关闭自动备份，同时关闭备份相关ToolTip
Global DoNotCareMe:=False ;是否关闭暖心语句
Global AwalysShowWorkReport:=False ;是否每次关闭文件后都进行报告
Global WorkReportIntervalTime:=1 ;必须打开文件多少分钟后才显示工作报告，如果打开了每次都报告，此条无效
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
Global LastBackupTapNum:=0 ;上次备份时已码的字数
Global AddLineToggle:=True ;是否插入空行或移除空行

Menu,Tray,Icon,%A_Desktop%/Icon图集/Notepad.ico
Menu,Tray,NoStandard
Menu,Tray,Add,清除已码字数,X_ClearTapNum
Menu,Tray,Add,&Exit,X_MenuExit

#IFWinActive Ahk_Class Notepad
    {
        SetTimer,ShowNoteTips,10 ;显示提示
        SetTimer,IntervalTime,1000 ;计时器
        SetTimer,AutoBackUpTime,1000 ;备份时间倒计时
        ;==========================高效TAB
        Shift & Enter::
            Send,% A_Space A_Space A_Space A_Space A_Space A_Space A_Space A_Space
        Return
        ;==========================高效BS
        Ctrl & BS::
            Send,{BS}
            Send,{BS}
            Send,{BS}
            Send,{BS}
        Return
        ;==========================高效Del
        Ctrl & Delete::
            Send,{Delete}
            Send,{Delete}
            Send,{Delete}
            Send,{Delete}
        Return
        ;==========================快速前删后删
        Ctrl & Insert::
            Send,{BS}{Delete}
        Return
        ;==========================发送日期和时间
        ::[d]::
            FormatTime, CurrentDateTime,,yyyy/M/d_HH:mm:ss_tt
            SendInput,%CurrentDateTime%
        Return
        ;==========================自动补全成对符号
        *'::
            If !GetKeyState("Ctrl")
                Send,‘’{Left}
            Else 
                Send,''{Left}
        Return
        *"::
            If !GetKeyState("Ctrl")
                Send,“”{Left}
            Else
                Send,""{Left}
        Return 
        *(:: 
            If !GetKeyState("Ctrl")
                Send,（）{Left}
            Else
                Send,(){Left}
        Return
        *<::
            If !GetKeyState("Ctrl")
                Send,《》{Left}
            Else
                Send,<>{Left}
        Return
        ; *[::
        ;     If !GetKeyState("Ctrl")
        ;         Send,【】{Left}
        ;     Else
        ;         Send,[]{left}
        ; Return
        ;======================插入段后行
        ^#Home:: ;每次都应先插入后才能移除
            If AddLineToggle
            {
                WinGetText,NoteText, A
                NoteText:=StrReplace(NoteText, "`r`n", "`r`n`r`n") ;增加段后行
                Send,^a
                Send,{Delete}
                ClipBoard:=NoteText
                Send,^v
                Send,{BS}{BS}{BS} ;去除多插入的空行
                ClipBoard:=""
                AddLineToggle:=False
            }
        Return
        ;=====================移除段后行
        ^#End::
            If !AddLineToggle
            {
                WinGetText, NoteText, A
                Loop
                {
                    NoteText:= StrReplace(NoteText, "`r`n`r`n", "`r`n", Count)
                }Until Count=0
                Send,^a
                Send,{Delete}
                ClipBoard:=NoteText
                Send,^v
                ClipBoard:=""
                AddLineToggle:=True
            }
        Return
    }
#IfWinActive

~Esc:: ;Esc在不同阶段的功能，不要放到上方热键群中
    If (!WinExist("Ahk_Class Notepad") AND TokenA AND !TokenD AND IntervalMin>=LogIntervalTime) ;AND IntervalMin>=1 AND IntervalSec>30 记事本已关闭且在程序运行时,且不与第三个功能冲突，必须达到一定时长才可以记录日志
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
            StartNum:=Num
        Token:=False ;条件更新
        TapNum:=Token?0:Num-StartNum ;刷新已码字数
        WhichChapter:=Trim(SubStr(NoteText,1,WhichChapterLength))
        ChapterName:=SubStr(Trim(SubStr(NoteText,ChapterNameLength+1,150)),1,ChapterNameLength)
        ;==========================启动时的字符串弹出效果
        If (WinExist("Ahk_Class Notepad") AND IsPop AND OnlyPopupOnStart) ;记事本存在且弹出效果为真
        {
            TokenC:=False ;未显示常驻ToolTip
            Str1:="总共有：" . Num . "字"
            PopUpStr(Str1,0,1,100)
            If (!WinExist("Ahk_Class Notepad") OR !WinActive("Ahk_Class Notepad") OR !IsPop)
                Goto Clear
            Str2:="总共有：" . LineCount . "行"
            PopUpStr(Str2,25,2,100)
            If (!WinExist("Ahk_Class Notepad") OR !WinActive("Ahk_Class Notepad") OR !IsPop)
                Goto Clear
            Str3:="当前为：" . WhichChapter
            PopUpStr(Str3,50,3,100)
            If (!WinExist("Ahk_Class Notepad") OR !WinActive("Ahk_Class Notepad") OR !IsPop)
                Goto Clear
            Str4:="章名为：" . ChapterName
            PopUpStr(Str4,75,4,100)
            If (!WinExist("Ahk_Class Notepad") OR !WinActive("Ahk_Class Notepad") OR !IsPop)
                Goto Clear
            If !DoNotCareMe
            {
                Str5:="今天也请继续码字~"
                PopUpStr(Str5,100,5,100)
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
        TokenC:=True ;显示了常驻ToolTip
        ;L_PosY:=LongToolTipPosY() ;获取显示的方式
        L_Str1:="总共有：" . Num . "字"
        GetToolTip(L_Str1,60,0,20,100)
        L_Str2:="总共有：" . LineCount . "行"
        GetToolTip(L_Str2,60,25,19,100)
        L_Str3:="已运行：" . IntervalHour . "时" . IntervalMin . "分" . IntervalSec . "秒"
        GetToolTip(L_Str3,60,50,18,100)
        L_PosY:=75
        If ShowWhichChapterAndChapterName
        {
            L_Str4:="当前为：" . WhichChapter
            GetToolTip(L_Str4,60,L_PosY,17,100)
            L_PosY+=25
            L_Str5:="章名为：" . ChapterName
            GetToolTip(L_Str5,60,L_PosY,16,100)
            L_PosY+=25
            If ShowTapNum
            {
                BackupTip:=IsBackup?"，满足备份条件":"，不满足备份条件"
                L_Str6:="已经码：" . TapNum . "字" . BackupTip
                GetToolTip(L_Str6,60,L_PosY,15,100)
                L_PosY+=25
                L_Str7:="离备份：" . ConditionOfAutoBackup-(TapNum-LastBackupTapNum) . "字"
                GetToolTip(L_Str7,60,L_PosY,14,100)
                L_PosY+=25
            } 
        }
        Else If ShowTapNum
        {
            BackupTip:=IsBackup?"，满足备份条件":"，不满足备份条件"
            L_Str6:="已经码：" . TapNum . "字" . BackupTip
            GetToolTip(L_Str6,60,L_PosY,15,100)
            L_PosY+=25
            L_Str7:="离备份：" . ConditionOfAutoBackup-(TapNum-LastBackupTapNum) . "字"
            GetToolTip(L_Str7,60,L_PosY,14,100)
            L_PosY+=25
        }
        If !DoNotAutoBackup
        {
            L_Str8:="已备份：" . BackupNum . "次☆~"
            GetToolTip(L_Str8,60,L_PosY,13,100)
            L_PosY+=25
            L_Str9:="将备份：" . NextBackupMin . "分" . NextBackupSec . "秒"
            GetToolTip(L_Str9,60,L_PosY,12,100)
            L_PosY+=25
        }
        If !DoNotCareMe
        {
            L_Str10:="加油码字哦~~~ 👍°∇<)"
            GetToolTip(L_Str10,60,L_PosY,11,100)
        }
    }Else {
        If !OnlyPopupOnStart
            IsPop:=True ;弹出效果为真
        Flag:=False ;停止记录时间
        ClearLongToolTip(150) ;清除常驻ToolTip
    }
    If !WinExist("Ahk_Class Notepad") ;关闭记事本后的操作
    {
        Flag:=True ;可开始记时
        Token:=True ;可开始记录字数
        TokenB:=False ;条件二成立(此条语句位置不可变)
        If (TokenA AND !TokenB) ;实现在关闭记事本时不会重复触发
        { 
            Str:="工作了：" . IntervalHour . "时" . IntervalMin . "分" . IntervalSec . "秒"
            If TokenC ;显示了常驻ToolTip
                ClearLongToolTip(150) ;清除常驻ToolTip，防止ToolTip重叠
            Ranking(TapNum)
            If (IsLog OR LogEveryTime) ;记录日志
                CreatWorkingLog(SubStr(Str,5),ShareTitle)
            If (IntervalMin>=WorkReportIntervalTime OR AwalysShowWorkReport) ;时间过短不进行报告
                WorkReport(Str) ;报告工作情况
            ClearShortToolTip(150) ;清除临时ToolTip
        }
        If (BackupWhenClose AND !DoNotAutoBackup) ;退出时进行备份
            AutoBackup(NoteText,ShareTitle)
        TokenA:=False ;条件更新
        IsLog:=False ;不可记录日志
        TokenD:=False ;报告工作已完成
        Num:=TapNum:=0 ;清除已码字数相关
        ExitWorkReportThead:=False ;ESC将不对后续报告造成影响
        BackupMin:=BackupSec:=0 ;自动备份变量重置
        WhichChpater:=ChapterName:="" ;清空变量
        IntervalHour:=IntervalMin:=IntervalSec:=0 ;计时器重置
        FileIndex:=1 ;重置备份文件下标
        BackupNum:=0 ;备份次数重置
        LastBackupTapNum:=0 ;重置字数
        NextBackupMin:=NextBackupSec:=0 ;下次备份时间重置
    }
    Return
    ;============================以下为单独的Label

    IntervalTime:
        If Flag
        {
            If(IntervalMin=60)
                IntervalHour+=1,IntervalMin:=0
            If(IntervalSec=60)
                IntervalMin+=1,IntervalSec:=0
            IntervalSec+=1
        }
    Return
    AutoBackUpTime: ;不可与上方整合在一起
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

    X_ClearTapNum:
        Token:=True
    Return
    X_MenuExit:
    ExitApp
    ;=========================================Function
    PopUpStr(String,PosY,Weight,Speed) ;ToolTip弹出效果
    {
        ClipLenth:=2
        Loop,% StrLen(StrReplace(String, A_Space, ""))
        {
            SplitStr:=SubStr(String,1,CLiplenth)
            ToolTip,%SplitStr%,60,%PosY%,%Weight%
            ClipLenth+=1
            Sleep,60
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
    If TapNum=0 ;决定此次工作的性质
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

WorkReport(Str)
{
    TokenD:=True
    W_Str1:="工作报告生成中……"
    PopUpStr(W_Str1,0,1,80)
    If ExitWorkReportThead ;可随时停止此次报告
    Return
W_Str2:=Str
PopUpStr(W_Str2,25,2,80)
If ExitWorkReportThead
    Return
W_Str3:="总共码：" . TapNum . "字"
PopUpStr(W_Str3,50,3,80)
If ExitWorkReportThead
    Return
W_Str4:=IsLog?"本次已写入日志文件":"本次未写入日志文件"
PopUpStr(W_Str4,75,4,80)
If ExitWorkReportThead
    Return
W_Str5:="此次为：" . WorkType
PopUpStr(W_Str5,100,5,80)
If ExitWorkReportThead
    Return
If !DoNotCareMe
{
    W_Str6:="生活愉快~"
    PopUpStr(W_Str6,125,6,80)
    If ExitWorkReportThead
    Return
}
W_Str1:="工作报告生成完毕"
ToolTip,%W_Str1%,60,0,1
If ExitWorkReportThead
    Return
Sleep,2500
Return
}

CreatWorkingLog(Str,ShareTitle) ;创造工作日志
{
    FileName:="C:\Users\稻荷叶\Desktop\写作日志.txt"
    WorkRecordFile:=FileOpen(FileName,"a" "`r", UTF-8)
    FormatTime,CurrentDateTime,, yyyy/M/d HH:mm:ss tt
    SubOne:= CurrentDateTime . "在：" . "【" . ShareTitle . "】" . "中`r`n"
    SubTwo:=LeftSpace . "工作了：" . "【" . Str . "】" . "`r`n"
    SubThree:=LeftSpace . "共码了：" . "【" . TapNum . "】" . "字`r`n"
    SubFour:=LeftSpace . "此次为：" . "【" . WorkType . "】" . "`r`n"
    WrittingLog:=SubOne . SubTwo . SubThree . SubFour ;整合
    WorkRecordFile.Write(WrittingLog) ;写入
    WorkRecordFile.Close()
}

AutoBackup(Source,ShareTitle)
{
    BackupNum+=1 ;备份次数
    IsSameFile:=False
    FormatTime,DateAndTime,, yyyy-M-d_HHmmss ;获取此时日期与时间
    ShareTitle:=StrReplace(SubStr(ShareTitle,1,InStr(ShareTitle, ".")-1),"*","") ;裁剪标题
    FileName:="C:\Users\稻荷叶\Desktop\自动备份文件\" . ShareTitle . FileIndex . "_" . DateAndTime . "_Recover.Txt"
    Loop,Files,%A_Desktop%\自动备份文件\*%ShareTitle%*.txt ;扫描文件并保存下标
        IsSameFile:=True
    FileIndex:=IsSameFile?(FileIndex+1):1 ;如果存在下标加一，否则为一
    If CoverFile ;覆盖文件
        FileIndex:=""
    FileName:="C:\Users\稻荷叶\Desktop\自动备份文件\" . ShareTitle . FileIndex . "_" . DateAndTime . "_Recover.Txt"
    RecoverFile:=FileOpen(FileName,"w" "`r",UTF-8)
    RecoverFile.Write(Source) ;写入
    RecoverFile.Close()
}