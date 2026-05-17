# 🪟 nitrate92's Automated Setup Software (ASS)
![nitrate92's ASS](ass.png)
Making Windows tolerable since 2021. Officially supports Windows 11 24H2, but has previously functioned similarly on Windows 10.

## ⚙️ Execution policy settings
`Set-Executionpolicy Unrestricted`

# 💡 How
The `ass/go.ps1` script is designed to install WinGet and any applications you'd like in the config, remove some default apps, and set your time zone. `ass/preferences.reg` contains quality of life settings. It is very much worth reading the comments so you can add or remove registry tweaks.

# ⁉️ Why?
I am a lunatic who reinstalls Windows every year or two. This is also rather convenient for quickly setting up other systems I want to use without having to poke through menus or the registry to change defaults.