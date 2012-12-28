#!/bin/bash
#
#==============================================================================
#                                                                             +                                                              +
#Date   = 23-08-2010                                                          +
#Usage  = Install EE based on the environment.                                + 
#                                                                             +
#                                                                             +   
#==============================================================================
echo -e "Enter the environment which you want to install and configure on the system. "
echo -e "Devloper environment [dev] Test Environment [test] Build Environment [build]:\c "
read  env
echo "$env environment is going to install."
install_properties="install.properties"
env_details=`sed -n "s|<${env}>\(.*\)</${env}>|\1|p" environmentoptions.xml`
echo $env_details
echo $env_details | sed -e 's/YES/YES\n/g' | sed -e 's/\s//g' > $install_properties
./environment-setup.sh
