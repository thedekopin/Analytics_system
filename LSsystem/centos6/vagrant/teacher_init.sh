echo "Provision teacher_vm"
echo "Step1: Update yum repository"
sudo yum -y update

echo "Step2: Add epel repository"
sudo yum -y epel-release

echo "Step3: Install necessary software"
sudo yum -y install java-1.8.0-openjdk-devel gcc curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker

echo "Step4: Install git (version >=2.4.0)"
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.4.0.tar.gz
tar -zxvf git-2.4.0.tar.gz
sudo mv git-2.4.0/ /
rm -rf git-2.4.0.tar.gz
cd /git-2.4.0
sudo ./configure --prefix=/usr/local
make
sudo make install
git -version
# sudo visudoコマンドでsource_pathに/usr/local/bin/を追記
# 時間があれば，sedコマンドでできるようにする．

echo "Step5: Mongodb configuration"
# 以下は公式ページを参照 https://docs.mongodb.com/v3.4/tutorial/install-mongodb-on-amazon/
# Install MongoDB Community Edition
# 1. Configure the package management system (yum)
# sudo vim /etc/yum.repos.d/mongodb-org-3.4.repo
# ----------------
# [mongodb-org-3.4]
# name=MongoDB Repository
# baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/
# gpgcheck=1
# enabled=1
# gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc
# ----------------
#
# 2. Install the MongoDB packages and associated tools.
# sudo yum install -y mongodb-org
# 
# Run MongoDB Community Edition
# 1. Start MongoDB
# sudo service mongod start
# 2. Verify that MongoDB has started successfully
# 3. Stop MongoDB
# sudo service mongodb stop
# 4. Restart MongoDB
# sudo service mongodb restart

echo "Step6: Apache configuration"
sudo yum -y install httpd
sudo service httpd start
sudo chkconfig httpd on
sudo service httpd status

echo "Step7: Tomcat7 configuration"
sudo yum -y install tomcat tomcat-webapps
sudo service tomcat start
sudo chkconfig tomcat on
sudo service tomcat status

echo "Step8: Link Apache and Tomcat7"
echo "Please execute the following command"
# Apache側の設定
# 1. 以下の設定が含まれていることを確認
# cat /etc/httpd/conf.modules.d/00-proxy.conf
# ----------------
# LoadModule proxy_module modules/mod_proxy.so
# LoadModule proxy_ajp_module modules/mod_proxy_ajp.so
# ----------------
# 
# 2. 以下のファイルを作成
# sudo vim /etc/httpd/conf.d/proxy-ajp.conf
# <Location / >
#  ProxyPass ajp://localhost:8009/
#  Order allow,deny
#  Allow from all
# </Location>
#
# Tomcat側の設定
# 3. 以下の設定が含まれていることを確認
# cat /etc/tomcat/server.xml
# ----------------
# <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
# ----------------
# ----------------
# Apache側からTomcatのページを表示させるため、8080ポートの設定を無効化する。
# <!--
# <Connector port="8080" protocol="HTTP/1.1"
#  connectionTimeout="20000"
#  redirectPort="8443" />
# -->
# ----------------
# 
# 4. Apacheの再起動
# sudo service httpd restart

echo "Step9: Gitbucket configuration"
sudo wget https://github.com/gitbucket/gitbucket/releases/download/4.21.0/gitbucket.war
sudo mv gitbucket.war /var/lib/tomcat/webapps/
# gitbucketの設定ファイルも時間があれば自動化する
# 下記のファイルをsedコマンドで編集すれば，base_urlとSSH，SSH用のhostの登録は可能
# sudo vim /usr/share/tomcat/.gitbucket/gitbucket.conf
# sshの公開鍵の登録がコマンドから行えるかが現状わからないため，
# とりあえず，手動で設定する．
