# Create a Data Engineering Data Hub Cluster
You can use the same one you created in the sqoop mission or build a new one.

The `all_everything.json` is a Zeppelin notebook which includes markdown of how to configure the livy interpreter to use the hive warehouse connector.


cdp datahub create-aws-cluster \
--cluster-name cnelson-de-datahub \
--environment-name cnelson2 \
--cluster-template-name "7.2.1 - Data Engineering: Apache Spark, Apache Hive, Apache Oozie" \
--instance-groups nodeCount=3,instanceGroupName=worker,instanceGroupType=CORE,instanceType=m5.2xlarge,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} nodeCount=1,instanceGroupName=master,instanceGroupType=GATEWAY,instanceType=m5.2xlarge,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} nodeCount=1,instanceGroupName=compute,instanceGroupType=CORE,instanceType=m5.2xlarge,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} nodeCount=0,instanceGroupName=gateway,instanceGroupType=CORE,instanceType=m5.2xlarge,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL,volumeEncryption=\{enableEncryption=false\} \
--image id=2ad475f8-698c-490f-aa53-040117f1e98c,catalogName=cdp-default \
--tags key="owner",value="okta/cnelson2@cloudera.com" 
...although this CLI command is slightly wrong, "rootVolumeSize" is required, working with the CLI team to figure out what the command needs to look like.


# Configure the Hive Warehouse Connector

This is how you get spark in zeppelin to talk to the hive warehouse, maybe other things as well?

This link was supplied by the basecamp documentation, but these instructions are from prior work done in making Zeppelin talk to hive.  This link was, however, vital in getting the spark-submit parameters correct for execution outside of Zeppelin.
https://community.cloudera.com/t5/Community-Articles/Integrating-Apache-Hive-with-Apache-Spark-Hive-Warehouse/ta-p/249035


## Update the livy config for whitelist in Cloudera Manager

`Livy --> configuration --> livy-conf/livy.conf`
```
livy.file.local-dir-whitelist=/tmp/zeppelin
```
Then restart Livy services from Cloudera Manager.

## Copy the Hive Warehouse Connector to the Whitelist Directory
Find the hostname where livy is installed `Cloudera Manager --> Livy --> Instances`

ssh into that host:  `<user>@<host> -i <your pemfile>`
The password is your workload password.

### Find the hive warehouse connector jar:
```
find / -name *hive-warehouse-connector* 2>/dev/null
```
### Create the whitelist directory
```
mkdir /tmp/zeppelin
cd /tmp
chmod 777 zeppelin
```

### Copy the jar into the whitelist directory, change the permisions
```
cd /tmp/zeppelin
chmod 777 *.jar
```
## Configure the Zeppelin interpreter
* `livy.spark.datasource.hive.warehouse.load.staging.dir`  ==> `/tmp`
* `livy.spark.datasource.hive.warehouse.read.jdbc.mode` ==> `client`
* `livy.spark.datasource.hive.warehouse.read.via.llap` ==> `false`
* `livy.spark.jars` ==> `file:///tmp/zeppelin/hive-warehouse-connector-assembly-1.0.0.7.2.8.0-228.jar`  (this is the path to the HWC jar you copied earlier)

#### Find the Hive2 JDBC URL
The hive2 jdbc URL is found in the Datahub console under Endpoints
`livy.spark.sql.hive.hiveserver2.jdbc.url ==> jdbc:hive2://cnelson2-datahub-master0.cnelson2.a465-9q4k.cloudera.site/;ssl=true;transportMode=http;httpPath=cnelson2-datahub/cdp-proxy-api/hive;user=<cdp username>;password=<workload password>`

#### Find the Hive Metastore URI
* From Cloudera Manager, go to `Hive --> Actions --> Download client config`
* Unzip the zip file and grep for the metastore URI:
```
grep -B 1 -A 2 -n 'hive.metastore.uris' hive-site.xml
```
* Use that to update one more livy config:
`livy.spark.datasource.hive.warehouse.metastoreUri  ==> thrift://cnelson2-datahub-master0.cnelson2.a465-9q4k.cloudera.site:9083`


## Take the result and create an external table against that S3 result
This requires one more livy config:
### Find the pyspark hwc zip:
```
find / -name *pyspark_hwc* 2>/dev/null
```
Copy that to `/tmp/zeppelin` 
```
cd /tmp/zeppelin
chmod 777 *pyspark_hwc*.zip
```

Now add another entry to the interpreter config:
`livy.spark.submit.pyFiles  ==>  file:///tmp/zeppelin/pyspark_hwc-1.0.0.7.2.1.4-4.zip` where the zip file is the file you just found
