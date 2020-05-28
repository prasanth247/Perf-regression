#!/bin/bash
# For any queries, please contact reddy.adalam@smarsh.com
space="cc-staging"

if [[ $space == *"cc-dev"* ]]
then
echo "Running test on dev"
else if [[ $space == *"cc-test"* ]]
then
echo "Running test on test"
else 
echo "running test on staging"
fi
