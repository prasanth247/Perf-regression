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
sed -i "s/2</$test</g" Responsetimes.jmx
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

jmeter -n -D javax.net.ssl.keyStore=cc-stage-superuser.p12 -D javax.net.ssl.keyStorePassword=superuser -D javax.net.ssl.keyStoreType=pkcs12 -t ATT_Automation.jmx -l ATTbatches_$StartDate.jtl

sleep 60
echo "collecting count and response times"

jmeter -n -D javax.net.ssl.keyStore=cc-stage-superuser.p12 -D javax.net.ssl.keyStorePassword=superuser -D javax.net.ssl.keyStoreType=pkcs12 -t Responsetimes.jmx -l responsetimes_$StartDate.jtl

echo "`cat responsetime.txt`"
teststart=`cat ATTbatches_$StartDate.jtl | grep "prtn-staging.cc.gov.smarsh.cloud" | head -1 | cut -d "," -f1`
testendtime=`cat responsetime.txt | cut -d "," -f3 | sort -n | tail -1`
testduration=$(((testendtime-teststart)/1000))
totalmessages=0
while IFS= read -r line
do
feedid=`echo "$line" | cut -d "," -f1`
finalcount=`echo "$line" | cut -d "," -f2`
init=`cat intialcount.txt |grep $feedid |cut -d "," -f2`
totalmessages=$((totalmessages+finalcount-init))
echo $feedid,$finalcount,$init >>finalresults.txt
done < responsetime.txt
throughput=$((totalmessages/testduration))
baseline=100
echo $throughput
if [ $throughput -ge $baseline ]
then
status="pass"
else
status="fail"
fi
echo $status
curl -X POST -H 'Content-type: application/json' --data '{ "text": "Performance test results summary", "blocks": [{ "type": "section", "text": { "type": "mrkdwn", "text":"Performance test results summary:'$status' \n Average throughput:'$throughput' msgs/sec \n Total messages ingested:'$totalmessages' msgs \n Test Duration: '$testduration' seconds"}}]}'  https://hooks.slack.com/services/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

echo "Slack alert sent"


sed -i "s/$test</2</g" CheckCount.jmx
sed -i "s/$test</2</g" Responsetimes.jmx

