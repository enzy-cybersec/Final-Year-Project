#  Description
I'm using "tshark" to capture the packets for this project:  

# Capture Everything on eth0
**NOTE: please change the interface name based on your system**  
```
#!/bin/bash
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
/usr/bin/tshark -i eth0 -w /home/pi/baseline_$TIMESTAMP.pcap
```
# any attacker realated traffic
**NOTE: please change the interface name based on your system**  
This will help to notice how much of the traffic is flaged by the NIDS and the ML model  
```
#!/bin/bash
# Script 2: Attacker IP Isolation
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
/usr/bin/tshark -i eth0 -f "host 192.168.66.100" -w /home/pi/attacker_only_$TIMESTAMP.pcap
```
# DNS traffic
**NOTE: please change the interface name based on your system**  
Since in the attack we are using DNS tunneling we will need to capture this separatelly to make the analisys easier.  
```
#!/bin/bash
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
/usr/bin/tshark -i eth0 -f "port 53 and host 192.168.56.100 and host 192.168.56.10" -w /home/pi/dns_logic_$TIMESTAMP.pcap
```
# Crontab
**This is optional**  
```
#!/bin/bash

SCRIPT1="/home/pi/script1.sh"
SCRIPT2="/home/pi/script2.sh"
SCRIPT3="/home/pi/script3.sh"

crontab -l > mycron 2>/dev/null

echo "59 08 * * * /bin/bash $SCRIPT1 > /dev/null 2>&1" >> mycron
echo "59 08 * * * /bin/bash $SCRIPT2 > /dev/null 2>&1" >> mycron
echo "59 08 * * * /bin/bash $SCRIPT3 > /dev/null 2>&1" >> mycron

echo "01 17 * * * /usr/bin/pkill tshark" >> mycron

crontab mycron
rm mycron
```