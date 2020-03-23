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

#---Get the count of messages before the test
rm getdata1.txt
#awk -F , '{ print $4,$7,$8}' OFS=, jobdetails.txt | sed 's/\r//g' >getdata1.txt
#awk -F, '{print $3,$2,$1}' OFS=, getdata1.txt > checkcount.txt
cat attfeeds.txt >>checkcount.txt
rm intialcount.txt

#modify the count based on the number of feeds
test=`cat checkcount.txt | wc -l`
sed -i "s/2</$test</g" CheckCount.jmx

jmeter -n -D javax.net.ssl.keyStore=cc-stage-superuser.p12 -D javax.net.ssl.keyStorePassword=superuser -D javax.net.ssl.keyStoreType=pkcs12 -t CheckCount.jmx -l CheckCount_$StartDate.jtl  


#make test executions dynamic configurations can be used
#echo "`cat currcount.txt`"
#. ../configure/ATT.settings
#echo $ATTFeeds

cat intialcount.txt

echo "sending ATT batches"
#----Dynamically calculating the expected count based on loop count----#

attbatches=`cat ATT_Automation.jmx | grep "LoopController.loops\">" | cut -d ">" -f2 | cut -d "<" -f1`

att=`cat attfeeds.txt | wc -l`
batchcount=`echo $((attbatches*1000 / att))`
awk -v num="$batchcount" -F, '{$2=$2+num;print}'  OFS=, intialcount.txt | sed 's/\r//g' > finalcount.txt
paste -d, finalcount.txt attfeeds.txt | awk -F, '{print $1,$2,$4,$5}' OFS=, > finalcount1.txt
echo "`cat finalcount1.txt`"


sed -i "s/$test</2</g" CheckCount.jmx


