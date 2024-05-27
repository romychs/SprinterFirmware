@echo ==============================================================================
@type read.me
@built.exe
@echo Assembling . . .
@echo Assembling Drivers . . .
@c:\asm\as80 -i -x3 -l -n drv-main.asm
@if errorlevel=3 goto error
@echo Drivers OK
@echo Assembling Kernel . . .
@c:\asm\as80 -i -x3 -l -n dos-main.asm
@if errorlevel=3 goto error
@goto good
:error
@echo -----------------------------------------------------------------------
@echo │                 ERROR                        ERROR                  │
@echo -----------------------------------------------------------------------
@goto quit
:good
@del system.dss
@ren dos-main.bin system.dss
@copy /b system.dss+drv-main.bin
@echo Имя файла           Размер        Занято  ┌── Изменен ──┐  Загружен  Атрибуты
@dir system.dss /v | find "system.dss"
:quit
