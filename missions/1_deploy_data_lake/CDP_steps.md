# Creating a CDP environment via the UI

Cheat Sheet:
https://docs.google.com/document/d/1BTTrZ7NijD-xCrlg1YYfHBDjN3KYLEKku3b3sOZ5En4/edit#


## Tagging
Everything is tagged with 

* `enddate:   05312021`
* `owner:  okta/cnelson2@cloudera.com`
* `project:   basecamp/0422/2021`

## Create 2 buckets in S3, use default permissions
* `cnelson2-data`
* `cnelson2-logs`

## References you'll use throughout the deployment
* ${LOGS_BUCKET} : `cnelson2-logs`
* ${LOGS_LOCATION_BASE} : `cnelson2-logs/log`
* ${DATALAKE_BUCKET} : `cnelson2-data`
* ${STORAGE_LOCATION_BASE} : `cnelson2-data/gravity`
* ${DYNAMODB_TABLE_NAME} : `cnelson2`
* ${AWS_ACCOUNT_ID} : `the account id of *YOUR* AWS account`
* ${IDBROKER_ROLE} : `cnelson2-idbroker-role`

## Create the IAM Roles & Policies

### &#x1F534; NOTE:  
The ranger audit role resource should not include the /ranger/audit portion of the path.  This is a mistake in the docs.
Should look like:
`"Resource": "arn:aws:s3:::cnelson2-data/gravity/*"`

The policy documents in this repository are correct for all the exercises (at least up through the first Spark exercise).  If you have trouble, check your policies against the json documents here.


# Creating the environment

* Assumer Instance Profile is the id-broker role
* Data access role is the datalake admin role

## NOTE:
choose correct region

### Networking
* create new network, use `10.10.0.0/16`
* disable private subnets
* create new security groups, use `0.0.0.0/0`
* pick your keypair
* enter your dynamodb table name (see above):  `cnelson2` _(it hasn't been created yet, but just use your username as the table name)_

### Logging
* Logger instance profile is the log-role
* s3 path is the logs location base (see above): `cnelson2-logs/log`

## How to create environment?
```
cdp environments create-aws-environment \
--environment-name cnelson2 \
--credential-name cnelson2 \
--region "us-east-2" \
--security-access cidr=0.0.0.0/0 \
--tags key=enddate,value=05312021 key=owner,value=okta/cnelson2@cloudera.com key=project,value=basecamp/04222021  \
--enable-tunnel \
--authentication publicKeyId="cnelson2-basecamp-keypair" \
--log-storage storageLocationBase=s3a://cnelson2-logs/log,instanceProfile=arn:aws:iam::665634629064:instance-profile/cnelson2-log-role \
--network-cidr 10.10.0.0/16 \
--s3-guard-table-name cnelson2 \
--free-ipa instanceCountByGroup=1 
```
This can take 15+ minutes.


## How to create id broker mappings?
```
cdp environments set-id-broker-mappings \
--environment-name cnelson2 \
--data-access-role arn:aws:iam::665634629064:role/cnelson2-datalake-admin-role \
--ranger-audit-role arn:aws:iam::665634629064:role/cnelson2-ranger-audit-role \
--set-empty-mappings 
```
This is more or less instantaneous.


## How to create data lake?
```
cdp datalake create-aws-datalake \
--datalake-name cnelson2 \
--environment-name cnelson2 \
--cloud-provider-configuration instanceProfile=arn:aws:iam::665634629064:instance-profile/cnelson2-idbroker-role,storageBucketLocation=s3a://cnelson2-data/gravity \
--tags key=enddate,value=05312021 key=owner,value=okta/cnelson2@cloudera.com key=project,value=basecamp/04222021 \
--scale LIGHT_DUTY \
--runtime 7.2.1 
```
This can take a long time.....
