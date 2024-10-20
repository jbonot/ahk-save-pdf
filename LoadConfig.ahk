#Requires AutoHotkey v2

LoadConfig(filename) {
    configFilePath := A_ScriptDir . "\" . filename

    if !FileExist(configFilePath) {
        MsgBox "Config file not found!"
        ExitApp
    }

    configContent := FileRead(configFilePath)

    config := Map()
    for line in StrSplit(configContent, "`r`n") {
        line := Trim(line)
        
        if line = "" || SubStr(line, 1, 1) = ";" {
            continue 
        }
        
        ; Expected format: <key>=<value>
        parts := StrSplit(line, "=")
        if parts.Length = 2 {
            key := Trim(parts[1])
            value := Trim(parts[2])
            config[key] := value
        }
    }

    return config
}