# Службы диагностического отслеживания
$services = @(
# Служба платформы подключенных устройств
"CDPSvc",
# Функциональные возможности для подключенных пользователей и телеметрия
"DiagTrack",
# Использование данных
"DusmSvc",
# Посредник подключений к сети
"NcbService",
# Обнаружение SSDP
"SSDPSRV")
Foreach ($service in $services)
{
	Get-Service -ServiceName $service | Stop-Service -Force
	Get-Service -ServiceName $service | Set-Service -StartupType Disabled
}
# Отключить телеметрию и сбор данных для отправки
Update-AutologgerConfig -Name AutoLogger-Diagtrack-Listener -Start 0
Update-AutologgerConfig -Name SQMLogger -Start 0
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection -Name AllowTelemetry -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection -Name AllowTelemetry -Value 1 -Force
# Отключить отчеты об ошибках Windows
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Windows Error Reporting" -Name Disabled -Value 1 -Force
# Изменить частоту формирования отзывов на "Никогда"
IF (!(Test-Path -Path HKCU:\Software\Microsoft\Siuf\Rules))
{
	New-Item -Path HKCU:\Software\Microsoft\Siuf\Rules -Force
}
New-ItemProperty -Path HKCU:\Software\Microsoft\Siuf\Rules -Name NumberOfSIUFInPeriod -Value 0 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name DoNotShowFeedbackNotifications -Value 1 -Force
# Отключить Cortana
IF ((Get-WinSystemLocale).Name -ne "ru-RU")
{
	IF (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"))
	{
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force
	}
	New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowCortana -Value 0 -Force
}
# Отключить Контроль Wi-Fi
IF (Get-NetAdapter -Physical | Where-Object {$_.Name -match "Беспроводная" -or $_.Name -match "Wi-Fi"})
{
	New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config -Name AutoConnectAllowedOEM -Value 0 -Force
}
# Отключить задачи диагностического отслеживания в Планировщике задач
$tasks = @(
"BgTaskRegistrationMaintenanceTask",
"Consolidator",
"DmClient",
"DmClientOnScenarioDownload",
"EnableLicenseAcquisition",
"FamilySafetyMonitor",
"FamilySafetyRefreshTask",
"File History (maintenance mode)",
"FODCleanupTask",
"GatherNetworkInfo",
"MapsToastTask",
"Microsoft Compatibility Appraiser",
"Microsoft-Windows-DiskDiagnosticDataCollector",
"MNO Metadata Parser",
"NetworkStateChangeTask",
"ProgramDataUpdater",
"Proxy",
"QueueReporting",
"TempSignedLicenseExchange",
"UsbCeip",
"WinSAT",
"XblGameSaveTask")
Foreach ($task in $tasks)
{
	Get-ScheduledTask -TaskName $task | Disable-ScheduledTask
}
# Отключить в "Журналах Windows/Безопасность" сообщение "Платформа фильтрации IP-пакетов Windows разрешила подключение"
auditpol /set /subcategory:"{0CCE9226-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable
# Открывать "Этот компьютер" в Проводнике
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1 -Force
# Отобразить "Этот компьютер" на Рабочем столе
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Force
# Показывать скрытые файлы
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Value 1 -Force
# Показывать расширения файлов
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0 -Force
# Отключить гибридный спящий режим
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power -Name HibernateEnabled -Value 0 -Force
# Не показывать кнопку Просмотра задач
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Value 0 -Force
# Не показывать кнопку поиска
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -Value 0 -Force
# Запрашивать подтверждение при удалении файлов
IF (!(Test-Path -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer))
{
	New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Force
}
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name ConfirmFileDelete -Value 1 -Force
# Запускать проводник с развернутой лентой
IF (!(Test-Path -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer))
{
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Force
}
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name ExplorerRibbonStartsMinimized -Value 2 -Force
# Развернуть диалог переноса файлов
IF (!(Test-Path -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager))
{
	New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager -Force
}
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager -Name EnthusiastMode -Value 1 -Force
# Не скрывать конфликт слияния папок
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideMergeConflicts -Value 0 -Force
# Отключить автозапуск с внешних носителей
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers -Name DisableAutoplay -Value 1 -Force
# Отключить использование режима одобрения администратором для встроенной учетной записи администратора
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0 -Force
# He дoбaвлять "- яpлык" для coздaвaeмыx яpлыкoв
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name link -Type Binary -Value ([byte[]](00,00,00,00)) -Force
# Отключить поиск программ в Microsoft Store
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name NoUseStoreOpenWith -Value 1 -Force
# Не хранить сведения о зоне происхождения вложенных файлов
IF (!(Test-Path -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments))
{
	New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments -Force
}
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments -Name SaveZoneInformation -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments -Name SaveZoneInformation -Value 1 -Force
# Отключить SmartScreen для приложений и файлов
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name SmartScreenEnabled -Type String -Value Off -Force
# Отключить SmartScreen в Edge
$edge = (Get-AppxPackage "Microsoft.MicrosoftEdge").PackageFamilyName
IF (!(Test-Path -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter" -Name EnabledV9 -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter" -Name PreventOverride -Value 0 -Force
# Отключить Flash Player в Edge
IF (!(Test-Path -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Addons"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Addons" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Addons" -Name FlashPlayerEnabled -Value 0 -Force
# Открывать в новом окне предыдущие страницы в Edge
IF (!(Test-Path -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\ContinuousBrowsing"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\ContinuousBrowsing" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\ContinuousBrowsing" -Name Enabled -Value 1 -Force
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Main" -Name AskToCloseAllTabs -Value 0 -Force
# Отображать кнопку домашней страницы в Edge
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Main" -Name HomeButtonEnabled -Value 1 -Force
# Установить домашнюю страницу в Edge
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Main" -Name HomeButtonPage -Type String -Value https://yandex.ru -Force
# Отправлять запросы "Не отслеживать" в Edge
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Main" -Name DoNotTrack -Value 1 -Force
# Отображать лучшие сайты в новой вкладке в Edge
IF (!(Test-Path -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\ServiceUI"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\ServiceUI" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\ServiceUI" -Name NewTabPageDisplayOption -Value 1 -Force
# Не отображать на панели инструментов кнопку "Избранное" в Edge
IF (!(Test-Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Favorites"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Favorites" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Favorites" -Name ShowOnAddressBar -Value 0 -Force
# Не отображать на панели инструментов кнопку "Список для чтения" в Edge
IF (!(Test-Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\ReadingList"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\ReadingList" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\ReadingList" -Name ShowOnAddressBar -Value 0 -Force
# Не отображать на панели инструментов кнопку "Журнал" в Edge
IF (!(Test-Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\History"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\History" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\History" -Name ShowOnAddressBar -Value 0 -Force
# Отображать на панели инструментов кнопку "Загрузки" в Edge
IF (!(Test-Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Downloads"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Downloads" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Downloads" -Name ShowOnAddressBar -Value 1 -Force
# Не отображать на панели инструментов кнопку "Добавить примечание" в Edge
IF (!(Test-Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Annotations"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Annotations" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Annotations" -Name ShowOnAddressBar -Value 0 -Force
# Не отображать на панели инструментов кнопку "Поделиться этой страницей" в Edge
IF (!(Test-Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Share"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Share" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\Extensions\Share" -Name ShowOnAddressBar -Value 0 -Force
# Отобразить пункты "Показать источник" и "Проверить элемент в контекстном меню Edge
IF (!(Test-Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\F12"))
{
	New-Item -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\F12" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\F12" -Name ShowPageContextMenuEntryPoints -Value 1 -Force
# Не разрешать Edge запускать и загружать страницу при загрузке Windows и каждый раз при закрытии Edge
IF (!(Test-Path HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader))
{
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader -Force
}
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader -Name AllowTabPreloading -Value 0 -Force
# Не разрешать предварительный запуск Edge при загрузке Windows, когда система простаивает, и каждый раз при закрытии Edge
IF (!(Test-Path HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main))
{
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main -Force
}
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main -Name AllowPrelaunch -Value 0 -Force
# Не показывать при прикреплении окна, что можно прикрепить рядом с ним
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name SnapAssist -Value 0 -Force
# Отключить управление принтером, используемым по умолчанию, со стороны Windows
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows" -Name LegacyDefaultPrinterMode -Value 1 -Force
# Сохранить скриншот по Win+PrtScr на Рабочем столе
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{b7bede81-df94-4682-a7d8-57a52620b86f}" -Name RelativePath -Type String -Value %USERPROFILE%\Desktop -Force
# Установка качества фона рабочего стола на 100 %
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name JPEGImportQuality -Value 100 -Force
# Отключить залипание клавиши Shift после 5 нажатий
New-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name Flags -Type String -Value 506 -Force
# Отключить отображение вкладки "Предыдущие версии" в свойствах файлов
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name NoPreviousVersionsPage -Value 1 -Force
# Отключить флажки для выбора элементов
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name AutoCheckSelect -Value 0 -Force
# Изменить путь переменной среды для временных файлов
IF (!(Test-Path $env:SystemDrive\Temp))
{
	New-Item -Path $env:SystemDrive\Temp -Type Directory -Force
}
[Environment]::SetEnvironmentVariable("TMP","$env:SystemDrive\Temp","User")
New-ItemProperty -Path HKCU:\Environment -Name TMP -Type ExpandString -Value %SystemDrive%\Temp -Force
[Environment]::SetEnvironmentVariable("TEMP","$env:SystemDrive\Temp","User")
New-ItemProperty -Path HKCU:\Environment -Name TEMP -Type ExpandString -Value %SystemDrive%\Temp -Force
[Environment]::SetEnvironmentVariable("TMP","$env:SystemDrive\Temp","Machine")
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name TMP -Type ExpandString -Value %SystemDrive%\Temp -Force
[Environment]::SetEnvironmentVariable("TEMP","$env:SystemDrive\Temp","Machine")
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name TEMP -Type ExpandString -Value %SystemDrive%\Temp -Force
[Environment]::SetEnvironmentVariable("TMP","$env:SystemDrive\Temp",'Process')
[Environment]::SetEnvironmentVariable("TEMP","$env:SystemDrive\Temp",'Process')
# Удалить UWP-приложения, кроме
# UWP-панель Intel
$intel = "AppUp.IntelGraphicsControlPanel"
# Пакет локализованного интерфейса на русском
$language = "Microsoft.LanguageExperiencePackru-ru"
# Фотографии
$photos = "Microsoft.Windows.Photos"
# Набросок на фрагменте экрана
$sketch = "Microsoft.ScreenSketch"
# Панель управления NVidia
$nvidia = "NVIDIACorp.NVIDIAControlPanel"
# Microsoft Store
$store = "*Store*"
Get-AppxPackage -AllUsers | Where-Object {$_.Name -CNotLike $intel -and $_.Name -CNotLike $language -and $_.Name -CNotLike $photos -and $_.Name -CNotLike $sketch -and $_.Name -CNotLike $nvidia -and $_.Name -CNotLike $store} | Remove-AppxPackage -ErrorAction SilentlyContinue
# UWP-панель Intel
$intel = "AppUp.IntelGraphicsControlPanel"
# Панель управления NVidia
$nvidia = "NVIDIACorp.NVIDIAControlPanel"
# Microsoft Store
$store = "*Store*"
Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -CNotLike $intel -and $_.DisplayName -CNotLike $nvidia -and $_.DisplayName -CNotLike $store} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
# Отключить компоненты
$features = @(
# Факсы и сканирование
"FaxServicesClientPackage",
# Компоненты прежних версий
"LegacyComponents",
# Компоненты работы с мультимедиа
"MediaPlayback",
# PowerShell 2.0
"MicrosoftWindowsPowerShellV2",
"MicrosoftWindowsPowershellV2Root",
# Средство записи XPS-документов (Microsoft)
"Printing-XPSServices-Features",
# Печать в PDF (Майкрософт)
"Printing-PrintToPDFServices-Features",
# Клиент рабочих папок
"WorkFolders-Client")
Foreach ($feature in $features)
{
	Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
}
# Удалить OneDrive
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Start-Process -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" /uninstall -NoNewWindow -Wait
Start-Sleep -Seconds 3
Stop-Process -ProcessName explorer
IF (!(Test-Path -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive))
{
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive -Force
}
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive -Name DisableFileSyncNGSC -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive -Name DisableFileSync -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive -Name DisableMeteredNetworkFileSync -Value 0 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive -Name DisableLibrariesDefaultSaveToOneDrive -Value 1 -Force
New-ItemProperty -Path HKCU:\Software\Microsoft\OneDrive -Name DisablePersonalSync -Value 1 -Force
Remove-ItemProperty -Path HKCU:\Environment -Name OneDrive -Force -ErrorAction SilentlyContinue
Remove-Item -Path $env:USERPROFILE\OneDrive -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $env:LOCALAPPDATA\Microsoft\OneDrive -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName *OneDrive* -Confirm:$false
# Не показывать советы по использованию Windows
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SoftLandingEnabled -Value 0 -Force
# Включить автоматическое обновление для других продуктов Microsoft
(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")
# Отключить меню игры
IF (!(Test-Path -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR))
{
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR -Force
}
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR -Name AllowgameDVR -Value 0 -Force
# Отключить игровую панель
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR -Name AppCaptureEnabled -Value 0 -Force
New-ItemProperty -Path HKCU:\System\GameConfigStore -Name GameDVR_Enabled -Value 0 -Force
# Отключить игровой режим
New-ItemProperty -Path HKCU:\Software\Microsoft\GameBar -Name AllowAutoGameMode -Value 0 -Force
New-ItemProperty -Path HKCU:\Software\Microsoft\GameBar -Name AutoGameModeEnabled -Value 0 -Force
# Отключить подсказки игровой панели
New-ItemProperty -Path HKCU:\Software\Microsoft\GameBar -Name ShowStartupPanel -Value 0 -Force
# Отключить восстановление системы
Disable-ComputerRestore -Drive $env:SystemDrive
Get-ScheduledTask -TaskName SR | Disable-ScheduledTask
Get-Service -ServiceName swprv,vss | Set-Service -StartupType Manual
Get-Service -ServiceName swprv,vss | Start-Service
Get-CimInstance -ClassName Win32_ShadowCopy | Remove-CimInstance
Get-Service -ServiceName swprv,vss | Stop-Service -Force
Get-Service -ServiceName swprv,vss | Set-Service -StartupType Disabled
# Отключить Windows Script Host
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name Enabled -Value 0 -Force
# Всегда отображать все значки в области уведомлений
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name EnableAutoTray -Value 0 -Force
# Включить брандмауэр
Set-NetFirewallProfile -Enabled True
# Отключить оптимизацию доставки для обновлений с других ПК
Get-Service -ServiceName DoSvc | Stop-Service -Force
IF (!(Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization))
{
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization -Force
}
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization -Name DODownloadMode -Value 0 -Force
# Включить в Планировщике задач запуска очистки обновлений Windows
$keys = @(
"Delivery Optimization Files",
"Device Driver Packages",
"Previous Installations",
"Setup Log Files",
"Temporary Setup Files",
"Update Cleanup",
"Windows Defender",
"Windows Upgrade Log Files")
Foreach ($key in $keys)
{
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$key" -Name StateFlags1337 -Value 2 -Force
}
$action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\cleanmgr.exe" -Argument "/sagerun:1337"
$trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 90 -At 9am
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserID $env:USERNAME -RunLevel Highest
$params = @{
"TaskName"	= "Update Cleanup"
"Action"	= $action
"Trigger"	= $trigger
"Settings"	= $settings
"Principal"	= $principal
}
Register-ScheduledTask @Params -Force
# Включить в Планировщике задач очистки папки %SYSTEMROOT%\SoftwareDistribution\Download
$xml = 'Программы\Прочее\xml\SoftwareDistribution.xml'
filter Get-FirstResolvedPath
{
	(Get-Disk | Where-Object {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object {$_.DriveLetter -ne $null}).DriveLetter + ':\' | Join-Path -ChildPath $_ -Resolve -ErrorAction SilentlyContinue
}
$xml | Get-FirstResolvedPath | Get-Item | Get-Content -Raw | Register-ScheduledTask -TaskName "SoftwareDistribution" -Force
# Включить в Планировщике задач очистки папки %SYSTEMROOT%\Logs\CBS
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument @"
`$dir = "$env:SystemRoot\Logs\CBS"
`$foldersize = (Get-ChildItem -Path `$dir -Recurse -Force | Measure-Object -Property Length -Sum).Sum/1MB
IF (`$foldersize -GT 10)
{
	Get-ChildItem -Path `$dir -Recurse -Force | Remove-Item -Recurse -Force
}
"@
$trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 62 -At 9am
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserID System -RunLevel Highest
$params = @{
"TaskName"	= "CBS"
"Action"	= $action
"Trigger"	= $trigger
"Settings"	= $settings
"Principal"	= $principal
}
Register-ScheduledTask @Params -Force
# Включить в Планировщике задач очистки папки %TEMP%
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument 'Get-ChildItem -Path "$env:TEMP" -Force -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue'
$trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 62 -At 9am
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserID System -RunLevel Highest
$params = @{
"TaskName"	= "Temp"
"Action"	= $action
"Trigger"	= $trigger
"Settings"	= $settings
"Principal"	= $principal
}
Register-ScheduledTask @Params -Force
# Запретить приложениям работать в фоновом режиме, кроме Cortana и Безопасность Windows
$Cortana = "Microsoft.Windows.Cortana*"
$SecHealthUI = "Microsoft.Windows.SecHealthUI*"
$ShellExperienceHost = "Microsoft.Windows.ShellExperienceHost*"
Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications -Exclude $Cortana, $SecHealthUI, $ShellExperienceHost |
ForEach-Object {
	New-ItemProperty -Path $_.PsPath -Name Disabled -Value 1 -Force
	New-ItemProperty -Path $_.PsPath -Name DisabledByUser -Value 1 -Force
}
# Включить контроль памяти
IF (!(Test-Path -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy))
{
	New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Force
}
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 01 -Value 1 -Force
# Запускать контроль памяти каждый месяц
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 2048 -Value 30 -Force
# Удалять временные файлы, не используемые в приложениях
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 04 -Value 1 -Force
# Удалять файлы, которые находятся в корзине
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 08 -Value 1 -Force
# Удалять файлы, которые находятся в корзине более 30 дней
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 256 -Value 30 -Force
# Отобразить секунды в системных часах на панели задач
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSecondsInSystemClock -Value 1 -Force
# Установить схему управления питания для стационарного ПК и ноутбука
IF ((Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType -eq 1)
{
	powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
}
Else
{
	powercfg /s 381b4222-f694-41f0-9685-ff5bb260df2e
}
# Использовать последнюю установленную версию .NET Framework для всех приложений
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\.NETFramework -Name OnlyUseLatestCLR -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework -Name OnlyUseLatestCLR -Value 1 -Force
# Не отображать экран блокировки
IF (!(Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization))
{
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Force
}
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Value 1 -Force
# Использовать сценарий автоматической настройки прокси-сервера
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name AutoConfigURL -Type String -Value https://antizapret.prostovpn.org/proxy.pac -Force
# Включить Num Lock при загрузке
New-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard" -Name InitialKeyboardIndicators -Type String -Value 2147483650 -Force
# Не показывать рекомендации в меню Пуск
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SubscribedContent-338388Enabled -Value 0 -Force
# Отключить автоматическую установку рекомендованных приложений
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SilentInstalledAppsEnabled -Value 0 -Force
# Отключить все функции "Windows: интересное" ###
IF (!(Test-Path -Path HKCU:\Software\Policies\Microsoft\Windows\CloudContent))
{
	New-Item -Path HKCU:\Software\Policies\Microsoft\Windows\CloudContent -Force
}
New-ItemProperty -Path HKCU:\Software\Policies\Microsoft\Windows\CloudContent -Name DisableWindowsSpotlightFeatures -Value 1 -Force
# Добавить в исключение Защитник Windows папку
$drives = Get-Disk | Where-Object {$_.IsBoot -eq $false}
IF ($drives)
{
	$drives = ($drives | Get-Partition | Get-Volume | Where-Object {$_.DriveLetter -ne $null}).DriveLetter | ForEach-Object {$_ + ':'}
	Foreach ($drive In $drives)
	{
		Set-MpPreference -ExclusionPath $drive\Программы\Прочее -Force
	}
}
# Отключить справку по F1
IF (!(Test-Path -Path "HKCU:\Software\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64"))
{
	New-Item -Path "HKCU:\Software\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64" -Force
}
New-ItemProperty -Path "HKCU:\Software\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64" -Name "(default)" -Type String -Value "" -Force
# Раскрыть окно Диспетчера задач
$taskmgr = Get-Process -Name Taskmgr -ErrorAction SilentlyContinue
IF ($taskmgr)
{
	$taskmgr.CloseMainWindow()
}
$taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
Do
{
	Start-Sleep -Milliseconds 100
	$preferences = Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager -Name Preferences -ErrorAction SilentlyContinue
}
Until ($preferences)
Stop-Process $taskmgr
$preferences.Preferences[28] = 0
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager -Name Preferences -Type Binary -Value $preferences.Preferences -Force
# Запретить отключение Ethernet-адаптера для экономии энергии
IF ((Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType -eq 1)
{
	$adapter = Get-NetAdapter -Physical | Get-NetAdapterPowerManagement
	$adapter.AllowComputerToTurnOffDevice = "Disabled"
	$adapter | Set-NetAdapterPowerManagement
}
# Установка крупных значков в панели управления
IF (!(Test-Path -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel))
{
	New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel -Force
}
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel -Name AllItemsIconView -Value 0 -Force
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel -Name StartupPage -Value 1 -Force
# Удалить пункт "Изменить с помощью Paint 3D" из контекстного меню
$exts = @(".bmp", ".gif", ".jpe", ".jpeg", ".jpg", ".png", ".tif", ".tiff")
Foreach ($ext in $exts)
{
	Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\$ext\Shell\3D Edit" -Recurse -Force -ErrorAction SilentlyContinue
}
# Удалить пункт "Передать на устройство" из контекстного меню
IF (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"))
{
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}" -Type String -Value "Play to menu" -Force
# Удалить пункт "Отправить" из контекстного меню
Remove-Item -LiteralPath Registry::HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing -Recurse -Force -ErrorAction SilentlyContinue
# Всегда ждать сеть при запуске и входе в систему
IF (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon"))
{
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name SyncForegroundPolicy -Value 1 -Force
# Не показывать уведомление "Установлено новое приложение"
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name NoNewAppAlert -Value 1 -Force
# Переопределить пользовательский метод ввода на английский язык на экране входа
IF (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Control Panel\International"))
{
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Control Panel\International" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Control Panel\International" -Name BlockUserInputMethodsForSignIn -Value 1 -Force
New-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" -Name 1 -Type String -Value 00000409 -Force
New-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" -Name 2 -Type String -Value 00000419 -Force
# Не показывать панель "Люди" на панели задач
IF (!(Test-Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People))
{
	New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People -Force
}
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People -Name PeopleBand -Value 0 -Force
# Скрыть папку "Объемные объекты" из "Этот компьютер"
IF (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"))
{
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name ThisPCPolicy -Type String -Value Hide -Force
IF (!(Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"))
{
	New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name ThisPCPolicy -Type String -Value Hide -Force
# Не показывать анимацию при первом входе в систему
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableFirstLogonAnimation -Value 0 -Force
# Снятие ограничения на одновременное открытие более 15 элементов
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name MultipleInvokePromptMinimum -Value 300 -Force
# Не показывать недавно используемые папки на панели быстрого доступа
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Value 0 -Force
# Не показывать недавно использовавшиеся файлы на панели быстрого доступа
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Value 0 -Force
# Удалить пункт "Добавить в библиотеку" из контекстного меню
Clear-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Folder\shellex\ContextMenuHandlers\Library Location" -Name "(default)" -Force
Clear-ItemProperty -Path "HKLM:\SOFTWARE\Classes\Folder\shellex\ContextMenuHandlers\Library Location" -Name "(default)" -Force
# Удалить пункт "Предоставить доступ к" из контекстного меню
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" -Type String -Value "" -Force
# Удалить пункт "Включить Bitlocker" из контекстного меню
IF (Get-WindowsEdition -Online | Where-Object {$_.Edition -eq "Professional" -or $_.Edition -eq "Enterprise"})
{
	$keys = @(
	"encrypt-bde",
	"encrypt-bde-elev",
	"manage-bde",
	"resume-bde",
	"resume-bde-elev",
	"unlock-bde")
	Foreach ($key in $keys)
	{
		New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Drive\shell\$key -Name ProgrammaticAccessOnly -Type String -Value "" -Force
	}
}
# Открепить от панели задач Microsoft Edge и Microsoft Store
$getstring = @'
[DllImport("kernel32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr GetModuleHandle(string lpModuleName);
[DllImport("user32.dll", CharSet = CharSet.Auto)]
internal static extern int LoadString(IntPtr hInstance, uint uID, StringBuilder lpBuffer, int nBufferMax);
public static string GetString(uint strId)
{
	IntPtr intPtr = GetModuleHandle("shell32.dll");
	StringBuilder sb = new StringBuilder(255);
	LoadString(intPtr, strId, sb, sb.Capacity);
	return sb.ToString();
}
'@
$getstring = Add-Type $getstring -PassThru -Name GetStr -Using System.Text
$unpinFromStart = $getstring[0]::GetString(5387)
$apps = (New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items()
$apps | Where-Object {$_.Path -like "Microsoft.MicrosoftEdge*"} | ForEach-Object {$_.Verbs() | Where-Object {$_.Name -eq $unpinFromStart} | ForEach-Object {$_.DoIt()}}
$apps | Where-Object {$_.Path -like "Microsoft.WindowsStore*"} | ForEach-Object {$_.Verbs() | Where-Object {$_.Name -eq $unpinFromStart} | ForEach-Object {$_.DoIt()}}
# Добавить пункт "Извлечь" для MSI в контекстное меню
IF (!(Test-Path -Path Registry::HKEY_CLASSES_ROOT\Msi.Package\shell\Извлечь\Command))
{
	New-Item -Path Registry::HKEY_CLASSES_ROOT\Msi.Package\shell\Извлечь\Command -Force
}
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Msi.Package\shell\Извлечь\Command -Name "(default)" -Type String -Value 'msiexec.exe /a "%1" /qb TARGETDIR="%1 extracted"' -Force
# Не использовать мои данные для входа для автоматического завершения настройки устройства после перезапуска или обновления
$sid = (Get-CimInstance -ClassName Win32_UserAccount -Filter "name='$env:USERNAME'").SID
IF (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\$sid"))
{
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\$sid" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\$sid" -Name OptOut -Value 1 -Force
# Удалить ярлык Microsoft Edge с рабочего стола
Remove-Item -Path "$env:USERPROFILE\Desktop\Microsoft Edge.lnk" -Force -ErrorAction SilentlyContinue
# Не отображать все папки в области навигации
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name NavPaneShowAllFolders -Value 0 -Force
# Отключить пользовательские службы
$services = @(
"cbdhsvc_*",
"PimIndexMaintenanceSvc_*",
"UnistoreSvc_*",
"UserDataSvc_*")
Foreach ($service In $services)
{
	Get-Service -ServiceName $service | Stop-Service -Force
}
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\cbdhsvc -Name Start -Value 4 -Force
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\cbdhsvc -Name UserServiceFlags -Value 0 -Force
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\PimIndexMaintenanceSvc -Name Start -Value 4 -Force
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\PimIndexMaintenanceSvc -Name UserServiceFlags -Value 0 -Force
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\UnistoreSvc -Name Start -Value 4 -Force
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\UnistoreSvc -Name UserServiceFlags -Value 0 -Force
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\UserDataSvc -Name Start -Value 4 -Force
New-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\UserDataSvc -Name UserServiceFlags -Value 0 -Force
# Скрыть кнопку Windows Ink Workspace
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace -Name PenWorkspaceButtonDesiredVisibility -Value 0 -Force
# Не предоставлять более специлизированные возможности с соотвествующими советами и рекомендациями
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy -Name TailoredExperiencesWithDiagnosticDataEnabled -Value 0 -Force
# Отключить средство просмотра диагностических данных
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey -Name EnableEventTranscript -Value 0 -Force
# Разрешить Windows исправлять размытость в приложениях
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name EnablePerProcessSystemDPI -Value 1 -Force
# Включить блокировки потенциально нежелательных приложений
Set-MpPreference -PUAProtection Enabled
# Удалить список "Недавно добавленные" из меню "Пуск"
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name HideRecentlyAddedApps -Value 1 -Force
# Удалить пункт "Отправить" из контекстного меню
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo -Name "(default)" -Type String -Value "" -Force
# Удалить принтеры
Remove-Printer -Name Fax, "Microsoft XPS Document Writer", "Microsoft Print to PDF" -ErrorAction SilentlyContinue
# Добавить "Запуск от имени друго пользователя" в контекстное меню для exe-файлов
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\exefile\shell\runasuser -Name "(default)" -Type String -Value "@shell32.dll,-50944" -Force
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\exefile\shell\runasuser -Name Extended -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\exefile\shell\runasuser -Name SuppressionPolicyEx -Type String -Value "{F211AA05-D4DF-4370-A2A0-9F19C09756A7}" -Force
New-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\exefile\shell\runasuser\command -Name DelegateExecute -Type String -Value "{ea72d00e-4960-42fa-ba92-7792a7944c1d}" -Force
# Включить доступ к сетевым дискам при включенном режиме одобрения администратором при доступе из программ, запущенных с повышенными правами
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLinkedConnections -Value 1 -Force
# Включить длинные пути Win32
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1 -Force
# Отключить создание ярлыка Edge на рабочем столе после обновления Windows
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name DisableEdgeDesktopShortcutCreation -Value 1 -Force
# Не разрешать приложениям на других устройствах запускать приложения и отправлять сообщения на этом устройстве и наоборот
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP -Name RomeSdkChannelUserAuthzPolicy -Value 0 -Force
# Включить прозрачную панель задач
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name UseOLEDTaskbarTransparency -Value 1 -Force
# Отключить удаление кэша миниатюр
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" -Name Autorun -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" -Name Autorun -Value 0 -Force
# Включить Управляемый доступ к папкам
Set-MpPreference -EnableControlledFolderAccess Enabled
# Добавить защищенную папку
Add-MpPreference -ControlledFolderAccessProtectedFolders D:\folder
# Скрыть уведомление Защитника Windows об использовании аккаунта Microsoft
IF (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows Security Health\State"))
{
	New-Item -Path "HKCU:\Software\Microsoft\Windows Security Health\State" -Force
}
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows Security Health\State" -Name AccountProtection_MicrosoftAccount_Disconnected -Value 1 -Force
# Скрыть уведомление Защитника Windows об отключенном фильтре SmartScreen для Microsoft Edge
New-ItemProperty "HKCU:\Software\Microsoft\Windows Security Health\State" -Name AppAndBrowser_EdgeSmartScreenOff -Value 0 -Force
# Удалить компоненты
$apps = @(
"App.Support.QuickAssist*",
"Hello.Face*",
"Media.WindowsMediaPlayer*",
"OneCoreUAP.OneSync*",
"OpenSSH.Client*")
Foreach ($app in $apps)
{
	Get-WindowsCapability -Online | Where-Object name -Like $app | Remove-WindowsCapability -Online
}
# Создать ярлык для "Устройства и принтеры"
$target = "control"
$file = "$env:AppData\Microsoft\Windows\Start Menu\Programs\System Tools\Устройства и принтеры.lnk"
$shell = New-Object -ComObject Wscript.Shell
$shortcut = $shell.CreateShortcut($file)
$shortcut.TargetPath = $target
$shortcut.Arguments = "printers"
$shortCut.IconLocation = "%SystemRoot%\system32\DeviceCenter.dll"
$shortcut.Save()
# Запускать ярлык к Командной строке от имени Администратора
$bytes = [System.IO.File]::ReadAllBytes("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk")
$bytes[0x15] = $bytes[0x15] -bor 0x20
[System.IO.File]::WriteAllBytes("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk", $bytes)
# Удалить пункт "Создать контакт" из контекстного меню
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\.contact\ShellNew -Name command -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\.contact\ShellNew -Name iconpath -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\.contact\ShellNew -Name MenuText -Force -ErrorAction SilentlyContinue
# Удалить пункт "Создать архив ZIP" из контекстного меню
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\.zip\CompressedFolder\ShellNew -Name Data -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\.zip\CompressedFolder\ShellNew -Name ItemName -Force -ErrorAction SilentlyContinue
# Включить Защиты сети в Защитнике Windows
Set-MpPreference -EnableNetworkProtection Enabled
# Настройка меню Пуск
filter Get-FirstResolvedPath
{
	(Get-Disk | Where-Object {$_.BusType -eq "USB"} | Get-Partition | Get-Volume | Where-Object {$_.DriveLetter -ne $null}).DriveLetter | ForEach-Object {$_ + ':\'} | Join-Path -ChildPath $_ -Resolve -ErrorAction SilentlyContinue | Select-Object -First 1
}
$regpath = 'Folder\Start.reg' | Get-FirstResolvedPath
IF ($regpath)
{
	Remove-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount -Recurse -Force
	Start-Process -FilePath reg.exe -ArgumentList 'import',"$regpath"
}
Else
{
	# Открепить все ярлыки от начального экрана
	$key = Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current
	$data = $key.Data[0..25] + ([byte[]](202,50,0,226,44,1,1,0,0))
	New-ItemProperty -Path $key.PSPath -Name Data -Type Binary -Value $data -Force
}
# Отображать цвет элементов в меню Пуск, на панели задач и в центре уведомлений
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name ColorPrevalence -Value 1 -Force
# Отображать цвет элементов в заголовках окон
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\DWM -Name ColorPrevalence -Value 1 -Force
# Использовать клавишу Print Screen, чтобы запустить функцию создания фрагмента экрана
New-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name PrintScreenKeyForSnippingEnabled -Value 1 -Force
# Отключить автоматическое скрытие полос прокрутки в Windows
New-ItemProperty -Path "HKCU:\Control Panel\Accessibility" -Name DynamicScrollbars -Value 0 -Force
# Группировать одинаковые службы в один процесс svhost.exe
$ram = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum/1kb
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control -Name SvcHostSplitThresholdInKB -Value $ram -Force
# Удалить пункт "Восстановить прежнюю версию" из контекстного меню
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{596AB062-B4D2-4215-9F74-E9109B0A8153}" -Type String -Value "" -Force
# Удалить пункт "Создать Точечный рисунок" из контекстного меню
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\.bmp\ShellNew -Name ItemName -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\.bmp\ShellNew -Name NullFile -Force -ErrorAction SilentlyContinue
# Не включать временную шкалу
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name EnableActivityFeed -Value 0 -Force
# Не разрешать Windows собирать действия с этого компьютера
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name PublishUserActivities -Value 0 -Force
# Не разрешать Windows синхронизировать действия с этого компьютера в облако
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name UploadUserActivities -Value 0 -Force
# Не разрешать приложениям использовать идентификатор рекламы
IF (!(Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo))
{
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo -Force
}
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo -Name DisabledByGroupPolicy -Value 1 -Force
# Не позволять веб-сайтам предоставлять местную информацию за счет доступа к списку языков
New-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name HttpAcceptLanguageOptOut -Value 1 -Force
# Не разрешать Windows отслеживать запуски приложений для улучшения меню "Пуск" и результатов поиска
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Start_TrackProgs -Value 0 -Force
# Удалить пункт "Печать" из контекстного меню для bat- и cmd-файлов
Remove-Item -Path Registry::HKEY_CLASSES_ROOT\batfile\shell\print -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path Registry::HKEY_CLASSES_ROOT\cmdfile\shell\print -Recurse -Force -ErrorAction SilentlyContinue
# Запускать Защитник Windows в песочнице
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
setx /M MP_FORCE_USE_SANDBOX 1
# Удалить пункт "Создать Документ в формате RTF" из контекстного меню
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\.rtf\ShellNew -Name Data -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\.rtf\ShellNew -Name ItemName -Force -ErrorAction SilentlyContinue
# Переопределить расположение папок "Загрузки" и "Документы"
$DiskCount = (Get-Disk | Where-Object {$_.BusType -ne "USB"}).Number.Count
IF ($DiskCount -eq 1)
{
	# Один физический диск
	$drive = (Get-Disk | Where-Object {$_.BusType -ne "USB" -and $_.IsBoot -eq $true} | Get-Partition | Get-Volume | Where-Object {$_.DriveLetter -ne $null}).DriveLetter + ':'
}
Else
{
	# Два физических диска
	$drive = (Get-Disk | Where-Object {$_.BusType -ne "USB" -and $_.IsBoot -eq $false} | Get-Partition | Get-Volume | Where-Object {$_.DriveLetter -ne $null}).DriveLetter + ':'
}
function KnownFolderPath
{
	Param (
		[Parameter(Mandatory = $true)]
		[ValidateSet('Documents', 'Downloads')]
		[string]$KnownFolder,

		[Parameter(Mandatory = $true)]
		[string]$Path
	)
	$KnownFolders = @{
		'Documents' = @('FDD39AD0-238F-46AF-ADB4-6C85480369C7','F42EE2D3-909F-4907-8871-4C22FC0BF756');
		'Downloads' = @('374DE290-123F-4565-9164-39C4925E467B','7D83EE9B-2244-4E70-B1F5-5393042AF1E4');
	}
	$Type = ([System.Management.Automation.PSTypeName]'KnownFolders').Type
	$Signature = @'
	[DllImport("shell32.dll")]
	public extern static int SHSetKnownFolderPath(ref Guid folderId, uint flags, IntPtr token, [MarshalAs(UnmanagedType.LPWStr)] string path);
'@
	$Type = Add-Type -MemberDefinition $Signature -Name 'KnownFolders' -Namespace 'SHSetKnownFolderPath' -PassThru
	# return $Type::SHSetKnownFolderPath([ref]$KnownFolders[$KnownFolder], 0, 0, $Path)
	ForEach ($guid in $KnownFolders[$KnownFolder])
	{
		$Type::SHSetKnownFolderPath([ref]$guid, 0, 0, $Path)
	}
	Attrib +r $Path
}
$Downloads = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
IF ($Downloads -ne "$drive\Загрузки")
{
	IF (!(Test-Path -Path $drive\Загрузки))
	{
		New-Item -Path $drive\Загрузки -Type Directory -Force
	}
	KnownFolderPath -KnownFolder Downloads -Path "$drive\Загрузки"
	New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}" -Type ExpandString -Value "$drive\Загрузки" -Force
}
$Documents = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name Personal
IF ($Documents -ne "$drive\Документы")
{
	IF (!(Test-Path -Path $drive\Документы))
	{
		New-Item -Path $drive\Документы -Type Directory -Force
	}
	KnownFolderPath -KnownFolder Documents -Path "$drive\Документы"
	New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Type ExpandString -Value "$drive\Документы" -Force
}
# Разрешить приложениям доступ к вашему местоположению
New-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location -Name Value -Type String -Value Deny -Force
# Отключить определение местоположения для этого устройства
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location -Name Value -Type String -Value Deny -Force
# Удалить %SYSTEMDRIVE%\PerfLogs
IF ((Test-Path -Path $env:SystemDrive\PerfLogs))
{
	Remove-Item $env:SystemDrive\PerfLogs -Recurse -Force
}
# Удалить %LOCALAPPDATA%\Temp
IF ((Test-Path -Path $env:LOCALAPPDATA\Temp))
{
	Remove-Item $env:LOCALAPPDATA\Temp -Recurse -Force
}
Stop-Process -ProcessName explorer
