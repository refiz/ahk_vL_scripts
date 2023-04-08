#SingleInstance, Force

CoordMode,ToolTip,Screen
CoordMode,Mouse,Screen

;========自定义
Global AllCharMenu:={ 1:"StartUp" ;在此按序号添加菜单项，需要自行添加及修改Label内容
    ,2:"Flypy.Com"
    ,3:"Ahk.Com"
    ,4:"Bili.Com"
    ,5:"AConvert.Com"
    ,6:"YouDao.Com"
    ,7:"Book"
    ,8:"Note"
    ,9:""
    ,10:""
    ,11:""
    ,12:""
    ,13:""
    ,14:""
    ,15:""
    ,16:""
    ,17:""
    ,18:""
,19:"TheMemo"}
Global SimpleCharMenu:={1:"笔记" ;此处为简字符菜单，适合圆形菜单形式
    ,2:"查形"
    ,3:"AHK"
    ,4:"哔哩"
    ,5:"转换"
    ,6:"翻译"
    ,7:"小说"
    ,8:"占十"
    ,9:"WEB"
    ,10:"占七"
    ,11:"占三"
    ,12:"虎牙"
    ,13:"占五"
    ,14:"占六"
    ,15:"JAPI"
    ,16:"UAPI"
    ,17:"菜鸟"
    ,18:"自启"
,19:"备忘"}
Global MenuStyle:="Circle" ;可选：长条形() 圆形(Circle)Circle
Global TipStyle:="SingleChar" ;可选：单字符(SingleChar) 全字符(AllChar)
Global Delay:=20 ;在此定义按住中键唤起菜单所需的时间
Global Radius:=50 ;在此定义圆形菜单的半径
Global MaxItems:=6 ;在此定义第一圈的最大项数，第二圈(最多)则为2*MaxItems项，总项数不超过19。关系为：(0-7]:[3-6],(0-9]:3,(9-13]:4,(13-16]:5,(16-19]:6
Global PI:=3.1415926
;========更换托盘图标相关，分激活与停用两种状态，双击托盘图标以停用脚本
Global IsOn:=True
Global IsStyle:=True
Global M_Open:="Open"
Global M_Close:="Close"

Menu,Tray,Icon,%A_Desktop%/Icon图集/MidMenu_Open.ico ;自备两个ICO
Menu,Tray,NoStandard ;去除默认菜单项
Menu,Tray,Add,Rect,M_MenuStyle
Menu,Tray,Add,%M_Close%,M_Toggle ;增加切换选项
Menu,Tray,Default,%M_Close% ;将切换选项设为默认
Menu,Tray,Click,2 ;设置双击响应
Menu,Tray,Add,&Exit,M_MenuExit ;添加退出按钮

#If IsOn
    ~MButton::
    HowLong:=0 ;初始化
    Loop{
        HowLong++ ;计时
        Sleep,10
        If !(GetKeyState("MButton"))
            Return
        ; ToolTip,% HowLong ;显示进度
    } Until HowLong>=Delay ;达到预定时间
    Send,{MButton} ;在浏览器中有用
    OptimizeShowEffect() ;显示菜单
    HotKey,~LButton,MenuClick ;设置单击热键，当单击时进行判断
    If (GetKeyState("MButton"))
        Return
    HotKey,~LButton,On ;启用热键
Return
#If

MenuClick:
    HotKey,~LButton,Off ;单击后关闭热键
    Sleep,100 ;等待ToolTip被激活
    Result:=CheckMenu() ;接受返回的数组
    If Result[1]!=1 ;此次单击是否将菜单项激活
    {
        CleanMenu() ;未激活则清除菜单并退出
        Return
    }
    OptimizeCloseEffect(Result[2]) ;优化菜单关闭效果
    Gosub,% Result[2] ;追求效率将此条放在上条上面
Return

M_MenuStyle:
    If(IsStyle)
    {
        Menu,Tray,Rename,Rect,Circle
        MenuStyle:="Rect"
        IsStyle:=False

    }Else{
        Menu,Tray,Rename,Circle,Rect
        MenuStyle:="Circle"
        IsStyle:=True
    }
Return

M_Toggle:
    If(IsOn) ;关闭
    {
        Menu,Tray,Rename,%M_Close%,%M_Open%
        Menu,Tray,Icon,%A_Desktop%/Icon图集/MidMenu_Close.ico
        IsOn:=False
    }Else{ ;开启
        Menu,Tray,Rename,%M_Open%,%M_Close%
        Menu,Tray,Icon,%A_Desktop%/Icon图集/MidMenu_Open.ico
        IsOn:=True
    }
Return

M_MenuExit:
ExitApp
;=========================Function
CheckMenu() ;通过检测是否将ToolTip激活，以检查是否选择了菜单项
{
    Loop,% AllCharMenu.Count() ;请确保菜单项与Label数量一致
    {
        If (WinActive(AllCharMenu[A_Index]) OR WinActive(SimpleCharMenu[A_Index]))
            Return [True,A_Index] ;返回线性数组，下标一为选择了菜单项，下标二为选择菜单项的下标
        Else
            Continue ;检测下一条
    }
}

CleanMenu() ;清除菜单
{
    Loop, % SimpleCharMenu.Count()
    {
        If (SimpleCharMenu[A_Index]="")
            Continue
        ToolTip,,,,A_Index
        Sleep,20 ;效果优化
    }
}

OptimizeShowEffect() ;优化显示菜单效果
{
    R:=Radius
    MouseGetPos,PosX,PosY ;获取坐标，用于计算Tip的坐标
    If (MenuStyle="Circle") ;以下为不同的菜单形式
    {
        PosX-=18,PosY-=10 ;稍微调整坐标，让光标置于中心
    }
    Loop,% SimpleCharMenu.Count()
    {
        If GetKeyState("RButton")
            Return
        If (SimpleCharMenu[A_Index]="")
            Continue
        If % (AllCharMenu.Count()<=MaxItems) ;总数未超过设定数
        {
            Radians:=(PI/180)*Round(360/AllCharMenu.Count()) ;不变
        }Else ;第二圈
        {
            If (A_Index>MaxItems) ;第二圈时更改半径及等分点
            {
                R:=2*Radius ;在此调节第二圈的半径
                Radians:=(PI/180)*Round(360/(2*MaxItems))
            }
            Else ;第一圈时
                Radians:=(PI/180)*Round(360/MaxItems)
        }
        If (MenuStyle="Circle") ;以下为不同的菜单形式
        {
            X:=PosX+R*Cos(Radians*A_Index)
            Y:=PosY+R*Sin(Radians*A_Index)
        }Else If (MenuStyle="Rect")
        {
            If (A_Index>1)
                PosY+=22
            X:=PosX
            Y:=PosY
        }
        If (TipStyle="SingleChar")
        {
            If % (A_Index=SimpleCharMenu.Count())
            {
                Sleep,30
                PopUpStr(SimpleCharMenu[SimpleCharMenu.Count()],PosX,PosY,SimpleCharMenu.Count())
            }
            Else
                PopUpStr(SimpleCharMenu[A_Index],X,Y,A_Index,15) ;在此调节弹出的速度

        }Else
        {
            If % (A_Index=AllCharMenu.Count())
                PopUpStr(AllCharMenu[AllCharMenu.Count()],PosX,PosY,AllCharMenu.Count())
            Else 
                PopUpStr(AllCharMenu[A_Index],X,Y,A_Index)
        }
    }
}

OptimizeCloseEffect(SelectIndex) ;优化选取效果
{
    Loop, % AllCharMenu.Count()
    {
        If % A_Index=SelectIndex ;跳过选中的菜单项
            Continue
        ToolTip,,,,A_Index
        Sleep,20
    }
    Sleep,% 25*AllCharMenu.Count() ;保留所选取的菜单项到最后
    ToolTip,,,,%SelectIndex%
}

PopUpStr(String,PosX,PosY,Weight,Speed:=0) ;建议保存此函数，在许多脚本中可使用
{
    ClipLenth:=2
    Loop,% StrLen(StrReplace(String, A_Space, "")) ;去除空格并获取长度
    {
        SplitStr:=SubStr(String,1,ClipLenth)
        ToolTip,%SplitStr%,%PosX%,%PosY%,%Weight%
        ClipLenth+=1
        Sleep,8
    }
    Sleep,%Speed%
Return
}

;==============================CustomizeLabel
1:
    Run,G:\笔记
Return

2:
    Run,http://react.xhup.club/search
Return

3:
    Run,https://wyagd001.github.io/zh-cn/docs/AutoHotkey.htm
Return

4:
    Run,https://www.bilibili.com/
Return

5:
    Run,https://www.aconvert.com/cn/icon/jpg-to-ico/
Return

6:
    Run,https://fanyi.youdao.com/
Return

7:
    Run,D:\小说
Return

8:

Return

9:
    Run,https://developer.mozilla.org/zh-CN/
Return

10:

Return

11:

Return

12:
    Run,https://www.huya.com/786724
Return
13:

Return

14:

Return

15:
    Run,https://www.runoob.com/manual/jdk11api/index.html
Return

16:
    Run,https://docs.unity.cn/cn/2020.3/Manual/UnityManual.html
Return

17:
    Run,https://www.runoob.com/
Return

18:
    Run,%A_Startup%
Return

19:
    Run,%A_Desktop%\备忘录.txt
Return