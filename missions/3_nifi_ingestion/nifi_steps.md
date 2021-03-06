# Nifi Ingestion

## Stand up a data hub cluster with Nifi using Flow Management Light Duty.

### Build a nifi cluster:

```
cdp datahub create-aws-cluster \
--cluster-name cnelson2-nifi \
--environment-name cnelson2 \
--cluster-template-name "7.2.1 - Flow Management Light Duty with Apache NiFi, Apache NiFi Registry" \
--instance-groups nodeCount=3,instanceGroupName=nifi,instanceGroupType=CORE,instanceType=m5.2xlarge,rootVolumeSize=150,attachedVolumeConfiguration=\[\{volumeSize=500,volumeCount=4,volumeType=standard\}\],recoveryMode=MANUAL nodeCount=1,instanceGroupName=gateway,instanceGroupType=GATEWAY,instanceType=m5.2xlarge,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL \
--image id=2ad475f8-698c-490f-aa53-040117f1e98c,catalogName=cdp-default \
--tags key=owner,value=okta/cnelson2@cloudera.com key=enddate,value=05312021 key=project,value=basecamp/04262021 
```



### Hue/Impala cluster:
You'll also "need" another data hub to use hive or impala (I chose impala) to create external tables to inspect the data in Hue

```
cdp datahub create-aws-cluster \
--cluster-name cnelson2-impala \
--environment-name cnelson2 \
--cluster-template-name "7.2.1 - Data Mart: Apache Impala, Hue" \
--instance-groups nodeCount=1,instanceGroupName=master,instanceGroupType=GATEWAY,instanceType=r5.4xlarge,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} nodeCount=1,instanceGroupName=coordinator,instanceGroupType=CORE,instanceType=r5d.4xlarge,attachedVolumeConfiguration=\[\{volumeSize=300,volumeCount=2,volumeType=ephemeral\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} nodeCount=2,instanceGroupName=executor,instanceGroupType=CORE,instanceType=r5d.4xlarge,attachedVolumeConfiguration=\[\{volumeSize=300,volumeCount=2,volumeType=ephemeral\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} \
--image id=2ad475f8-698c-490f-aa53-040117f1e98c,catalogName=cdp-default \
--tags key=owenr,value=okta/cnelson2@cloudera.com key=project,value=basecamp/04262021 key=enddate,value=05312021 
```

## The Actual Exercise
The instructions here are terrible, here are the corrections & other info

### Sources:

#### S3
You won't have access to this bucket, so you'll have to wget all the individual files onto a folder on your nifi nodes.   

You'll probably have to put these files on each node.  I made a directory called `/tmp/data` and gave it 777 permissions.

The ListFiles processor will not validate if the folder structure isn't present on all nifi nodes.

```
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000000_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000001_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000002_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000003_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000004_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000005_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000006_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000007_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000008_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000009_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000010_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000011_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000012_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000013_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000014_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000015_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000016_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000017_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000018_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000019_0
wget https://gravity-data.s3.ca-central-1.amazonaws.com/measurements/000020_0
```

Pro Tip:  Nifi keeps track of the files it has processed, so if you need to reprocess them you will have to `touch *` to re-trigger the processing.


#### HDFS
You won't be able to HDFS to these files, you'll have to use InvokeHTTP in nifi with OPEN operation & psuedo authentication.

It should look like this in the request URL, just substitute your username:

```
http://ec2-3-239-11-101.compute-1.amazonaws.com:14000/webhdfs/v1/user/gravity/galaxies.csv?op=open&user.name=cnelson2
```

How anyone was supposed to figure out to use the _open_ operation on their own is beyond me.


#### RDBMS
You'll have to download the mysql jdbc jar onto each of the nifi nodes.   There may be a way to do this from the UI, I did it from the command line.

I unzipped the zip & copied the jar into /tmp and (I think) gave it 777 permissions.  The DBMS connection pool serivce in nifi won't enable until it is on all 3(?) nodes.

In the controller service use this:
```
connection URL:  jdbc:mysql://ec2-3-239-11-101.compute-1.amazonaws.com:3306/gravity
driver location:  file:///tmp/mysql-connector-java-8.0.24.jar
driver class name:  com.mysql.jdbc.Driver
```

Make sure you only execute on the primary node or else the SQL will run 3 times and you have duped up data.

#### Text File on FTP
you actually need to use SFTP, and the files are located in the /ftp folder, so use `ftp` as the directory in your sftp processors.
