local url = "https://raw.githubusercontent.com/Hack3rN3w/Scripts/main/Sinonniumhub.lua"

local success, code = pcall(function()
    return game:HttpGet(url)
end)

if success then
    -- 1. Проверяем, не подсунул ли GitHub нам 404 ошибку вместо скрипта
    if code:find("404: Not Found") then
        warn("ОШИБКА 404: Файл 'Sinonniumhub.lua' не найден по этой ссылке!")
    elseif #code > 0 then
        
        -- 2. Безопасно компилируем код БЕЗ моментального вызова скобками ()
        local executableFunction, err = loadstring(code)
        
        -- 3. Если loadstring вернул функцию (а не nil), то запускаем её
        if executableFunction then
            print("Скрипт успешно запущен!")
            executableFunction() 
        else
            -- Если внутри скачанного скрипта была синтаксическая ошибка
            warn("Ошибка компиляции скрипта: " .. tostring(err))
        end
        
    else
        warn("Скрипт пустой!")
    end
else
    warn("Ошибка подключения. Попробуй сменить эксплоит: " .. tostring(code))
end
