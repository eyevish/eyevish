# ======================================================================================
# This file downloads the default ignition file to install k3s
# after the run on this script from you windows installation 
# where you choose to run the deplu scripts - run the following
# mkdir %userprofile%\.kube
# ssh core@xpinode1 "sudo cat /etc/rancher/k3s/k3s.yaml" > %userprofile%\.kube\config
# ======================================================================================

rm -f ignition.json ; curl -sfL https://github.com/eyevish/eyevish/raw/main/ignition.json -o ignition.json
sudo flatcar-install -d /dev/sda -i ignition_sip.json
echo -e "\n======================================================================================\n"
echo -e " To access the Kubernetes server and deploy your IMM run the following 
 command from your \"Windows host with xpi installation\" using a DOS CMD windows.    
   \033[0;32m
   mkdir %userprofile%\.kube
   ssh core@xpinode1 \"sudo cat /etc/rancher/k3s/k3s.yaml\" > %userprofile%\\.kube\\\config              
   \033[0m
NOTE: The first command may return an error if the folder already exists."
echo .

read  -p "If you saw success of flatCar installer, you may boot into the OS; \n Would you line to reboot ? (Y/[N]): " ansYN
if  [[ $ansYN =~ [Yy] ]];  then 
  echo Rebooting ......
  sudo eject cdrom
  sudo reboot
fi