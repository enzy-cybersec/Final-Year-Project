# Descripotion of the project 
**comparing machine learning algorithms to reduce false alarms in NIDS in an AD network**  
This project focuses on Active Directory network security and the goal is to figure out which machine learning algorithem (Logistic Regression, Random Forest, XGBoost, and Isolation Forest), will perform better to identify and reduce false alarms of an NIDS.

# Details
This project has several parts:  
**1. Building and AD for the project**  
**2. Building a network with NIDS**  
**3 Generating clean/non-malicious traffic to capture for ML model training**  
**4. Generating attack/malicious traffic to capture for ML model trainign and examination**  
**5. Training ML models**  
**6. Examination**  
**7. Analysing the results**  
**8. developing a report based on the results**  

# Map of the Networks
**In the both networks, L3 switch is been used for inter vlan routing and VMs are directly set to ethernet cable to the phisical network**  
<img width="445" height="363" alt="ADnormal-edit" src="https://github.com/user-attachments/assets/9e818f8f-9423-4f9d-bda0-a1718b51f7d6" />  
This network is for the Normal Enterprise traffic capturing and all the AD VMs are in the same vlan and the switch is using SPAN to copy all packets and send them to the NIDS (RPi5).  
<img width="445" height="363" alt="ADattacker-edit" src="https://github.com/user-attachments/assets/5e23b1e7-abb3-4ddb-b63d-9d5d0453cf2c" />  
This network is for the Normal Enterprise traffic capturing and all the AD VMs are in the same vlan while the attacker can only access the SVR1 and the switch is using SPAN to copy all packets and send them to the NIDS (RPi5).  
**The normal network traffic and one of the attack traffics are used for model training while another attack traffic is used for testing the models.**
  
**Please note that setting up these networks requires knowlege of networking specially DNS**  
# Map of the AD Scripts
**Note that you will find more scripts based on the needs in the path ```vagrant/AD-Scripts```as well**  
```
├── NIDS
│	├── rpi-cap-nodel.service
│	└── rpi_cap_no_del.sh
│
├── Physical-networking
│	├── SPAN-Monitor.txt
│
└── vagrant/AD-Scripts/ad/
	├── DC01/
	│   └── Population/
	│       ├── Create_OUs.ps1
	│       ├── Create_Department_OUs.ps1
	│       ├── Create_Users.ps1  
	│       ├── Create_Groups.ps1
	│       ├── Assign_GroupMembership.ps1     
	│       ├──  Create_ServiceAccounts.ps1 
	│       └──README.md
	│
	├── SVR1/
	│   ├── Server_Prep/
	│   │   ├── FileServer_Prep.ps1
	│   │   ├── IIS_Prep.ps1
	│   │   └── README.md
	│   │
	│   └── BackgroundNoise/
	│           ├── Service_Auth.ps1
	│           └── README.md
	│
	└── WRK1/
	      ├── Machine_Behaviour/
	      │   ├── GPO_Refresh.ps1
	      │   ├── Machine_Auth.ps1
	      │
	      ├── User_Behaviour/
	      │   ├── Morning_Logons.ps1
	      │   ├── Login_Loops.ps1
	      │   └── Interactive_Use.ps1
	      │
	      ├── Work_Activity/
	      │   ├── SMB_Usage.ps1
	      │   └── Web_Requests.ps1
	      │
	      ├── Background_Noise/
	      │      └── Periodic_AD_Queries.ps1
	      │
	      └── Scheduler
	             ├── Scheduler.ps1
	             └── Scheduler_System.ps1
```  
# How to use the scripts  
In order to use the scripts you will need to use the AD setup scripts first and then move to the population.  
**The noise and behaviour based scripts is only for the NIDS to capture the normal traffic both in the normal network and while attack**  
**Please use the vulnerability scripts on AD for attack networks not the normal one**  
**The best aproch is to have 3 cloned AD sets for each network**  
**One also can use the setup for AD pentesting practice**  
