
# check -for correct number of arguments
if ($args.Count -ne 3)
{
    Write-Output "Please input the URI, Username and Password"
    exit 1

}

#assign arguments to variables
$uri = $args[0]
$user = $args[1]
$pass = $args[2]

#concatenate the user/pass for base64 encoding
$userpass = "$($user):$($pass)"

#create URI strings for API calls (LunsURI is an unfinished URI)
$unisphereKeysURI = "$($uri)/univmax/restapi/performance/Array/keys"
$unisphereLunsURI = "$($uri)/univmax/restapi/provisioning/symmetrix/"

#encode user/pass
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($userpass)
$auth =[Convert]::ToBase64String($Bytes)

#prepare headers for Unisphere Get Request
$headers = @{}
$headers.Add("authorization", $auth)
$headers.Add("accept", "application/json")

#Get keys from Unisphere
$keysReturn = Invoke-WebRequest -Uri $unisphereKeysURI -Headers $headers | ConvertFrom-Json

#Drill down into returned object
$keysArrayInfo = $keysReturn.arrayInfo

#Place all Sym IDs in array
$symKeys = @()

For($i=0; $i -lt $keysArrayInfo.Length; $i++){
    
    $symKeys += $keysArrayInfo[$i].symmetrixId

}

#Make API calls for each Sym ID in array.

For($i=0; $i -lt $symKeys.Length; $i++){
    Write-Output "Symmetrix ID: $($symKeys[$i])"
    $symIdURI = "$($unisphereLunsURI)/$($symKeys[$i])/volume"
    $LunsReturn = Invoke-WebRequest -Uri $symIdURI -Headers $headers | ConvertFrom-Json
    Write-Output $LunsReturn

}



