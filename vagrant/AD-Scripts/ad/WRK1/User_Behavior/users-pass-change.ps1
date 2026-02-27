$Users = @(
    "a.khan", "b.moore", "c.taylor", "d.thomas", # HR / Admin
    "e.jones", "g.walker", "h.wilson",           # Sales / Ops
    "j.smith", "k.anderson", "l.brown",           # IT / Technical
    "m.ali", "n.martin", "o.lee", "p.evans",     # Finance / Management
    "r.miller", "s.sales1", "s.sales2", "t.dev"  # Sales & Devs
)
$Pass = 'P@ssw0rd123!'

foreach ($U in $Users) {
    try {
        net user $U $Pass /domain
    }
    catch {
        Write-Warning "[!] Failed to reset: $($U.SamAccountName)"
    }
}