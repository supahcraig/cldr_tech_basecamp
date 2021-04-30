# Streaming Kafka/Nifi

ssh into a nifi node


```
wget https://gravity-data.s3.ca-central-1.amazonaws.com/basecamp_references/dev-basecamp/05-Fast_Data_Storage/bootcamp-0.1.0.jar

java -cp bootcamp-0.1.0.jar com.cloudera.fce.bootcamp.MeasurementGenerator cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site 29876
```
Where the port is any available port.


## ListenTCP

Defaults are fine, other than setting the port to where your data generator is running


## Kafka Producer

You'll need to use SSL:
* `Security Protocol:  SASL_SSL`
* `SASL Mechanism:  PLAIN`
* `Username: <your CDP username>`
* `Password: <your workload password>`
* `SSL Context Service:  <use default Nifi SSL Context Service`
* For best performance set `Use Transactions: false`
