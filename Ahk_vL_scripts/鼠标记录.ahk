;Developed By DaoHe
;Ahk_Version@1.1.34.03
#NoEnv
#SingleInstance,Force

SetBatchLines,-1 ;脚本无间断运行
CoordMode,Mouse,Screen ;坐标模式为屏幕
SendMode,Event ;

TrayTip MouseRecord,欢迎使用：）
SetTimer,HideTrayTip,-3000

;========鼠标击键相关
Global ClickCount,IsLog ;鼠标总共的击键次数和是否开始录制
Global IsAction ;控制是否允许播放
Global XPostion:={},YPostion:={},ClickNum:={},WhichBtn:={} ;存储鼠标击键信息
Global Presses ;鼠标单击或双击
;========鼠标拖动相关
Global NowPosX,NowPosY ;记录当前的鼠标位置，用于判断是否处于Drag状态
Global DragSPosX:={},DragSPosY:={},DragEPosX:={},DragEPosY:={} ;保存Drag的信息
Global Token:={} ;保存了拖动的下标(即第几次击键是拖动)
Global IsDrag:=False ;用于创建单例(Drag)
Global Flag ;用于解决出现的棘手问题
Global TokenA:={} ;用于解决出现的棘手问题
;============================脚本控制热键
^Up:: ;===============开始录制
    Init() ;初始工作
    GetToolTip("录制开始",1000)
Return
^Down:: ;=============结束录制
    End() ;结束工作
    GetToolTip("录制结束",1000)
Return
#Enter:: ;==============开始播放
    If(IsAction)
    {
        ; IsAction:=False ;单例
        GetToolTip("运行中",10000)
        ReadInfo()
        GetToolTip("运行结束",1500)
    }
Return
^Enter::
    GetToolTip("请等待",2000)
    Sleep,200
    GoSub OpenFile
Return
#Esc:: ;================#Esc退出脚本
    TrayTip MouseRecord,每天好心情：）
    SetTimer,HideTrayTip,-3000
ExitApp
Return
;=============================;鼠标热键
~MButton:: ;采用热键记录
    WriteMouseInfo("M") ;记录鼠标点击信息
Return
~RButton:: 
    WriteMouseInfo("R")
Return
~LButton::
    WriteMouseInfo("L") 
Return
~WheelDown::
    WriteMouseInfo("WD")
Return
~WheelUp::
    WriteMouseInfo("WU")
Return
;=============================LabelAboutDragging
GetMousePostion: ;获取鼠标位置，用于判断鼠标是否处于Drag状态
    MouseGetPos,NowPosX,NowPosY
Return

IsDragState: ;判断鼠标是否处于Drag状态
    If(IsLog) ;已开始录制
    {
        If(GetKeyState("LButton")) ;鼠标处于按下状态
        {
            MouseGetPos,PriorPosX,PriorPosY
            If(NowPosX!=PriorPosX||NowPosY!=PriorPosY&&IsDrag) ;判断是否为拖动状态
            {
                GetToolTip("Dragging",1000)
            }
            If(NowPosX!=PriorPosX||NowPosY!=PriorPosY&&!IsDrag) ;判断拖动状态是否刚开始
            {
                PosX:=XPostion[ClickCount]
                PosY:=YPostion[ClickCount]
                DragSPosX[ClickCount]:=PosX
                DragSPosY[ClickCount]:=PosY
                Token[ClickCount]:=ClickCount ;保存下标
                Flag:=True ;已处于拖动状态，可记录终点坐标
                IsDrag:=True
            }
        }Else ;鼠标处于弹起状态
        {
            IsDrag:=False ;设为非拖动状态，用于避免鼠标空闲时触发
            If(Flag){
                MouseGetPos,EndPosX,EndPosY ;记录终点位置
                DragEPosX[ClickCount]:=EndPosX
                DragEPosY[ClickCount]:=EndPosY
            }
            Flag:=False ;拖动状态结束，用于避免鼠标空闲时触发
        }
    }
Return
;============================OtherLabel
RemoveToolTip: ;移除ToolTip
    ToolTip
Return
SaveFile: ;====保存文件
FileSelectFile, FileName, S16,, Create A New File:
    If(FileName = "") ;名字不可为空
        Return
    File:= FileOpen(FileName, "w",UTF-8) ;创建文件
    If !IsObject(File)
    {
        MsgBox,Can't Open"%FileName%"For Writing.
            Return
    }Else{
        TrayTip MouseRecord,保存成功
        SetTimer,HideTrayTip,-3000
        WriteData(File)
    }
Return
OpenFile: ;====打开文件
    IsAction:=True
    IsLog:=False
    FileSelectFile,FileName,,Select A File
    File:= FileOpen(FileName, "r-d")
    If !IsObject(File)
    {
        Return
    }Else{
        TrayTip MouseRecord,打开成功#Win+Enter播放#
        SetTimer,HideTrayTip,-4000
        ReadData(File)
    }
Return
HideTrayTip: ;HideTrayTip
    TrayTip ; 尝试以正常的方式隐藏它.
    if SubStr(A_OSVersion,1,3) = "10."
    {
        Menu Tray, NoIcon
        Sleep 200 ; 可能有必要调整 sleep 的时间.
        Menu Tray, Icon
    }
Return
;============================Function
GetToolTip(String,Time) ;显示ToolTip，参数显示的文本和显示的持续时间
{
    ToolTip,%String%
    SetTimer,RemoveToolTip,%Time%
}

Init() ;==================准备工作
{
    IsLog:=True ;允许录制
    IsAction:=True ;允许播放
    ClickCount:=0 ;数据初始化
    ;====AboutDragging
    SetTimer,IsDragState,10
    SetTimer,GetMousePostion,10 ;获取当前鼠标位置
}
End() ;==================结束工作
{
    IsLog:=False ;关闭录制
    ;====保存录制文件相关
    MsgBox,4,,是否保存录制文件？
    IfMsgBox,Yes
    GoSub SaveFile
}
WriteData(ByRef File) ;================写入数据
{
    ;==============AboutClick
    File.Write(ClickCount "\")
    File.Write(Token.Count() "\")
    For Index, Value in XPostion
        File.Write(Value "\")
    For Index, Value in YPostion
        File.Write(Value "\")
    For Index, Value in ClickNum
        File.Write(Value "\")
    For Index, Value in WhichBtn
        File.Write(Value "\")
    ;==============AboutDrag
    For Index, Value in Token
        File.Write(Value "\")
    For Index, Value in DragSPosX
        File.Write(Value "\")
    For Index, Value in DragSPosY
        File.Write(Value "\")
    For Index, Value in DragEPosX
        File.Write(Value "\")
    For Index, Value in DragEPosY
        File.Write(Value "\")
    File.Close()
}
ReadData(ByRef File) ;================读入数据
{
    DataString:=File.Read()
    Loop,Parse,DataString,`\ ;"\"作为分隔符
    {
        If(A_Index=1)
        {
            Lenth:=A_LoopField
            ClickCount:=Lenth
        }Else If(A_Index=2)
        {
            Count:=A_loopField
        }Else If(A_Index<=Lenth+2)
        {
            XPostion[A_Index-2]:=A_LoopField
        }Else If(A_Index<=Lenth*2+2)
        {
            YPostion[A_Index-2-Lenth]:=A_LoopField
        }Else If(A_Index<=Lenth*3+2)
        {
            ClickNum[A_Index-2-2*Lenth]:=A_LoopField
        }Else If(A_Index<=Lenth*4+2)
        {
            WhichBtn[A_Index-2-3*Lenth]:=A_LoopField
        }Else If(A_Index<=Lenth*4+Count+2) ;===ABoutDrag
        {
            Token[A_LoopField]:=A_LoopField
            TokenA.Push(A_LoopField)
            IndexOne:=IndexTwo:=IndexThree:=IndexFour:=0
        }Else If(A_Index<=Lenth*4+Count*2+2)
        {
            IndexOne+=1
            DragSPosX[TokenA[IndexOne]]:=A_LoopField
        }Else If(A_Index<=Lenth*4+Count*3+2)
        {
            IndexTwo+=1
            DragSPosY[TokenA[IndexTwo]]:=A_LoopField
        }Else If(A_Index<=Lenth*4+Count*4+2)
        {
            IndexThree+=1
            DragEPosX[TokenA[IndexThree]]:=A_LoopField
        }Else If(A_Index<=Lenth*4+Count*5+2)
        {
            IndexFour+=1
            DragEPosY[TokenA[IndexFour]]:=A_LoopField
        }
        File.Close()
    }
}
;========================脚本核心
WriteMouseInfo(Btn) ;========写入鼠标信息
{
    If(IsLog) ;仅在开始录制时写入
    {
        ClickCount+=1 ;击键次数加一
        if (A_ThisHotkey = A_PriorHotkey && A_TimeSincePriorHotkey < 300) ;判断鼠标是否为双击
        {
            Presses:=2 ;鼠标双击
            ClickCount-=1 ;双击触发两次WritMouseInfo()，则需减去多加的一次ClickCount
            ClickNum[ClickCount]:=2 ;存储双击记录，ClickCount为Key
            If(ClickCount) ;实时显示当前击键信息
            {
                ToolTip,%ClickCount%%A_Space%%Btn%%A_Space%%Presses% ;第几次击键、哪个键、单双击
            }
        }Else{ ;单击事件
            Presses:=1
            ClickNum[ClickCount]:=1
            MouseGetPos,Xpos,Ypos ;获取坐标
            XPostion[ClickCount]:=Xpos ;存储X坐标
            YPostion[ClickCount]:=Ypos ;存储Y坐标
            If(Btn=="R") ;记录WhichButton
            {
                WhichBtn[ClickCount]:="R"
            }Else If(Btn=="L")
            {
                WhichBtn[ClickCount]:="L"
            }Else If(Btn=="M")
            {
                WhichBtn[ClickCount]:="M"
            }Else If(Btn=="WD")
            {
                WhichBtn[ClickCount]:="WD"
            }Else{
                WhichBtn[ClickCount]:="WU"
            }
            If(ClickCount) ;实时显示当前击键信息
            {
                ToolTip,%ClickCount%%A_Space%%Btn%%A_Space%%Presses%
            }
        }
    }
}
ReadInfo() ;===============读取鼠标信息
{
    BlockInput,MouseMove
    Temp:=ClickCount-1 ;临时变量，用作数组下标索引
    Loop % ClickCount
    {
        Btn:=WhichBtn[ClickCount-Temp]
        PosX:=XPostion[ClickCount-Temp]
        PosY:=YPostion[ClickCount-Temp]
        Click_Count:=ClickNum[ClickCount-Temp]
        If(Token.HasKey(ClickCount-Temp)) ;处理拖动事件
        {
            ToolTip,Dragging
            MouseMove,DragSPosX[ClickCount-Temp],DragSPosY[ClickCount-Temp]
            Sleep,200
            Click,Down
            MouseMove,DragEPosX[ClickCount-Temp],DragEPosY[ClickCount-Temp]
            Sleep,200
            Click,Up
        }Else{
            MouseClick,%Btn%,%PosX%,%PosY%,%Click_Count%
            ToolTip,%A_Index%%A_Space%%Btn%%A_Space%%Click_Count%
        }
        Temp-=1
        Sleep,600 ;减慢速度，防止不连续的单击变成双击与
    }
    BlockInput,MouseMoveOff
    ToolTip
}