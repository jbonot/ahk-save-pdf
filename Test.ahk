#Requires AutoHotkey v2
#include Utils.ahk
#include ..\UIA-v2-main\Lib\UIA.ahk

Assert(result, key, test) {
    if (result) {
        OutputDebug("Pass`t" . key . '`t' . test . '`r`n')
    } else {
        OutputDebug("Fail`t" . key . '`t' . test . '`r`n')
    }
}

TestCapitalizeName() {
    cases := [
        ["JOHN DOE", "John Doe"],
        ["john doe", "John Doe"],
    ]

    for index, entry in cases {
        Assert(CapitalizeName(entry[1]) == entry[2], index, "TestCapitalizeName")
    }
}

TestLoadConfig() {
    config := LoadConfig('config.example.ini')
    Assert(config.Has("windowTitle"), "key", "TestLoadConfig")
    Assert(config["windowTitle"] == "Editor", "value", "TestLoadConfig")
}

TestGetPatientData() {
    properties := ["age", "dob", "name", "country"]
    cases := [
        ["24j (01/01/2000) DOE, JANE (NL)", {
            age: "24j",
            dob: "01.01.2000",
            name: "Doe, Jane",
            country: "NL"
        }],
        ["invalid", 0],
    ]

    for index, entry in cases {
        data := GetPatientData(entry[1])
        if (data) {
            Assert(
                data.age == entry[2].age &&
                data.dob == entry[2].dob &&
                data.name == entry[2].name &&
                data.country == entry[2].country
                , index, "TestGetPatientData"
            )
        } else {
            Assert(data == entry[2], index, "TestGetPatientData")
        }
    }
}

TestLoadDates() {
    entries := LoadDates('dates.example.txt')
    expected := [{
        day: "03",
        month: "05",
        year: "2024",
        name: "Skywalker"
    }, {
        day: "04",
        month: "05",
        year: "2024",
        name: "Solo"
    }]

    for index, entry in entries {
        Assert(
            entry.day == expected[index].day &&
            entry.month == expected[index].month &&
            entry.year == expected[index].year &&
            entry.name == expected[index].name
            , index, "TestGetPatientData"
        )
    }
}

Main() {
    TestCapitalizeName()
    TestLoadConfig()
    TestGetPatientData()
    TestLoadDates()
}

Main()