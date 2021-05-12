# Spark Streaming

The instructions here are terrible because they rely on a prior exercise which doesn't exist.   So I made up my own exercise to roughly accomplish the goal using the things they said to use:
* pull data from hive/impala ==> kafka
* spark streaming job to do some stuff 
* push that result to kafka
* use nifi to read from kafka and write to s3


## Resources Needed

* Data hub cluster with nifi
* Data hub cluster with streaming 
* Data Warehouse experience or DW data hub cluster

## Configuring Nifi to read from Impala

### ExecuteSQL processor
Set up your database connection pool service (see below).
You may need to use a SQL Pre-Query, we used `select timeofday()` but it may not have been necessary.

### DBConnectionPool service
* get the Database Connection URL from the Virtual DW, click on the 3 dots and "Copy JDBC URL"
  * `jdbc:impala://coordinator-cnelson2-impala.env-6m89nj.dw.a465-9q4k.cloudera.site:443/default;AuthMech=12;transportMode=http;httpPath=cliservice;ssl=1;auth=browser`
  * NOTE the JDBC URL is wrong 
    * you'll need to point to your database (unless your tables are under default)
    * `AuthMech=3` will allow you to authenticate with Kerberos/keytab OR username/password (one or the other)
* Database Driver Class Name = `com.cloudera.impala.jdbc.Driver`
* Download the driver the same way you got the connection URL
  * it will be a zip of several versions; unzip it, then unzip the one you want to get to the actual jar file for your desired version
* upload jdbc jar to all nifi nodes, and set permissions (777 is probably excessive)

```
scp -i ~/Downloads/cnelson2-basecamp-keypair.pem ImpalaJDBC42.jar cnelson2@cnelson2-nifi-nifi0.cnelson2.a465-9q4k.cloudera.site:/tmp/.
ssh -i ~/Downloads/cnelson2-basecamp-keypair.pem cnelson2@cnelson2-nifi-nifi0.cnelson2.a465-9q4k.cloudera.site 'chmod 777 /tmp/ImpalaJDBC42.jar'

scp -i ~/Downloads/cnelson2-basecamp-keypair.pem ImpalaJDBC42.jar cnelson2@cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site:/tmp/.
ssh -i ~/Downloads/cnelson2-basecamp-keypair.pem cnelson2@cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site 'chmod 777 /tmp/ImpalaJDBC42.jar'

scp -i ~/Downloads/cnelson2-basecamp-keypair.pem ImpalaJDBC42.jar cnelson2@cnelson2-nifi-nifi2.cnelson2.a465-9q4k.cloudera.site:/tmp/.
ssh -i ~/Downloads/cnelson2-basecamp-keypair.pem cnelson2@cnelson2-nifi-nifi2.cnelson2.a465-9q4k.cloudera.site 'chmod 777 /tmp/ImpalaJDBC42.jar'
```
* set the driver location to whereever you uploaded that file to:  `/tmp/ImpalaJDBC42.jar`
* Database User = your CDP username
* Password = your workload password
* NOTE:  you could also use kerberos/keytab by following similar steps in the hbase mission


This was hard to debug, we used this link for help with the JDBC URL
https://community.cloudera.com/t5/Community-Articles/Virtual-Warehouse-Impala-CDP-Public-Cloud-AWS/ta-p/313884


### PublishKafka_2_0 processor
* Kafka brokers
 * list all your kafka brokers using port 9093 for SSL
 * `cnelson-kafka-broker1.cnelson2.a465-9q4k.cloudera.site:9093, cnelson-kafka-broker0.cnelson2.a465-9q4k.cloudera.site:9093, cnelson-kafka-broker2.cnelson2.a465-9q4k.cloudera.site:9093`
 * Security Protocol = `SASL_SSL`
 * SASL Mechanism = `PLAIN`
 * don't touch kerberos
 * Username = <your CDP username>
 * Password = <your workload password>
 * SSL Context Service = `Default Nifi SSL Context Service`
   * no additional configuration required for the SSL context service
 * Set your topic name
 * Delivery Guarantee = `Best Effort`
 * Use Transactions = `false` for best performance


cdp datahub create-aws-cluster \
--cluster-name cnelson-kafka \
--environment-name cnelson2 \
--cluster-template-name "7.2.1 - Streams Messaging Light Duty: Apache Kafka, Schema Registry, Streams Messaging Manager" \
--instance-groups nodeCount=3,instanceGroupName=broker,instanceGroupType=CORE,instanceType=m5.2xlarge,attachedVolumeConfiguration=\[\{volumeSize=1,000,volumeCount=1,volumeType=st1\}\],recoveryMode=MANUAL nodeCount=1,instanceGroupName=master,instanceGroupType=GATEWAY,instanceType=m5.2xlarge,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL \
--image id=2ad475f8-698c-490f-aa53-040117f1e98c,catalogName=cdp-default \
--datahub-database NON_HA 

