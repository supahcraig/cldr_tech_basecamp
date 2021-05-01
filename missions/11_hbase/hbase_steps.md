# Operational Database

You'll also need that Nifi cluster still running, refer to Nifi missions for that setup.


## Spin up Operational Database Datahub Cluster

Use the Operational Database with SQL for AWS
```
cdp datahub create-aws-cluster \
--cluster-name cnelson2-od \
--environment-name cnelson2 \
--cluster-template-name "7.2.1 - Operational Database: Apache HBase, Phoenix" \
--instance-groups nodeCount=1,instanceGroupName=leader,instanceGroupType=CORE,instanceType=m5.2xlarge,rootVolumeSize=100,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} nodeCount=2,instanceGroupName=master,instanceGroupType=CORE,instanceType=m5.2xlarge,rootVolumeSize=100,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} nodeCount=1,instanceGroupName=gateway,instanceGroupType=GATEWAY,instanceType=m5.2xlarge,rootVolumeSize=100,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} nodeCount=3,instanceGroupName=worker,instanceGroupType=CORE,instanceType=m5.2xlarge,rootVolumeSize=100,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} \
--subnet-id subnet-0f39220bd0ce7cfaa \
--image id=2ad475f8-698c-490f-aa53-040117f1e98c,catalogName=cdp-default \
--tags key="owner",value="okta/cnelson2@cloudera.com" key="enddate",value="05312021" key="project",value="basecamp/04302021" 
```


## Download hbase conf
From Operational DB's Cloudera mnager, go Clusters --> HBase --> Actions --> Download Client Configuration

I think you can just unzip that locally and copy the hbase-site.xml & core-site.xml to the nifi nodes, but it _might_ require all those files.

Download hbase-site.xml & core-site.xml & upload to nifi cluster

```
scp -i ../cnelson2-basecamp-keypair.pem hbase-site.xml cnelson2@cnelson2-nifi-nifi0.cnelson2.a465-9q4k.cloudera.site:/tmp/hbase-site.xml
scp -i ../cnelson2-basecamp-keypair.pem hbase-site.xml cnelson2@cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site:/tmp/hbase-site.xml
scp -i ../cnelson2-basecamp-keypair.pem hbase-site.xml cnelson2@cnelson2-nifi-nifi2.cnelson2.a465-9q4k.cloudera.site:/tmp/hbase-site.xml

scp -i ../cnelson2-basecamp-keypair.pem core-site.xml cnelson2@cnelson2-nifi-nifi0.cnelson2.a465-9q4k.cloudera.site:/tmp/core-site.xml
scp -i ../cnelson2-basecamp-keypair.pem core-site.xml cnelson2@cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site:/tmp/core-site.xml
scp -i ../cnelson2-basecamp-keypair.pem core-site.xml cnelson2@cnelson2-nifi-nifi2.cnelson2.a465-9q4k.cloudera.site:/tmp/core-site.xml
```


## Configure PutHbaseCell nifi processor

* Add a PutHbaseCell procesor to the nifi canvas.
* Create a new HBase Client Service


### Hbase client service

#### Deal with Kerberos

1.  From CDP Console --> User Management, find your user
2.  Actions --> Get Keytab for your environment, and download
3.  scp that to each nifi node
```
scp -i cnelson2-basecamp-keypair.pem cnelson2-cnelson2.keytab cnelson2@cnelson2-nifi-nifi0.cnelson2.a465-9q4k.cloudera.site:/tmp/cnelson2-cnelson2.keytab`
scp -i cnelson2-basecamp-keypair.pem cnelson2-cnelson2.keytab cnelson2@cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site:/tmp/cnelson2-cnelson2.keytab`
scp -i cnelson2-basecamp-keypair.pem cnelson2-cnelson2.keytab cnelson2@cnelson2-nifi-nifi2.cnelson2.a465-9q4k.cloudera.site:/tmp/cnelson2-cnelson2.keytab`
```
4.  ssh to one of your nifi nodes
5.  cd to the directory where you put your keytab
6.  `klist -kt <your keytab>`
7.  Copy the principal from that output
 * should look like `cnelson2@CNELSON2.A465-9Q4K.CLOUDERA.SITE`

Finish setting up the HBase Client Service

* Keytab is `<path to your keytab>/your.keytab`
* Principal is what you copied from step 7
_(( things still won't work yet ))_



## Fix permissions
ssh into each nifi node and chmod 777 your hbase-site.xml, core-site.xml, and your keytab file

Protip:  do this with 3 tabs in iTerm2.


## Create the Hbase table in Hue

Go to your ODB data hub cluster, and open up the Hue UI to create a new table.


## PutHbaseCell nifi processor

* Use your Hbase Client service
* Table name you just created in Hue
* Row identifier... appears to be anything you want
* Column family you used when you created your table
* Column qualifier... appears to be anything you want
* 

## ListenTCP nifi processor
Just like the kafka exercise you'll need a listen TCP processor and to kick off the data generator jar on one of the nifi nodes:

```
wget https://gravity-data.s3.ca-central-1.amazonaws.com/basecamp_references/dev-basecamp/05-Fast_Data_Storage/bootcamp-0.1.0.jar
java -cp bootcamp-0.1.0.jar com.cloudera.fce.bootcamp.MeasurementGenerator <any nifi node hostname> <any available port>
```

## See results in Hue
