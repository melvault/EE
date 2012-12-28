#!/bin/bash
#
#==============================================================================
#                                                                             +     
#Author = Narendra Gollapilli  (narendra.gollapilli@gmail.com)                +
#Date   = 04-03-2011                                                          +
#Usage  = Environment setup for SunJava,Tomcat,Jboss,Eclipse,Maven            + 
#                                                                             +
#                                                                             +   
#==============================================================================
PS_BIT=`uname -m`
# Creating local repositiory.
repo="/opt/melvault/EE0.8"
if [ -d $repo ]
then
 echo "melvault directory existed in /opt/"
else
 mkdir -p $repo
 echo "melvault directory created in /opt/"
fi

#Setup Tomcat 6.0
function tomcat()
{
  if [ -d "$repo/tomcat6.0.28" ]
  then
    echo "Tomcat6.0.28 installed $repo."
  else
    echo "Tomcat not installed in $repo."
    tar -xvf apache-tomcat-6.0.28.tar.gz; 
    mv apache-tomcat-6.0.28 $repo/tomcat6.0.28
    echo "************Configuring tomcat ports 8080-> 9080, ajp 8009->9089 
         and secure port as 9443.******************"
    sed -e 's/8080/9090/g' -e 's/8009/9009/g' -e 's/8005/9005/g' -e 's/8443/9443/g' \
    $repo/tomcat6.0.28/conf/server.xml > /tmp/TMPFILE
    mv /tmp/TMPFILE $repo/tomcat6.0.28/conf/server.xml
    echo "===== Start tomcat server as $repo/tomcat6.0.28/bin/startup.sh======="
    echo "==============http://localhots:9080/=============="
  fi
}

#Setup Mysql Java  connector

function mysql_connector_java()
{
   if [ -d "$repo/mysql-connector-java" ]
  then
   echo "mysql-connector-java installed $repo."
  else
   echo "mysql-connector-java not installed $repo."
   tar -xvf mysql-connector-java-5.0.8.tar.gz
   mv mysql-connector-java-5.0.8 $repo/mysql-connector-java
  fi
}

#Setup Sun jdk 1.6
function sunjdk()
{ 
  echo "FROM SDK"
  if [ -d "$repo/jdk1.6.0_21" ]
  then
    echo "jdk1.6.0_21 installed $repo."
  else
    echo ${PS_BIT}
    if [[ "${PS_BIT}" == *x86_64* ]]; then
      chmod +x jdk-6u21-linux-x64.bin; touch sun_jdk.log
      ./jdk-6u21-linux-x64.bin < sun_jdk.log; mv jdk1.6.0_21 $repo
    elif [[ "${PS_BIT}" == *i686* ]]; then
      chmod +x jdk-6u21-linux-i586.bin; touch sun_jdk.log
      ./jdk-6u21-linux-i586.bin < sun_jdk.log; mv jdk1.6.0_21 $repo
    fi
    rm -rf sun_jdk.log
  fi
  mysql_connector_java
  echo "==============Installed Sun Jdk 1.6.0_21 @ $repo.=================="
}

#Setup Jboss with 8080 port.
function jboss()
{
 if [ -d "$repo/jboss" ]
 then
  echo "jboss installed $repo."
 else
  echo "jboss not installed $repo."
  unzip jboss-5.1.0.GA-jdk6.zip
  mv jboss-5.1.0.GA $repo/jboss
  echo "JAVA_HOME=$repo/jdk1.6.0_21
CLASSPATH=$JAVA_HOME/lib:$repo/mysql-connector-java
LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/i386
JAVA_OPTS=\"-Xms256m -Xmx1024m -XX:MaxPermSize=512M\"
export PATH=\${JAVA_HOME}/bin:\${PATH}
export JAVA_HOME PATH CLASSPATH LD_LIBRARY_PATH JAVA_OPTS
JBOSS_HOME=$repo/jboss
export PATH=\${JBOSS_HOME}/bin:\${PATH}" > "$repo/ee.sh"
  chmod +x $repo/ee.sh
  rm -f /etc/profile.d/ee.sh
  ln -s $repo/ee.sh /etc/profile.d/ee.sh
  source /etc/profile.d/ee.sh
  #chcon -t textrel_shlib_t $repo/jdk1.6.0_21/jre/lib/i386/client/libjvm.so
  chown -R jboss $repo/jboss
  su jboss; exit
  echo "JBOSS installed at $repo with port 8080."
 fi
}


#Maven setup
function maven()
{
 if [ -d "$repo/maven" ]
 then
  echo "maven installed at $repo."
 else
  echo "maven  not installed at $repo."
  tar -xvzf apache-maven-3.0.3-bin.tar.gz
  mv apache-maven-3.0.3 $repo/maven
  M2_HOME=$repo/maven
  PATH=$M2_HOME/bin:$PATH
  echo "maven installed at $repo."
fi
}

#Add user
function addUsers()
{
 jboss=`cat /etc/passwd | grep ^jboss`
 if [[ "${jboss}" == *jboss* ]]; then
  jboss="true"
 else
  useradd -s /bin/bash -c "Jboss User" -g root jboss
 fi

 qbuild=`cat /etc/passwd | grep ^qbuild`
 if [[ "${qbuild}" == *qbuild* ]]; then
  qbuild="true"
 else
 rm -rf /opt/melvault/qbuild
  useradd -s /bin/bash -m -d /opt/melvault/qbuild -c "melvault Build User" -g root qbuild
  #chown -R qbuild /opt/melvault/qbuild
 fi
}

#Create symnlinks
function createSymlink()
{
if [ -d "/opt/melvault/EE" ]
  then
   rm "/opt/melvault/EE"
   ln -s $repo "/opt/melvault/EE"
   echo "exist removed" 
  else
   ln -s $repo "/opt/melvault/EE"
   echo "symlink created for EE"
fi
}
while read line
do 
  if [ "$line" == "TOMCAT=YES" ]   
  then
    tomcat  
   else 
      if [ "$line" == "JBOSS=YES" ] 
      then
       jboss
      else
         if [ "$line" == "JAVA=YES" ] 
         then
          sunjdk
         else
               if [ "$line" == "MAVEN=YES" ]
               then
                 maven
               else 
                echo "Setup completed."
               fi
         fi
      fi
  fi
  createSymlink
  addUsers 
done < "install.properties"
