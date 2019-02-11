#!/bin/bash


echo "#######################  Git Clone and build application    #####################"

# NOTE: Making git clone as commant as project was not buildable issue was with make file,please compare to see the fix  
# git clone https://github.com/ThoughtWorksInc/infra-problem 

cd infra-problem

apt-get install -y leiningen

make libs

make clean all


if [ $? -ne 0 ]; then
     echo "------------ Build Failed!!!!!--------------- "
     exit 1
fi


echo "#######################      build complete                  #####################"


echo "#######################      creating new key pair                #####################"


cd ..


. create_key_pair.sh 

echo "new key-pair has been created - you can find private key in '/tmp/ssh_util//keypair.key' "

cd terraform

echo "--------------------------------------------------------------------------"
        echo Initialize terraform
        terraform init -input=false
        if [ $? -ne 0 ]; then
            retval=$?
            echo Terraform init failed!
            shutdown $retval
        fi
echo "--------------------------------------------------------------------------" 


        terraform apply -auto-approve
            if [ $? -ne 0 ]; then
                retval=$?
                echo Terraform apply failed!
                shutdown $retval
            fi

















