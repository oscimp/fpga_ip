@rem Automatically generated by Amaranth 0.5.4. Do not edit.
@echo off
SetLocal EnableDelayedExpansion
if defined AMARANTH_ENV_VIVADO call "%AMARANTH_ENV_VIVADO%"
if [!VIVADO!] equ [""] set VIVADO=
if [!VIVADO!] equ [] set VIVADO=vivado
"%VIVADO%" -mode batch -log top.log -source top.tcl || exit /b
