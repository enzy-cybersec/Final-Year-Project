
netsh interface ip delete address "Ethernet 2" addr=192.168.56.100

win10.vm.network "private_network", ip: "192.168.56.10", adapter: 2
