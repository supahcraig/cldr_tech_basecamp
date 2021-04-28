# Configure spark in zeppelin

## Update the livy config for whitelist in Cloudera Manager

`Livy --> configuration --> livy-conf/livy.conf`
```
livy.file.local-dir-whitelist=/tmp/zeppelin
```

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
`livy.spark.datasource.hive.warehouse.load.staging.dir  ==> /tmp`
`livy.spark.datasource.hive.warehouse.read.jdbc.mode ==> client`
`livy.spark.datasource.hive.warehouse.read.via.llap ==> false`
`livy.spark.jars ==> file:///tmp/zeppelin/hive-warehouse-connector-assembly-1.0.0.7.2.8.0-228.jar`  (this is the path to the HWC jar you copied earlier)

#### Find the Hive2 JDBC URL
The hive2 jdbc URL is found in the Datahub console under Endpoints
`livy.spark.sql.hive.hiveserver2.jdbc.url ==> jdbc:hive2://cnelson2-datahub-master0.cnelson2.a465-9q4k.cloudera.site/;ssl=true;transportMode=http;httpPath=cnelson2-datahub/cdp-proxy-api/hive;user=<cdp username>;password=<workload password>`

#### Find the Hive Metastore URI
From Cloudera Manager, go to `Hive --> Actions --> Download client config`
Unzip the zip file and grep for the metastore URI:
```
grep -B 1 -A 2 -n 'hive.metastore.uris' hive-site.xml
```
Use that to update one more livy config:
`livy.spark.datasource.hive.warehouse.metastoreUri  ==> thrift://cnelson2-datahub-master0.cnelson2.a465-9q4k.cloudera.site:9083`
