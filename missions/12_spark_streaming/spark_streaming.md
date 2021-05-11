# Spark Streaming

## Resources Needed

* Data hub cluster with nifi
* Data Warehouse experience of DW data hub cluster


### DBConnectionPool service
* get the Database Connection URL from the Virtual DW, click on the 3 dots and "Copy JDBC URL"
* Database Driver Class Name = `com.cloudera.impala.jdbc41.Driver`
* Download the driver the same way you got the connection URL
** `jdbc:impala://coordinator-cnelson2-impala.env-6m89nj.dw.a465-9q4k.cloudera.site:443/default;AuthMech=12;transportMode=http;httpPath=cliservice;ssl=1;auth=browser`
** it will be a zip of several versions; unzip it, then unzip the one you want to get to the actual jar file
* upload jdbc driver to nifi nodes, and set permissions (777 is probably excessive)

```
scp -i ~/Downloads/cnelson2-basecamp-keypair.pem ImpalaJDBC42.jar cnelson2@cnelson2-nifi-nifi0.cnelson2.a465-9q4k.cloudera.site:/tmp/.
ssh -i ~/Downloads/cnelson2-basecamp-keypair.pem cnelson2@cnelson2-nifi-nifi0.cnelson2.a465-9q4k.cloudera.site 'chmod 777 /tmp/ImpalaJDBC42.jar'

scp -i ~/Downloads/cnelson2-basecamp-keypair.pem ImpalaJDBC42.jar cnelson2@cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site:/tmp/.
ssh -i ~/Downloads/cnelson2-basecamp-keypair.pem cnelson2@cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site 'chmod 777 /tmp/ImpalaJDBC42.jar'

scp -i ~/Downloads/cnelson2-basecamp-keypair.pem ImpalaJDBC42.jar cnelson2@cnelson2-nifi-nifi2.cnelson2.a465-9q4k.cloudera.site:/tmp/.
ssh -i ~/Downloads/cnelson2-basecamp-keypair.pem cnelson2@cnelson2-nifi-nifi2.cnelson2.a465-9q4k.cloudera.site 'chmod 777 /tmp/ImpalaJDBC42.jar'
```
* set the driver location to whereever you uploaded that file to:  `/tmp/ImpalaJDBC42.jar`
* 
