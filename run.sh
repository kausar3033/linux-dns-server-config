set -x 
sudo apt update
sudo apt install -y bind9 bind9utils bind9-doc dnsutils
cd /etc/bind
cp named.conf.options named.conf.options.bak
echo -e "acl trustedclients {\n        localhost;\n        localnets;\n        192.168.2.0/24;\n};\n\noptions {\n        directory '/var/cache/bind';\n\n        recursion yes;\n        allow-query { trustedclients; };\n        allow-query-cache { trustedclients; };\n        allow-recursion { trustedclients; };\n\n        forwarders {\n                8.8.8.8;\n                8.8.4.4;\n        };\n\n        \n        dnssec-validation no;\n\n        listen-on-v6 port 53 { ::1; };\n        listen-on port 53 { 127.0.0.1; 192.168.2.20; };\n};" >> named.conf.options
sudo named-checkconf
cp named.conf.local named.conf.local.bak
echo -e "zone 'ibos.io' {\n        type master;\n        file '/etc/bind/db.ibos.io';\n};\n\nzone '2.168.192.in-addr.arpa' {\n        type master;\n        file '/etc/bind/db.192.168.2';\n};" >> named.conf.local
sudo named-checkconf
echo -e ";\n; BIND data file for local loopback interface\n;\n$TTL    604800\n@       IN      SOA     prince-supershop.ibos.io. admin.ibos.io. (\n                              3         ; Serial\n                         604800         ; Refresh\n                          86400         ; Retry\n                        2419200         ; Expire\n                         604800 )       ; Negative Cache TTL\n;\n@       IN      NS      prince-supershop.ibos.io.\n\nprince-supershop        IN      A       192.168.2.20" >> db.ibos.io
named-checkzone ibos.io db.ibos.io
echo -e ";\n; BIND reverse data file for ibos.local zone\n;\n$TTL    604800\n@       IN      SOA     prince-supershop.ibos.io. admin.ibos.io. (\n                              2         ; Serial\n                         604800         ; Refresh\n                          86400         ; Retry\n                        2419200         ; Expire\n                         604800 )       ; Negative Cache TTL\n;\n@       IN      NS      prince-supershop.ibos.io.\n\n20       IN      PTR     ibos.ibos.local." >> db.192.168.2
sudo named-checkzone 2.168.192.in-addr.arpa db.192.168.2
sudo systemctl restart bind9
