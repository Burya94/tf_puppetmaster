#!/bin/bash
timedatectl set-timezone Europe/Kiev
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install git
yum -y install puppetserver
echo "autosign = true" >> /etc/puppetlabs/puppet/puppet.conf
sed -i -e 's/JAVA_ARGS="-Xms2g -Xmx2g -XX:MaxPermSize=256m"/JAVA_ARGS="-Xms512m -Xmx512m"/' "/etc/sysconfig/puppetserver"
/opt/puppetlabs/puppet/bin/gem install r10k
mkdir -p /etc/puppetlabs/r10k

cat > /etc/puppetlabs/r10k/r10k.yaml << EOF
cachedir: '/var/cache/r10k'
sources:
 prod:
  remote: 'https://github.com/Burya94/puppet_code.git'
  basedir: '/etc/puppetlabs/code/environments'
EOF

(crontab -l 2>/dev/null; echo "*/10 * * * * /opt/puppetlabs/puppet/bin/r10k deploy environment dev") | crontab -
systemctl restart crond
/opt/puppetlabs/puppet/bin/r10k deploy environment
mv -f /etc/puppetlabs/code/environments/dev/hiera.yaml /etc/puppetlabs/puppet/hiera.yaml
mkdir -p /etc/puppetlabs/puppet/eyaml
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml
/opt/puppetlabs/puppet/bin/eyaml createkeys --pkcs7-private-key=/etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem
chown -R puppet:puppet /etc/puppetlabs/puppet/eyaml
chmod -R 0500 /etc/puppetlabs/puppet/eyaml
chmod 0400 /etc/puppetlabs/puppet/eyaml/*.pem
cd /etc/puppetlabs/code/environments/dev/ && /opt/puppetlabs/puppet/bin/r10k puppetfile install
#/opt/puppetlabs/bin/puppetserver gem install hiera-eyaml
 free && sync && echo 3 > /proc/sys/vm/drop_caches && free
systemctl start puppet
systemctl start puppetserver
sudo systemctl enable puppetserver
#puppetserver gem install hiera-eyaml - need to be run from cli then restart puppetserver
#/opt/puppetlabs/puppet/bin/eyaml encrypt
#  --pkcs7-private-key=/etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem \
#  --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem \
#  --string="value"
