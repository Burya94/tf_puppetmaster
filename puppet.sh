#!/bin/bash
mount /dev/xvda2 /mnt
dd if=/dev/zero of=/mnt/swapfile bs=1M count=2048
chown root:root /mnt/swapfile
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile
echo "/mnt/swapfile swap swap defaults 0 0" >> /etc/fstab
echo "vm.swappiness = 100" >> /etc/sysctl.conf
sysctl -p
timedatectl set-timezone Europe/Kiev
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install git
yum -y install puppetserver
echo "autosign = true" >> /etc/puppetlabs/puppet/puppet.conf
/opt/puppetlabs/puppet/bin/gem install r10k
mkdir -p /etc/puppetlabs/r10k

cat > /etc/puppetlabs/r10k/r10k.yaml << EOF
cachedir: '/var/cache/r10k'
sources:
 prod:
  remote: 'https://github.com/Burya94/puppet_code.git'
  basedir: '/etc/puppetlabs/code/environments'
EOF

mv -f /etc/puppetlabs/code/environments/dev/hiera.yaml /etc/puppetlabs/puppet/hiera.yaml
sed -i -e 's/JAVA_ARGS="-Xms2g -Xmx2g -XX:MaxPermSize=256m"/JAVA_ARGS="-Xms512m -Xmx512m"/' "/etc/sysconfig/puppetserver"
#----------------------------------
systemctl start puppet
free && sync && echo 3 > /proc/sys/vm/drop_caches && free
systemctl start puppetserver
systemctl enable puppetserver
systemctl stop puppet
#-----------------------------------
/opt/puppetlabs/puppet/bin/r10k deploy environment -p

#------------------------------------------------------

#Also, the memory requirements will vary based on how many Puppet modules you have in your module path, how much Hiera data you have, etc.
#/opt/puppetlabs/puppet/bin/eyaml encrypt
#  --pkcs7-private-key=/etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem \
#  --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem \
#  --string="value"
