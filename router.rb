# Install the necessary packages 

# system("sudo apt-get install hostapd")
# system("sudo apt-get install dnsmasq")
# system("sudo apt-get install bridge-utils")

# Set the SSID and password for the access point
@ssid = "tp-link-wn722n" 
@wpa_passphrase = "12345678"
@interface = "wlan0" # The interface used by the AP
@interf4ce = "wlan1" # Bridge interface
@ipv4 = "192.168.1" # "10.1.0"  # "172.16.0"

# Configuration hostapd WPA2-PSK and CCMP
File.open("/etc/hostapd/hostapd.conf", "w") do |conf|

  conf.puts "interface=#{@interface}"
  conf.puts "driver=nl80211"
  conf.puts "ssid=#{@ssid}"
  conf.puts "hw_mode=g" # "hw_mode=g" = 2.4GHz, "hw_mode=a" = 5GHz band
  conf.puts "channel=11" 
  conf.puts "wpa=2"
  conf.puts "rsn_pairwise=CCMP" 
  conf.puts "wpa_passphrase=#{@wpa_passphrase}"
  # conf.puts "bridge=br0"

  end
 
  
File.open("/etc/dnsmasq.conf", "w") do |conf|

  conf.puts "interface=#{@interface}"
  conf.puts "dhcp-range=#{@ipv4}.2,#{@ipv4}.30,255.255.255.0,12h"
  conf.puts "dhcp-option=3,#{@ipv4}.1"
  conf.puts "dhcp-option=6,#{@ipv4}.1"
  conf.puts "server=8.8.8.8"
  conf.puts "log-queries" 
  conf.puts "log-dhcp"
  conf.puts "listen-address=127.0.0.1"

  end

# system("nmcli device disconnect wlan0") # Dissociated interface from any AP
system("ifconfig #{@interface} up #{@ipv4}.1 netmask 255.255.255.0") 
system("echo '1' > /proc/sys/net/ipv4/ip_forward") # Enabling IP-Forwarding for IPv4 
system("echo > /var/lib/misc/dnsmasq.leases") # Clear dnsmasq.leases
system("systemctl restart dnsmasq") # Restart DNS/DHCP services

# Setting Rules firewall with iptables 
system("iptables --flush ")
system("iptables --delete-chain")
system("iptables --table nat --flush")
system("iptables --table nat --delete-chain")
system("iptables --table nat -A POSTROUTING -o #{@interf4ce} -j MASQUERADE")
system("iptables -A FORWARD -i #{@interface} -o #{@interf4ce} -j ACCEPT")

# Starting Access Point
system("sudo hostapd /etc/hostapd/hostapd.conf")

