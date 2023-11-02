# This file downloads the default ignition file to install k3s
# after the run on this script from you windows installation 
# where you choose to run the deplu scripts - run the following
# mkdir %userprofile%\.kube
# ssh core@xpinode1 "sudo cat /etc/rancher/k3s/k3s.yaml" > %userprofile%\.kube\config
rm ignition.json || wget http://10.9.7.189:8888/ignition.json
sudo flatcar-install -d /dev/sda -i ignition.json