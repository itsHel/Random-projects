@echo off
SET "StartPath=%cd%"
del /f filelist.txt

SetLocal EnableDelayedExpansion
FOR /f "tokens=*" %%f in ('dir /B /ON /S "!StartPath!"') DO (
    set "SubDirsAndFiles=%%f"
    set "SubDirsAndFiles=!SubDirsAndFiles:%StartPath%=!"
    ECHO !SubDirsAndFiles!>> filelist.txt
)