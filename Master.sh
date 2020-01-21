#!/bin/bash
# For any queries, please contact reddy.adalam@smarsh.com

pd=`pwd`
StartDate=`date +"%m%d%Y%H%M%S"`

wget http://apachemirror.wuchna.com//jmeter/binaries/apache-jmeter-5.2.1.zip
unzip apache-jmeter-5.2.1.zip
JMETER_HOME=${pd}/apache-jmeter-5.2.1/bin
echo `ls $JMETER_HOME`

