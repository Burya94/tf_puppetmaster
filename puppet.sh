#!/bin/bash -v
timedatectl set-timezone Europe/Kiev
hostnamectl set-hostname puppet
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum update -y
yum -y install puppetserver
echo "autosign = true" >> /etc/puppetlabs/puppet/puppet.conf
sed -i -e 's/JAVA_ARGS="-Xms2g -Xmx2g"/JAVA_ARGS="-Xms512m -Xmx512m"/' "/etc/sysconfig/puppetserver"
systemctl start puppetserver
systemctl enable puppetserver
cat >>/etc/hosts << EOF
172.16.34.4   slave1
172.16.34.5   slave2
EOF

cat >/etc/puppetlabs/code/environments/production/manifests/site.pp << EOF
package { 'ntp' :
        ensure => installed,
        }
case $::osfamily{
      'redhat': {
        service {'ntpd':
          ensure => running,
        }
      }
      'debian': {
        service {'ntp':
          ensure => running,
        }
      }
    }
EOF
