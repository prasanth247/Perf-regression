#!/bin/bash
# For any queries, please contact reddy.adalam@smarsh.com

pd=`pwd`
StartDate=`date +"%m%d%Y%H%M%S"`
#cd ../docker-jmeter
#./build.sh
#ls /opt/apache-jmeter-5.1.1/bin
cp jmeterscripts/*.jar jmeterscripts/randomwords.txt /opt/apache-jmeter-5.1.1/lib
echo "copied required files for creating batches"
ls /opt/apache-jmeter-5.1.1/lib grep "GenerateData.jar"
cd jmeterscripts
#---Disable all active jobs---
jmeter -n -D javax.net.ssl.keyStore=cc-stage-superuser.p12 -D javax.net.ssl.keyStorePassword=superuser -D javax.net.ssl.keyStoreType=pkcs12
-t Disablealljobs.jmx -l Disablealljobs_$StartDate.jtl
echo "disabled all jobs"
