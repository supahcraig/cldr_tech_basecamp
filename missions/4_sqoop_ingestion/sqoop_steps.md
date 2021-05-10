# Ingesting data with sqoop

## Create a Data Engineering environment
I did it with an experience, but a data hub cluster would also work.  There is no "show CLI" feature for Data Engineering experience.


## Create the destination table in Hive

```
create external table detectors.sqoop_astrophysicists (
  astrophysicist_id int,
  astrophysicist_name string,
  year_of_birth int,
  nationality string
)
stored as avro
location 's3a://cnelson2-data/external/sqoop_astrophysicists';
```

## Upload the mysql connector jar
```
scp -i ../cnelson2-basecamp-keypair.pem mysql-connector-java-8.0.24.jar cnelson2@cnelson2-de-master0.cnelson2.a465-9q4k.cloudera.site:mysql-connector-java-8.0.24.jar

ssh -i cnelson2-basecamp-keypair.pem cnelson2@cnelson2-de-master0.cnelson2.a465-9q4k.cloudera.site
```


## Run sqoop

I used this link to solve the could not load jdbc issue:  https://stackoverflow.com/questions/22741183/sqoop-could-not-load-mysql-driver-exception
Possilby if the jar were in /var/lib/sqoop it would've worked without this export.

```
export HADOOP_CLASSPATH=/home/cnelson2/mysql-connector-java-8.0.24.jar

sqoop import --connect jdbc:mysql://ec2-3-239-11-101.compute-1.amazonaws.com:3306/gravity --username gravity --password SuperSecurePassword --table astrophysicists --target-dir s3a://cnelson2-data/external/sqoop_astrophysicists --as-avrodatafile -m 1
```

