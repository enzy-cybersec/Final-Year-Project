FYP-Automation/
│
├── DC01/
│   └── PhaseA_AD_Population/
│       ├── A1_Create_OUs.ps1
│       ├── A2_Create_Department_OUs.ps1
│       ├── A3_Create_Users.ps1  
│       ├── A4_Create_Groups.ps1
│       ├── A5_Assign_GroupMembership.ps1     
│       └── A6_Create_ServiceAccounts.ps1 
│
├── SVR01/
│   ├── PhaseF_Server_Prep/
│   │   ├── F1_FileServer_Prep.ps1
│   │   ├── F2_IIS_Prep.ps1
│   │
│   ├── PhaseD_Work_Activity/
│   │   ├── D1_SMB_Usage.ps1
│   │   └── D2_Web_Requests.ps1
│   │
│   └── PhaseE_Background_Noise/
│       └── E1_Service_Auth.ps1
│
└── WRK01/
      ├── PhaseB_Machine_Behavior/
      │   ├── B1_GPO_Refresh.ps1
      │   ├── B2_Machine_Auth.ps1
      │
      ├── PhaseC_User_Behavior/
      │   ├── C1_Morning_Logons.ps1
      │   ├── C2_Login_Loops.ps1
      │   └── C3_Interactive_Use.ps1
      │
      └── PhaseE_Background_Noise/
      └── E2_Periodic_AD_Queries.ps1