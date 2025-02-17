#!/bin/bash

#Enable debugging and exit on error
set -x

sudo dd if=/dev/zero of=/swapfile bs=128M count=16 
sudo chmod 600 /swapfile 
sudo mkswap /swapfile 
sudo swapon /swapfile 
sudo swapon -s

echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

sudo mount -o remount,size=5G /tmp/

max_attempts=10 attempt_num=1 success=false 
while [ $success = false ] && [ $attempt_num -le $max_attempts ]; do 
	echo "Trying yum install" 
	sudo yum update -y 
	sudo yum upgrade -y

	sudo yum install lvm2 docker nvme-cli wget unzip gpg java-17-amazon-corretto-devel telnet git-2.39.1 ansible-8.3.0 -y 
	sudo yum install -y /usr/bin/systemctl

	#Check the exit code of the command
	if [ $? -eq 0 ]; then 
		echo "Yum install succeeded" 
		success=true 
	else 
		echo "Attempt $attempt_num failed. Sleeping for 3 seconds and trying again..." 
		sleep 5 ((attempt_num++)) 
	fi 
done

sudo nvme id-ctrl --output binary /dev/nvme1n1 | cut -c3073-3104 | tr -d '\0'

PRESENT_WORKING_DIR=`pwd`

cd $PRESENT_WORKING_DIR

#Activate volume groups
vgchange -ay

#Check the file system type of the specified device
DEVICE="/dev/nvme1n1" 
DEVICE_FS=`blkid -o value -s TYPE /dev/nvme1n1 || echo ""` 
if [ "`echo -n $DEVICE_FS`" == "" ] ; then

	#Wait for the device to be attached and format it if not formatted
	DEVICENAME=`echo "/dev/nvme1n1" | awk -F '/' '{print $3}'` 
	DEVICEEXISTS=''

	#Loop to verify device attachment
	while [[ -z $DEVICEEXISTS ]]; do 
		echo "verify $DEVICENAME" 
		DEVICEEXISTS=`lsblk | grep "$DEVICENAME" | wc -l` 
		if [[ $DEVICEEXISTS != "1" ]]; then 
			sleep 15 
		fi 
	done

	#Ensure the device file in /dev/ exists within a time limit
	count=0 
	until [[ -e "/dev/nvme1n1" || "$count" == "60" ]]; do 
		sleep 5 
		count=$(expr $count + 1) 
	done

	#Initialize physical volume, create volume group, and logical volume
	pvcreate /dev/nvme1n1 
	vgcreate vg00 /dev/nvme1n1 
	lvcreate -n vol_jenkins -l 100%FREE vg00

	#Create a file system on the volume
	mkfs.ext4 /dev/vg00/vol_jenkins 
fi

#Create directory /vol_jenkins if it doesn't exist
mkdir -p /vol_jenkins

#Add entry to /etc/fstab for mounting at boot
echo "/dev/vg00/vol_jenkins /vol_jenkins ext4 defaults 0 0" >> /etc/fstab

#Mount /vol_jenkins
mount /dev/vg00/vol_jenkins /vol_jenkins 
echo "EBS volume mounted."

sleep 5

#Ensure the device file in /vol_jenkins exists within a time limit
mount_count=0 
until [[ -e "/vol_jenkins" || "$mount_count" == "60" ]]; do 
	sleep 5 mount_count=$(expr $mount_count + 1) 
done

#Install jenkins
if [ -n "${JENKINS_VERSION}" ]; then 
	echo "Jenkins installation started" 
	wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo 
	rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

	max_attempts=10 attempt_num=1 success=false 
	while [ $success = false ] && [ $attempt_num -le $max_attempts ]; do 
		echo "Trying yum install"

		sudo yum update -y
		sudo yum install jenkins-${JENKINS_VERSION} -y

		# Check the exit code of the command
		if [ $? -eq 0 ]; then
  		echo "Yum install succeeded"
  		success=true
		else
  			echo "Attempt $attempt_num failed. Sleeping for 3 seconds and trying again..."
  			sleep 5
  			((attempt_num++))
		fi
	done

		sudo mkdir -p /vol_jenkins/jenkins_home/ 
		sudo systemctl enable jenkins 
		sudo systemctl start jenkins 
		sudo systemctl stop jenkins 
		sudo usermod -d /vol_jenkins/jenkins_home/jenkins jenkins 
		sudo cp -prv /var/lib/jenkins/ /vol_jenkins/jenkins_home 
		sudo rm -r /var/lib/jenkins/ 
		sudo chown -R jenkins:jenkins /vol_jenkins/jenkins_home/jenkins 
		sudo sed -i 's|JENKINS_HOME=/var/lib/jenkins|JENKINS_HOME=/vol_jenkins/jenkins_home/jenkins|' /lib/systemd/system/jenkins.service
		sudo sed -i 's|WorkingDirectory=/var/lib/jenkins|WorkingDirectory=/vol_jenkins/jenkins_home/jenkins|' /lib/systemd/system/jenkins.service 
		sudo systemctl daemon-reload 
		sudo systemctl enable jenkins 
		sudo systemctl start jenkins 
		sudo cat /vol_jenkins/jenkins_home/jenkins/secrets/initialAdminPassword 
		echo "Jenkins installation completed" 
		sudo rm -f /etc/yum.repos.d/jenkins.repo 
		sudo usermod -s /bin/bash jenkins 
else 
	echo "Jenkins installation skipped" 
fi

#Install pip
wget -q https://bootstrap.pypa.io/get-pip.py 
python3 get-pip.py 
rm -f get-pip.py

#Install terraform
if [ -n "${TERRAFORM_VERSION}" ]; then 
	echo "Terraform installation started" 
	wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}linux_amd64.zip unzip terraform${TERRAFORM_VERSION}_linux_amd64.zip
	mv terraform /usr/local/bin
	terraform --version 
	echo "Terraform installation completed" 
else 
	echo "Terraform installation skipped" 
fi

echo "Amazon Linux configuration completed."
