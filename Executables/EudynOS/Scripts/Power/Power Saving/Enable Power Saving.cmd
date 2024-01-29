@echo off

whoami /user | find /i "S-1-5-18" > nul 2>&1 || (
	call RunAsTI.cmd "%~f0" %*
	exit /b
)

:: Restore default power schemes
:: This should set the power plan to 'Balanced' by default
powercfg /restoredefaultschemes

:: Enable Advanced Configuration and Power Interface (ACPI) devices
call toggleDev.cmd -Enable @("ACPI Processor Aggregator", "Microsoft Windows Management Interface for ACPI") > nul

:: Disable driver/device power saving
PowerShell -NoP -C "$usb_devices = @('Win32_USBController', 'Win32_USBControllerDevice', 'Win32_USBHub'); $power_device_enable = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi; foreach ($power_device in $power_device_enable){$instance_name = $power_device.InstanceName.ToUpper(); foreach ($device in $usb_devices){foreach ($hub in Get-WmiObject $device){$pnp_id = $hub.PNPDeviceID; if ($instance_name -like \"*$pnp_id*\"){$power_device.enable = $True; $power_device.psbase.put()}}}}" > nul
for %%a in (
    "AllowIdleIrpInD3"
    "D3ColdSupported"
    "DeviceSelectiveSuspended"
    "EnableIdlePowerManagement"
    "EnableSelectiveSuspend"
    "EnhancedPowerManagementEnabled"
    "IdleInWorkingState"
    "SelectiveSuspendEnabled"
    "SelectiveSuspendOn"
    "WaitWakeEnabled"
    "WakeEnabled"
    "WdfDirectedPowerTransitionEnable"
) do (
    for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "%%~a" ^| findstr "HKEY"') do (
        reg delete "%%b" /v "%%~a" /f > nul 2>&1
    )
)

:: Disable D3 support on SATA/NVMEs while using Modern Standby
:: https://learn.microsoft.com/en-us/windows-hardware/design/component-guidelines/power-management-for-storage-hardware-devices-intro#d3-support
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Storage" /v "StorageD3InModernStandby" /f > nul 2>&1

:: Disable IdlePowerMode for stornvme.sys (storage devices) - the device will never enter a low-power state
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\stornvme\Parameters\Device" /v "IdlePowerMode" /f > nul 2>&1

:: Reset power throttling to default
:: https://blogs.windows.com/windows-insider/2017/04/18/introducing-power-throttling
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f > nul 2>&1

:: Enable the kernel being tickless
:: https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set#additional-settings
bcdedit /deletevalue disabledynamictick > nul 2>&1

echo Completed.
echo Press any key to exit...
pause > nul
exit /b