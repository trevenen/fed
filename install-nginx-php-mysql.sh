#!/bin/sh
# Script for Fedit.TV to automatically install Server requirements. 
# 
# BEFORE RUNNING THIS SCRIPT MAKE SURE YOU INSTALL CentOS 6.latest 64 bit

########## Prepare server  ##########
rm -f /var/cache/yum/timedhosts.txt;
yum clean all;


########## Looking for what version of centos ###############
arch=`uname -m`
OS_MAJOR_VERSION=`sed -rn 's/.*([0-9])\.[0-9].*/\1/p' /etc/redhat-release`
OS_MINOR_VERSION=`sed -rn 's/.*[0-9].([0-9]).*/\1/p' /etc/redhat-release`
if [ "$arch" = "x86_64" ]; then
	if [ "$OS_MAJOR_VERSION" = 5 ]; then
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm;
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-5.rpm;
	else 
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm;
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm;
	fi
else
	if [ "$OS_MAJOR_VERSION" = 5 ]; then
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm;
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-5.rpm;
	else 
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm;
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm;
	fi
fi

# Add the repo for epel

# Add the repo for 

# Add the repo for 

# Add the repo for NginX

cat > /etc/yum.repos.d/nginx.repo<<EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF

########### Create users and make correct groups ##########
useradd jeff --home-dir=/var/www;
useradd tr --home-dir=/var/www;
useradd sean --home-dir=/var/www;
useradd dani --home-dir=/var/www;
useradd fedit --home-dir=/var/www;
#useradd guys that do the account management
#useradd nginx # Is this needed?
########## Change usernames and remember to run secret script that changes ports and blocks root from ssh access #######

########## Install Nginx PHP MySql via YUM ##########
# To remove run following command.
# yum -y remove httpd nginx php php-* mysqld;

yum -y install yum-fastestmirror;
yum -y install vim wget rsync;
yum -y install git; 

yum --enablerepo=remi -y install make automake gcc gcc-c++ libtool nasm pkconfig patch gcc-g77 ruby ruby-devel rubygems flex bison tar unzip ntp pcre perl pcre-devel httpd-devel zlib zlib-devel GeoIP GeoIP-devel openssl openssl openssl-devel

yum --enablerepo=remi -y install nginx mysql mysql-server php php-common php-fpm php-mysql php-pgsql php-pecl-mongo php-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml php-pecl-apc php-cli php-pear php-pdo

gem install --no-rodoc --no-ri chef-solr
cd /home/fedit/; touch solo.rb; touch chef.json; 
chef-solo -c solo.rb -j /home/fedit/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz
chef-solo -c solo.rb -j /home/fedit/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz

service httpd stop; chkconfig httpd off;
service nginx start; chkconfig nginx on;
service mysqld start; chkconfig mysqld on;
service php-fpm start; chkconfig php-fpm on;

########## Download nginx config files ##########

wget -O /etc/nginx/nginx.conf https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-main-conf.txt;

wget -O /etc/nginx/conf.d/default.conf  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-default-conf.txt;

wget -O /etc/nginx/conf.d/example.com.conf  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-custom-config-example.txt;

wget -O /etc/nginx/conf.d/my_domain https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-my-domain-conf.txt;

rm -f /etc/nginx/conf.d/example_ssl.conf

service nginx restart;

########## Set up a random password for mysql ##########

pass1=`openssl rand 6 -base64`;
pass2="cft.${pass1}";
echo "mysql root password is ${pass2}";
mysqladmin -u root password "${pass2}";


mkdir -p /www/ip.com/custom_error_page;
cd /www/ip.com;

wget -O /www/ip.com/index.php  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-default-index.html;

wget -O /www/mysql-and-sftp-password.php  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-mysql-password.html;

sed -i "s/COMFORTVPSPASSWORD/${pass2}/g" /www/mysql-and-sftp-password.php;

########## Download error pages ##########

wget -O /www/ip.com/custom_error_page/404.html  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-404.html;
wget -O /www/ip.com/custom_error_page/403.html  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-403.html;
wget -O /www/ip.com/custom_error_page/50x.html  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-50x.html;

########## Install phpMyAdmin ##########

wget -O /www/ip.com/phpmyadmin_url.txt  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/phpmyadmin_url.txt
wget -O /www/ip.com/phpMyAdmin4.tar.gz -i /www/ip.com/phpmyadmin_url.txt

tar -zxvf phpMyAdmin*.gz > /dev/null;
rm -f phpMyAdmin*.gz;
mv phpMyAdmin-*-all-languages phpMyAdmin4U;

echo fedit:"${pass2}" | chpasswd;
chown -R fedit:fedit /www;
chmod +x /www;
chmod +x -R /www/ip.com;

######### Configure FFMPEG Deps ############


### Yasm is assembler used by x264 and FFMPEG
curl -O http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzvf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
make distclean
. /home/fedit/.bash_profile

### x264 
cd ~/ffmpeg_sources
git clone --depth 1 git://git.videolan.org/x264
cd x264
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make
make install
make distclean

### libfdk_aac
cd ~/ffmpeg_sources
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean

### Livmp3lame
cd ~/ffmpeg_sources
curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
make
make install
make distclean

### Libopus 
cd ~/ffmpeg_sources
curl -O http://downloads.xiph.org/releases/opus/opus-1.0.3.tar.gz
tar xzvf opus-1.0.3.tar.gz
cd opus-1.0.3
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean

### libogg
cd ~/ffmpeg_sources
curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz
tar xzvf libogg-1.3.1.tar.gz
cd libogg-1.3.1
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean

### libvorbis
cd ~/ffmpeg_sources
curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.3.tar.gz
tar xzvf libvorbis-1.3.3.tar.gz
cd libvorbis-1.3.3
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean

### libvpx
cd ~/ffmpeg_sources
git clone --depth 1 http://git.chromium.org/webm/libvpx.git
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples
make
make install
make clean

### FFMPEG
cd ~/ffmpeg_sources
git clone --depth 1 git://source.ffmpeg.org/ffmpeg
cd ffmpeg
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
export PKG_CONFIG_PATH
./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl --enable-nonfree --enable-libfdk_aac --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264
make
make install
make distclean
hash -r
. ~/.bash_profile
 



########## Display information after installation ##########
clear
echo -e "\n\n\n";
echo "====== Nginx + PHP-FPM + MYSQL Successfully installed";
echo "====== MySql root password is ${pass2}";
echo "====== SFTP Username is myweb";
echo "====== SFTP Password is ${pass2}";
echo "====== Website document root is /www/yourdomain";
echo "====== Add websites tutorials: http://goo.gl/sdDF9";
echo -e "\n\n\n";
echo "====== Now you can visit http://your-ip-address/ ";
echo "====== Eg. http://`hostname -i`/";
echo "====== phpMyAdmin: http://`hostname -i`/phpMyAdmin4U/";
echo -e "\n\n\n";
echo "====== Chef: http://`hostname -i`:4000";
echo -e "\n\n\n";
echo "====== FFMPEG INSTALLED: http://`hostname -i`:/ffmpeg/";
echo -e "\n\n\n";




