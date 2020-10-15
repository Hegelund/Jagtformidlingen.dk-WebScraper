# Webscraber for jagtformidling.dk
function Get-HtmlContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$url
    )
    try {
        $query = Invoke-WebRequest -uri $url
        $items = $query.AllElements | Where-Object class -EQ "myrightIMG"
        return $items
        
    }
    catch {
        return $_.Exception
    }
}

function Get-KeywordHit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $HtmlContent,
        [Parameter(Mandatory = $true)]
        [string]$keyword
    )
    try {
        foreach ($item in $HtmlContent) {
            if ($item.innerText -like "*$keyword*") {
                $item.innerText
            }
        }
    }
    catch {
        return $_.Exception
    }
}

function Invoke-Sendmail {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Mail,       
        [Parameter(Mandatory = $true)]
        [string]$Subject,
        [Parameter(Mandatory = $true)]
        [string]$Body,
        [Parameter(Mandatory = $true)]
        [string]$Password
    )
    try {
        $EmailFrom = $Mail
        $EmailTo = $Mail
        $SMTPServer = "smtp.gmail.com"
        $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
        $SMTPClient.EnableSsl = $true
        $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Mail, "$Password");
        $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
    }
    catch {
        return $_.Exception
    }
}

# Urls for different part of the site
$Bukkejagt = "http://jagtformidling.dk/category.aspx?ID=1"
$Udlejes = "http://jagtformidling.dk/Ads.aspx?ID=6"
$Konsortiepladser = "http://jagtformidling.dk/Ads.aspx?ID=11"
$Jagtkammerat = "http://jagtformidling.dk/category.aspx?ID=12"
$And = "http://jagtformidling.dk/category.aspx?ID=13"
$gratis = "http://jagtformidling.dk/category.aspx?ID=14"
$klapjagt = "http://jagtformidling.dk/category.aspx?ID=22"
$andet = "http://jagtformidling.dk/category.aspx?ID=23"

# Scrabing the Content
$Bukkejagt_content = Get-HtmlContent -url $Bukkejagt
$Udlejes_content = Get-HtmlContent -url $Udlejes
$Konsortiepladser_content = Get-HtmlContent -url $Konsortiepladser
$Jagtkammerat_content = Get-HtmlContent -url $Jagtkammerat
$And_content = Get-HtmlContent -url $And
$gratis_content = Get-HtmlContent -url $gratis
$klapjagt_content = Get-HtmlContent -url $klapjagt
$andet_content = Get-HtmlContent -url $andet

# Putting content into array
$contents = @(
    $Bukkejagt_content
    $Udlejes_content
    $Konsortiepladser_content
    $Jagtkammerat_content
    $And_content
    $gratis_content
    $klapjagt_content 
    $andet_content
)

# Inset keywords here
$keywords = @(
    'Brædstrup'
    '8740'
    'Nørre snede'
    'Klovborg'
    'Addit'
    'Vestbirk'
    'Østbirk'
    'Voervadsbro'
    'Hammel'
    'Postnummer: 8740'
    'Østlolland'
)

# INSET EMAIL AND PASSWORD HERE
$Mail = "MyEmail@gmail.com"
$MyPswd = "MyPassword" 
# Encrypting password 
$encryptedPassword = ConvertTo-SecureString $MyPswd -AsPlainText -Force | ConvertFrom-SecureString 
# Or stor you password as secure string
#$encryptedPassword = "myEncryptedPassword"

# Decrypting password
$password = $encryptedPassword | ConvertTo-SecureString 
$password = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($password)

# Doing the magic
foreach ($keyword in $keywords) {  
    foreach ($content in $contents) {
        $Body = Get-KeywordHit -HtmlContent $content -keyword $keyword
        if (![string]::IsNullOrEmpty($Body)) { 
            $Subject = "Jagtformidling Keyword Alert Keyword - $keyword"
            Invoke-Sendmail -Mail $Mail -Subject $Subject -body $body -Password $password
        } 
    }   
}
