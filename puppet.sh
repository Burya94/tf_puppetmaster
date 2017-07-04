#!/bin/bash -v
timedatectl set-timezone Europe/Kiev
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum update -y
yum -y install git
yum -y install puppetserver
echo "autosign = true" >> /etc/puppetlabs/puppet/puppet.conf
sed -i -e 's/JAVA_ARGS="-Xms2g -Xmx2g -XX:MaxPermSize=256m"/JAVA_ARGS="-Xms512m -Xmx512m"/' "/etc/sysconfig/puppetserver"
systemctl start puppetserver
systemctl enable puppetserver
yum install ruby -y
/opt/puppetlabs/puppet/bin/gem install r10k
mkdir -p /etc/puppetlabs/r10k

sed -i -e 's/"nodes/%{::trusted.certname}"/"%{::osfamily}"/' '/etc/puppetlabs/puppet/hiera.yaml'

cat > /etc/puppetlabs/r10k/r10k.yaml << EOF
cachedir: '/var/cache/r10k'
sources:
 prod:
  remote: 'https://github.com/Burya94/puppet_code.git'
  basedir: '/etc/puppetlabs/code/environments'
EOF


(crontab -l 2>/dev/null; echo "*/10 * * * * /opt/puppetlabs/puppet/bin/r10k deploy environment dev") | crontab -
systemctl restart crond
