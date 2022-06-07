# Version 0.1


#Запускаем в бесконечном цмкле с интервалом 5 секунд
while (1 -eq 1) {

#Сохраняем текущие настройки протоколов
$cur = [System.Net.ServicePointManager]::SecurityProtocol
try {
    #Без этого айка не отдает токен
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    #Определяем текущую директорию, в которой лежит скрипт
    $currentPath = $PSScriptRoot

    #Получаем токен
    try {
       $token = (Invoke-WebRequest -Uri http://localhost:9042/api/login/2050).Content.Trim('"')

        #Скорее всего придется хранить токен в переменной, т.к. не дает часто обновлять (на будущее)
        $tokenFile = $currentPath + "\token.txt"
        $token | Out-File -FilePath $tokenFile

    } catch [Exception] {
        # Если не получилось взять токен из айки - пытаемся использовать сохраненный в файле
        $tokenFile = $currentPath + "\token.txt"
        $token = Get-Content $tokenFile
    }


    #Создаем запрос на получение заказов
    $orderRequest = Invoke-WebRequest -Uri http://localhost:9042/api/orders?key=$token
    
    #Получаем имя устройства
    $deviceName = $env:computername

    #Получаем адрес order service
    $urlConfFile = $currentPath + "\url.conf"
    $orderServiceUrl = Get-Content $urlConfFile
    $tempUrl = $orderServiceUrl + "?posDeviceName="  + $deviceName

    #Отправляем данные в order
    Invoke-WebRequest $tempUrl -ContentType "application/json" -Method Post -Body $orderRequest.Content

} finally {
    #Возвращаем настройки протоколов
    [System.Net.ServicePointManager]::SecurityProtocol = $cur
}

#Ждем 5 секунд и повторяем
Start-Sleep -Seconds 5

}
