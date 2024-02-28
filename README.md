# CARTP Scripts

### TL;DR
Random scripts that I used in the CARTP course lab & final exam.

I relied hevily on **AzureRT** (https://github.com/mgeeky/AzureRT), it had a few bugs that needed fixing, and I also added multiple custom functions to it to speed up repetitive tasks like connecting Az/AzureAD modules, enumeration, etc.


### Custome Tools
##### Stand-alone
Loot-VM.ps1
Various post-foothold checks. PRT, AzureADJoin, User Data, PS console history & more.

findADFS.ps1
Checks for ADFS instance in the domain.
(*Never got the chance to test this tool and probably never will since I'm already done with the exam.*)

---

##### Included in AzureRT.ps1
Connect-All
Connects both Az and Azure AD using provided credentials
`Connect-All -UserName 'admin@foo.onmicrosoft.com' -Password 'Pa$$w0rd'`

Evil-Winrm
You already know what this does x)
`Evil-Winrm -UserName admin -Password 'Pa$$w0rd' -TargetIP 10.10.10.10 -TargetHostName ADConnectVM`

Whois
Enumerates a given user and lists his details. i.e. Group memeberships, Role assignment, Admin Units, etc.
`whois 'admin@foo.onmicrosoft.com'`

List-DeviceOwners
Loops all readable users and lists who owns what - no parameters needed.
`List-DeviceOwners`

</eof>