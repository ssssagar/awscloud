#!/bin/bash


JENKINS_VERSION=2.426.3
TERRAFORM_BIN_VERSION=1.9.8-1

# Enable debugging and exit on error 
set -ex

sudo apt update
sudo apt -y upgrade
sudo apt -y install nvme-cli zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget unzip gpg gnupg software-properties-common
sudo nume id-ctrl —output binary /dev/nvme1n1 | cut -c3073-3104 | tr -d '\0'
PRESENT_WORKING_DIR=`pwd`
mkdir -p / run/python
cd /run/python
#sudo make install

# Check if Python 3 is installed
if command -v python3 &>/dev/null; then
    echo "Python 3 is already installed."
    python3 --version
else
    echo "Python 3 is not installed. Installing now..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-dev
    echo "Python 3 installation complete."
    python3 --version
    pip --version
    ln -s /usr/bin/python3 /usr/bin/python
fi

cd $PRESENT_WORKING_DIR
# Activate volume groups 
vgchange -ay

# Check the file system type of the specified device DEVICE="/dev/nvme1n1"
DEVICE_FS=`blkid -o value -s TYPE /dev/nvme1n1 || echo ""`

if [ "`echo -n $DEVICE_FS`" == "" ] ; then
	# Wait for the device to be attached and format it if not formatted
	DEVICENAME=`basename "/dev/nvme1n1"`
	DEVICEEXISTS='' 
	# Loop to verify device attachment
	while [[ -z $DEVICEEXISTS ]]; do 
		echo "verify $DEVICENAME"
		DEVICEEXISTS=`lsblk | grep "$DEVICENAME" | wc -l`
		if [[ $DEVICEEXISTS != "1" ]]; then 
			sleep 15
		fi
	done
	# Ensure the device file in /dev/ exists within a time limit 
	count=0
	until [[ -e "/dev/nvme1n1" || "$count" == "60" ]]; do 
		sleep 5
	count=$(expr $count + 1) 
	done
# Initialize physical volume, create volume group, and logical volume 
	pvcreate /dev/nvme1n1
	vgcreate vg00 /dev/nvme1n1
	lvcreate -n vol_jenkins -l 100%FREE vg00 
	# Create a file system on the volume
	mkfs.ext4 /dev/vg00/vol_jenkins
fi
# Create directory /vol_jenkins if it doesn't exist 
mkdir -p /vol_jenkins
# Add entry to /etc/stab for mounting at boot
echo "/dev/vg00/vol_jenkins /vol_jenkins ext4 defaults 0 0" >> /etc/fstab 

mounted_dir="/vol_jenkins"

# Threshold size in GB (change as per your requirement)
threshold_size=30  # Example: 10 GB

# Get the allocated size of the mounted directory in GB
allocated_size=$(df -BG "$mounted_dir" | awk 'NR==2 {print $2}' | sed 's/G//')

# Compare the allocated size with the threshold
if [ "$allocated_size" -eq "$threshold_size" ]; then
    echo "EBS volume is already mounted."
    sleep 5
else
	# Mount /vol_ jenkins
	mount /dev/vg00/vol_jenkins /vol_jenkins
    echo "EBS volume mounted."
fi

# Ensure the device file in /vol_jenkins exists within a time limit
mount_count=0

# File to check
directory_to_check="/vol_jenkins"

# Loop until the counter reaches 60 seconds or the file exists
until [ $mount_count -ge 60 ] || [ -d "$directory_to_check" ]; do
    echo "Mount Counter: $mount_count seconds"
    
    # Increment the counter by 5 seconds
    mount_count=$((mount_count + 5))
    
    # Wait for 5 seconds
    sleep 5
done

echo "Installing jenkins"

# Function to check if Jenkins is installed
check_jenkins_installed() {
    if command -v jenkins &> /dev/null; then
        echo "Jenkins is already installed."
        jenkins --version
        return 0
    else
        echo "Jenkins is not installed."
        return 1
    fi
}

# Install Jenkins if not installed
install_jenkins() {
    echo "Installing Jenkins..."
    sudo apt install -y openjdk-17-jdk
    # Add Jenkins repository
	sudo mkdir -p /run/jenkins/keyrings/
	sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
	sudo echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
	sudo apt update
	sudo apt install jenkins=${JENKINS_VERSION} -y
	#sudo ufw allow 8080/tcp 
	#sudo ufw reload
	#sudo ufw allow OpenSSH
	#sudo ufw enable
	#sudo ufw status
	mkdir -p /vol_jenkins/jenkins_home/
	sudo systemctl stop jenkins
	sudo usermod -d /vol_jenkins/jenkins_home/jenkins jenkins
	sudo cp -prv /var/lib/jenkins/ /vol_jenkins/jenkins_home
	sudo chown -R jenkins:jenkins /vol_jenkins/jenkins_home/jenkins
	sudo sed -i 's|JENKINS_HOME=.*|JENKINS_HOME=/vol_jenkins/jenkins_home/jenkins|' /etc/default/jenkins
	sudo sed -i 's|JENKINS_HOME=/var/lib/jenkins|JENKINS_HOME=/vol_jenkins/jenkins_home/jenkins|' /lib/systemd/system/jenkins.service
	sudo sed -i 's|WorkingDirectory=/var/lib/jenkins|WorkingDirectory=/vol_jenkins/jenkins_home/jenkins|' /lib/systemd/system/jenkins.service
	sudo systemctl daemon-reload
	sudo systemctl start jenkins 
	sudo systemctl enable jenkins
	sudo cat /vol_jenkins/jenkins_home/jenkins/secrets/initialAdminPassword
	echo "Jenkins installation completed"

    echo "Jenkins installation complete."
    jenkins --version
}

if ! check_jenkins_installed || -n "${JENKINS_VERSION}" ; then
    install_jenkins
fi

echo "Installing awscli"
# Check if awscli is installed
if command -v aws &>/dev/null; then
    echo "awscli is already installed."
    aws --version
else
    echo "awscli is not installed. Installing now..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install
    aws --version
fi

echo "Installing terraform"
# Install terraform
if [ -n "${TERRAFORM_BIN_VERSION}" ] || command -v terraform &>/dev/null; then
	echo "Terraform installation started"

	sudo wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
	sudo echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

	sudo apt update
	sudo apt install terraform=${TERRAFORM_BIN_VERSION} -y
	terraform -v
	sudo apt-mark hold terraform
	#Remove Hold: If you want to allow future updates for Terraform, you can remove the hold by running:
	#sudo apt-mark unhold terraform
	
	#Available Versions: You can list available versions in the HashiCorp APT repository by using:
	#apt list -a terraform

	echo "Terraform ${TERRAFORM_BIN_VERSION} installation completed" 
else
	echo "Terraform installation skipped" 
fi

echo "Ubuntu configuration completed."