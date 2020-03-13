#!/bin/bash
# For any queries, please contact reddy.adalam@smarsh.com
pd=`pwd`
StartDate=`date +"%m%d%Y%H%M%S"`

#cp jmeterscripts/*.jar jmeterscripts/randomwords.txt /opt/apache-jmeter-5.1.1/lib
echo "copied required files for creating batches"
cd jmeterscripts
#---Disable all active jobs---
jmeter -n -D javax.net.ssl.keyStore=cc-stage-superuser.p12 -D javax.net.ssl.keyStorePassword=superuser -D javax.net.ssl.keyStoreType=pkcs12 -t Disablealljobs.jmx -l Disablealljobs_$StartDate.jtl
echo "disabled all jobs"

echo "`cat Disablealljobs_$StartDate.jtl`"
#---Get the count of messages before the test
#rm getdata1.txt
awk -F , '{ print $4,$7,$8}' OFS=, jobdetails.txt | sed 's/\r//g' >getdata1.txt
awk -F, '{print $3,$2,$1}' OFS=, getdata1.txt > checkcount.txt
cat attfeeds.txt >>checkcount.txt
cat checkcount.txt
