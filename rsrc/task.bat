@echo off

FOR /F "tokens=* USEBACKQ" %%F IN (`schtasks /query /tn SWAS /fo csv`) DO (
SET var=%%F
)
IF NOT DEFINED var (
    echo notask > notask
)

