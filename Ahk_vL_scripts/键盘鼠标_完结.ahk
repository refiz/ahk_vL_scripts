;在+ScroolLock打开的时候，可以使用键盘的方向键移动鼠标
#SingleInstance,Force

CoordMode,Screen

;是否移动光标
Global IsMove := False
;按下方向键到松开的间隔时间
Global Interval := 0
;基础方向偏移量(1像素)，MoveEnd标签中也要作相应更改
Global X_Offset := 1.5
Global Y_Offset := 1.5
;当前按下按键的名称
Global Btn := ""
;方向加速度，决定到达最大速度的快慢
Global Acca := 1.3
;最大速度(偏移量)
Global MaxSpeed := 6

;Shift ScrollLock开启
+ScrollLock::
    If (!IsMove){
        ToolTip,OPEN,0,0,5 ;在此定义提示功能开启的提示串及显示位置
        IsMove := True
        ; Hotkey, Left, M_Left, On ;被舍弃的方案
        ; Hotkey, Right, M_Right, On
        ; Hotkey, Up, M_Up, On
        ; Hotkey, Down, M_Down, On
    }
    Else{
        ToolTip,,,,5
        IsMove := False
    }
Return

; Esc::
; ExitApp

#If IsMove

;可增加其他按键功能覆盖
Enter::
    ClicK,0 0 Left 1 Relative ;在当前光标位置单击鼠标左键
Return
+Enter::
    ClicK,0 0 Right 1 Relative ;在当前光标位置单击鼠标右键
Return
Left:: ;光标左移
    Btn := "Left"
    Goto,MoveStart
Return
Right::
    Btn := "Right"
    Goto,MoveStart
Return
Up::
    Btn := "Up"
    Goto,MoveStart
Return
Down::
    Btn := "Down"
    Goto,MoveStart
Return

#If

MoveStart:
    If (Btn=="Left"){
        Y_Offset := 0
        Interval += 0.005 ;非标准间隔时间，而是自定义的
        X_Offset -= Interval*Acca ;逐渐增加速度
        X_Offset := X_Offset<0?X_Offset:-X_Offset ;左移及上移需要赋负号
        X_Offset := -X_Offset>=MaxSpeed?-MaxSpeed:X_Offset ;速度限制
    }
    If (Btn=="Right"){
        Y_Offset := 0
        Interval += 0.005
        X_Offset += Interval*Acca
        X_Offset := X_Offset>=MaxSpeed?MaxSpeed:X_Offset
    }
    If (Btn=="Up"){
        X_Offset := 0
        Interval += 0.005
        Y_Offset -= Interval*Acca
        Y_Offset := Y_Offset<0?Y_Offset:-Y_Offset
        Y_Offset := -Y_Offset>=MaxSpeed?-MaxSpeed:Y_Offset
    }
    If (Btn=="Down"){
        X_Offset := 0
        Interval += 0.005
        Y_Offset += Interval*Acca
        Y_Offset := Y_Offset>=MaxSpeed?MaxSpeed:Y_Offset
    }
    ; ToolTip,%X_Offset% %Y_Offset% %Interval% %Btn%,100,100,2 ;调试用
    MouseMove,%X_Offset%,%Y_Offset%,0,R
    GoTo,MoveEnd
Return

MoveEnd:
    If GetKeyState(Btn,"P"){
        GoTo,MoveStart
    }Else{ ;重置变量，为节省变量，此处也要作相应更改
        Interval := 0
        X_Offset := 1.5
        Y_Offset := 1.5
    }
Return