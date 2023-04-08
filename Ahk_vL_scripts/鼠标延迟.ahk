
F1::
SPI_GETMOUSESPEED := 0x70
SPI_SETMOUSESPEED := 0x71
; 获取鼠标当前的速度以便稍后恢复:
DllCall("SystemParametersInfo", "UInt", SPI_GETMOUSESPEED, "UInt", 0, "UIntP", OrigMouseSpeed, "UInt", 0)
; 现在在倒数第二个参数中设置较低的速度 (范围为 1-20, 10 是默认值):
DllCall("SystemParametersInfo", "UInt", SPI_SETMOUSESPEED, "UInt", 0, "Ptr", 3, "UInt", 0)
KeyWait F1  ; 这里避免了由于键盘的重复特性导致再次执行 DllCall.
return

F1 up::DllCall("SystemParametersInfo", "UInt", SPI_SETMOUSESPEED, "UInt", 0, "Ptr", OrigMouseSpeed, "UInt", 0)  ; 恢复原来的速度.