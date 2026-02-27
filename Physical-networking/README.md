# Description
This section is based on Cisco layer 3 switches and I'm using SPAN to copy the traffic and send them to the NIDS. Also this setup is using inter-vlan routing function of layer 3 switches.  
# Network 1 (Normal Traffic)
** NOTE: This section is the same in all of the networks.**  
**1. Fa0/2 -> WRK1**  
**2. Fa0/4 -> SVR1**  
**3. Fa0/6 -> DC01**  
**4. Fa0/8 -> NIDS**  
  
```
# Enable and configure terminal
enable 
conf t  

# Define vlan
vlan 56 
name enzy-fyp-AD  
exit  

# Repeat this for all fa 0/2, 0/4, /0/6
int fa 0/2
switchport mode access  
switchport access vlan 56  
spanning-tree portfast 
exit   

# SPAN session configuration
monitor session 1 source interface fa0/2 both # Repeat this for all fa 0/2, 0/4, /0/6
monitor session 1 destination interface fa0/8

# The layer 3 gateway
int vlan 56
ip address 192.168.56.1 255.255.255.0
no shut
exit

# in the enable mode
write memory
```  
**The IP table**  
```
Port 2   |  WRK1 |  192.168.56.200 
Port 4  |  SVR1   |  192.168.56.100
Port 6  |  DC01   |  192.168.56.10
Port 8  |  NIDS   |  192.168.56.300
```  
# Networks 2 and 3 (Attack Traffics)
**This is for both attack networks and it is aditional to the privious network configuration**  
**5. Fa0/10 -> attacker machine**  
```
enbale  
conf t

vlan 66
name enzy-fyp-attack
exit

int fa 0/10
switchport mode access
switchport access vlan 66
spanning-tree portfas
exit 

int vlan 66
ip address 192.168.66.1 255.255.255.0
no shut
exit

monitor session 1 source interface fa0/10 both
```

# ACL logic

```
ip access-list extended attack-svr
permit ip 192.168.66.0 0.0.0.255 host 192.168.56.100
deny ip 192.168.66.0 0.0.0.255 192.168.56.0 0.0.0.255
permit ip 192.168.66.0 0.0.0.255 any
exit

int vlan 66
ip access-group attack-svr in
exit 

# in the enable mode
write memory
```
# VM and AD networking
**On the host set the ip address to whatever but the ips that are being used in the AD**  
Set the VMs to bridge adaptor and chose the network card that your lan is connected to.