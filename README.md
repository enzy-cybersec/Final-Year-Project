# Descripotion of the project 
***comparing machine learning algorithms to reduce false alarms in NIDS in an AD network***
This project focuses on Active Directory network security and the goal is to figure out which machine learning algorithem (Logistic Regression, Random Forest, XGBoost, and Isolation Forest), will perform better to identify and reduce false alarms of an NIDS.

# Details
This project has several parts
**1. Building and AD for the project**
**2. Building a network with NIDS**
**3 Generating clean/non-malicious traffic to capture for ML model training**
**4. Generating attack/malicious traffic to capture for ML model trainign and examination**
**5. Training ML models**
**6. Examination**
**7. Analysing the results**
**8. developing a report based on the results**

#Map of the Scripts

```
├── RPi5
│	├── rpi-cap-nodel.service
│	└── rpi_cap_no_del.sh
│
├── switch
│	├── SPAN-Monitor.txt
│
└── vagrant/fyp/ad/
	├── DC01/
	│   └── PhaseA_AD_Population/
	│       ├── Create_OUs.ps1
	│       ├── Create_Department_OUs.ps1
	│       ├── Create_Users.ps1  
	│       ├── Create_Groups.ps1
	│       ├── Assign_GroupMembership.ps1     
	│       ├──  Create_ServiceAccounts.ps1 
	│       └──README.md
        │
	├── SVR01/
	│   ├── PhaseF_Server_Prep/
	│   │   ├── FileServer_Prep.ps1
	│   │   ├── IIS_Prep.ps1
	│   │   └── README.md
	│   │
	│   └── PhaseE_Background_Noise/
	│           ├── Service_Auth.ps1
	│           └── README.md
	│
	└── WRK01/
	      ├── PhaseB_Machine_Behavior/
	      │   ├── GPO_Refresh.ps1
	      │   ├── Machine_Auth.ps1
	      │
	      ├── PhaseC_User_Behavior/
	      │   ├── Morning_Logons.ps1
	      │   ├── Login_Loops.ps1
	      │   └── Interactive_Use.ps1
	      │
	      ├── PhaseD_Work_Activity/
	      │   ├── SMB_Usage.ps1
	      │   └── Web_Requests.ps1
	      │
	      └── PhaseE_Background_Noise/
	             └── Periodic_AD_Queries.ps1
```