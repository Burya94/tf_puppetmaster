#!/bin/bash
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

/opt/puppetlabs/puppet/bin/r10k deploy environment
/opt/puppetlabs/bin/puppetserver gem install hiera-eyaml
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml
mv -f /etc/puppetlabs/code/environments/dev/hiera.yaml /etc/puppetlabs/puppet/hiera.yaml
sed -i -e 's/JAVA_ARGS="-Xms2g -Xmx2g -XX:MaxPermSize=256m"/JAVA_ARGS="-Xms512m -Xmx512m"/' "/etc/sysconfig/puppetserver"
#----------------------------------
systemctl start puppet
free && sync && echo 3 > /proc/sys/vm/drop_caches && free
systemctl start puppetserver
systemctl enable puppetserver
systemctl stop puppet
#-----------------------------------
mkdir -p /etc/puppetlabs/puppet/eyaml
/opt/puppetlabs/puppet/bin/eyaml createkeys --pkcs7-private-key=/etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem
chown -R puppet:puppet /etc/puppetlabs/puppet/eyaml
chmod -R 0500 /etc/puppetlabs/puppet/eyaml
chmod 0400 /etc/puppetlabs/puppet/eyaml/*.pem
cd /etc/puppetlabs/code/environments/dev/ && /opt/puppetlabs/puppet/bin/r10k puppetfile install
#------------------------------------------------------
(crontab -l 2>/dev/null; echo "*/10 * * * * /opt/puppetlabs/puppet/bin/r10k deploy environment") | crontab -
systemctl restart crond
#Also, the memory requirements will vary based on how many Puppet modules you have in your module path, how much Hiera data you have, etc.
#/opt/puppetlabs/puppet/bin/eyaml encrypt
#  --pkcs7-private-key=/etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem \
#  --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem \
#  --string="value"
