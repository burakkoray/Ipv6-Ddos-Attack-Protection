#Burak Koray KOSE
#Gebze Institute of Technology Grad Project
#Ddos Preventation Script with Iptables


#version 1.4
#new rules added
#New chain rules added




#!/bin/bash
#
# Firewall rules
# 

######################################################################
function on {
    echo "Firewall: ESTABLISHED"
       	
ip6tables -F
ip6tables -X
ip6tables -t mangle -F
ip6tables -t mangle -X
 
#loop back e izin veme
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
 
# içerden dos u engelle 
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP
 
# Allow full outgoing connection but no incomming stuff
ip6tables -A INPUT -i $PUBIF -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A OUTPUT -o $PUBIF -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
 
# allow incoming ICMP ping pong stuff
ip6tables -A INPUT -i $PUBIF -p ipv6-icmp -j ACCEPT
ip6tables -A OUTPUT -o $PUBIF -p ipv6-icmp -j ACCEPT
 

# log everything else
ip6tables -A INPUT -i $PUBIF -j LOG
ip6tables -A INPUT -i $PUBIF -j DROP

#kuralları sile
iptables -t nat -F
iptables -t mangle -F

#kuralları sil
iptables -X
iptables -t nat -X
iptables -t mangle -X





#synflood
#Checking connetions limiting and dropping 
#we can change the limit
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 60/minute --limit-burst 120 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/minute --limit-burst 2 -j LOG
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP




#Allowing normal requests

# Allow incoming DNS requests.
iptables -A INPUT -m state --state NEW -p udp --dport 53 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 53 -j ACCEPT

# Allow incoming HTTP requests.
iptables -A INPUT -m state --state NEW -p tcp --dport 80 -j ACCEPT

# Allow incoming HTTPS requests.
iptables -A INPUT -m state --state NEW -p tcp --dport 443 -j ACCEPT

# Allow incoming POP3 requests.
iptables -A INPUT -m state --state NEW -p tcp --dport 110 -j ACCEPT

# Allow incoming IMAP4 requests.
iptables -A INPUT -m state --state NEW -p tcp --dport 143 -j ACCEPT

# Allow incoming POP3S requests.
iptables -A INPUT -m state --state NEW -p tcp --dport 995 -j ACCEPT

# Allow incoming SMTP requests.
iptables -A INPUT -m state --state NEW -p tcp --dport 25 -j ACCEPT

# Allow incoming SSH requests.
iptables -A INPUT -m state --state NEW -p tcp --dport 22 -j ACCEPT

# Allow incoming FTP requests.
iptables -A INPUT -m state --state NEW -p tcp --dport 21 -j ACCEPT



#synflood preventation test
iptables -N SYN_FLOOD
iptables -A INPUT -p tcp --syn -j SYN_FLOOD
iptables -A SYN_FLOOD -m limit --limit 2/s --limit-burst 6 -j RETURN
iptables -A SYN_FLOOD -j DROP



# Make It Even Harder To Multi-PING
#can change limits
iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 2 -j ACCEPT
iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 2 -j LOG --log-prefix PING-DROP:
iptables -A INPUT -p icmp -j DROP
iptables -A OUTPUT -p icmp -j ACCEPT



}
######################################################################
function off {
    # stop firewall
    echo "Firewall: disabling filtering (allowing all access)"
    ip6tables -F
    ip6tables -F -t mangle
    ip6tables -P INPUT ACCEPT
    ip6tables -P OUTPUT ACCEPT
    ip6tables -P FORWARD ACCEPT

    
    #delete rules 
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
}
######################################################################
function stop {
    # stop all external connections
    echo "Firewall: stopping all external connections"
    ip6tables -F INPUT
    ip6tables -F OUTPUT
    ip6tables -P INPUT DROP
    ip6tables -P FORWARD REJECT
    ip6tables -P OUTPUT REJECT

    # allow anything over loopback
    ip6tables -A INPUT -i lo -s ::1/128 -j ACCEPT
    ip6tables -A OUTPUT -o lo -d ::1/128 -j ACCEPT

    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
}

case "$1" in
    start)
	on
    ;;
    stop)
	off
    ;;
    
    *)
	echo "options: {start|stop|off}"

    ;;
esac



