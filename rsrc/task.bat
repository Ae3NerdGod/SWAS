@echo off

FOR /F "tokens=* USEBACKQ" %%F IN (`schtasks /query /tn AutostartV1 /fo csv`) DO (
SET var=%%F
)
IF NOT DEFINED var (
    echo notask > notask
)

