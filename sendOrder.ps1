# Version 0.1


# Run in an infinite loop at intervals of 5 seconds
while (1 -eq 1) {

# Save the current security protocol settings
$cur = [System.Net.ServicePointManager]::SecurityProtocol
try {
    # Without it, the IIKO does not give the token
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    # Define the current directory where the script is located
    $currentPath = $PSScriptRoot

    # Getting token
    try {
       $token = (Invoke-WebRequest -Uri http://localhost:9042/api/login/2050).Content.Trim('"')

        # Most likely you will have to store the token in a variable, since it does not allow for frequent updates
        $tokenFile = $currentPath + "\token.txt"
        $token | Out-File -FilePath $tokenFile

    } catch [Exception] {
        # If it was not possible to get the token from the IIKO - try to use the saved in the file
        $tokenFile = $currentPath + "\token.txt"
        $token = Get-Content $tokenFile
    }

    # Creating a request to receive orders
    $orderRequest = Invoke-WebRequest -Uri http://localhost:9042/api/orders?key=$token
    
    # Getting the device name
    $deviceName = $env:computername

    # Getting the order service address
    $urlConfFile = $currentPath + "\url.conf"
    $orderServiceUrl = Get-Content $urlConfFile
    $tempUrl = $orderServiceUrl + "?posDeviceName="  + $deviceName

    # Sending data to the order service
    Invoke-WebRequest $tempUrl -ContentType "application/json" -Method Post -Body $orderRequest.Content

} finally {
    # Returning protocol settings
    [System.Net.ServicePointManager]::SecurityProtocol = $cur
}

# Wait 5 seconds and then repeat
Start-Sleep -Seconds 5

}
