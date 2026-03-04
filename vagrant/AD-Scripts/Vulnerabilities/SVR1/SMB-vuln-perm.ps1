# 1. Ensure the directory exists
New-Item -Path "C:\Public_Exchange" -ItemType Directory -Force

# 2. Apply NTFS Permissions (The Folder)
$Path = "C:\Public_Exchange"
$Acl = Get-Acl $Path
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("ANONYMOUS LOGON","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$Acl.SetAccessRule($Ar)
$ArGuest = New-Object System.Security.AccessControl.FileSystemAccessRule("Guest","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$Acl.SetAccessRule($ArGuest)
Set-Acl $Path $Acl

# 3. Apply Share Permissions (The Network Entry Point)
Grant-SmbShareAccess -Name "Exchange" -AccountName "ANONYMOUS LOGON" -AccessRight Full -Force
Grant-SmbShareAccess -Name "Exchange" -AccountName "Guest" -AccessRight Full -Force
Grant-SmbShareAccess -Name "Exchange" -AccountName "Everyone" -AccessRight Full -Force