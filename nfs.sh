#!/bin/bash

####################
# OWNER: KABBIL GI #
# VERSION: v1      #
# DATE: 12-12-2022 #
####################

for host in `cat /var/host`
do
TOUT=`timeout 60s ssh  -o BatchMode=yes -o StrictHostKeyChecking=no -p 2022 $host date > /dev/null`
if [ $? -eq 0 ]
        then
        Login="ssh -o BatchMode=yes -o StrictHostKeyChecking=no -p 2022"
else
        Login="ssh -o BatchMode=yes -o StrictHostKeyChecking=no"
fi
 
        SSH="$Login"
timeout 60s $SSH $host uptime > /dev/null
if [ $? -eq 0 ]; then
$SSH $host "echo; echo -e '\t\t\t==============='; echo -e '\t\t\t$host'; echo -e '\t\t\t==============='; echo"
else
        echo
        echo "Login Not Success"
fi
echo
echo "Present NFS shares: "
echo
sleep 2
$SSH $host df -T | grep nfs
sleep 4
echo
read -p 'Need to create NFS? [ 'yes/y' or 'no/n' ]: ' ans
if [ "$ans" = yes ] || [ "$ans" = y ] ; then
 
        echo
        echo "creating a NFS share"
        echo
        read -p 'Storage IP: [Default IP 172.20.5.150]' Host
        Host=${Host:-172.20.5.150}
        read -p 'Share_name: ' Share
        echo
        : ${Share:? "Please Enter Share_name field"}
        read -p 'Mount_name: ' Dir
        echo
        : ${Dir:? "Please Enter Mount_name field"}
        $SSH $host " mkdir /$Dir"
        $SSH $host "cp /etc/fstab /etc/fstab_$(date +'%d_%m_%Y')"
        $SSH $host " mount -t nfs $Host:/$Share /$Dir "
 
        if [ $? -eq 0 ]; then
        
                $SSH $host " echo '$Host:/$Share /$Dir nfs defaults 0 0' >> /etc/fstab; sleep 2; echo; "
                $SSH $host "echo -e 'Mounted the share:'; echo; df -T | grep /$Dir; echo "
 
                if [ $? -eq 0 ]; then
                
                        (echo "
Hello kabbil,
 
Mounted the share $Share in the server $host.
 
Regards,
Kabbil
 
                         " )|mail -s "NFS Testing" <TO MAIL ADDRESS>
                fi
 
        else
                 echo " Share not Exported "
 
        fi
 
else
 
        echo
        echo " No need to create NFS share "
        echo
 
fi
 
done
