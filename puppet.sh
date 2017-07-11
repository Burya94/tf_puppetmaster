#!/bin/bash
sudo timedatectl set-timezone Europe/Kiev
sudo rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install git
sudo yum -y install puppetserver
sudo bash -c 'echo "autosign = true" >> /etc/puppetlabs/puppet/puppet.conf'
sudo sed -i -e 's/JAVA_ARGS="-Xms2g -Xmx2g -XX:MaxPermSize=256m"/JAVA_ARGS="-Xms512m -Xmx512m"/' "/etc/sysconfig/puppetserver"
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
sudo /opt/puppetlabs/puppet/bin/gem install r10k
sudo mkdir -p /etc/puppetlabs/r10k

sudo bash -c "cat > /etc/puppetlabs/r10k/r10k.yaml << EOF
cachedir: '/var/cache/r10k'
sources:
 prod:
  remote: 'https://github.com/Burya94/puppet_code.git'
  basedir: '/etc/puppetlabs/code/environments'
EOF"

(crontab -l 2>/dev/null; echo "*/10 * * * * /opt/puppetlabs/puppet/bin/r10k deploy environment dev") | crontab -
sudo systemctl restart crond
sudo /opt/puppetlabs/puppet/bin/r10k deploy environment
sudo mv -f /etc/puppetlabs/code/environments/dev/hiera.yaml /etc/puppetlabs/puppet/hiera.yaml
sudo mkdir -p /etc/puppetlabs/puppet/eyaml
sudo /opt/puppetlabs/puppet/bin/gem install hiera-eyaml
sudo /opt/puppetlabs/puppet/bin/eyaml createkeys --pkcs7-private-key=/etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem
sudo chown -R puppet:puppet /etc/puppetlabs/puppet/eyaml
sudo chmod -R 0500 /etc/puppetlabs/puppet/eyaml
sudo chmod 0400 /etc/puppetlabs/puppet/eyaml/*.pem
sudo cd /etc/puppetlabs/code/environments/dev/ && sudo /opt/puppetlabs/puppet/bin/r10k puppetfile install
#/opt/puppetlabs/bin/puppetserver gem install hiera-eyaml
sudo bash -c "free && sync && echo 3 > /proc/sys/vm/drop_caches && free"
sudo systemctl start puppet
sudo systemctl stop puppetserver
sudo systemctl start puppetserver
#puppetserver gem install hiera-eyaml - need to be run from cli then restart puppetserver
#/opt/puppetlabs/puppet/bin/eyaml encrypt
#  --pkcs7-private-key=/etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem \
#  --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem \
#  --string="value"
