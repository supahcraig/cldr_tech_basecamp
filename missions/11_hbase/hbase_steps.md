# Operational Database

## Spin up Operational Database Datahub Cluster


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


## PutHbaseCell processor

### Hbase controller service

download hbase-site.xml & core-site.xml & upload to nifi cluster

```
scp -i ../cnelson2-basecamp-keypair.pem hbase-site.xml cnelson2@cnelson2-nifi-nifi0.cnelson2.a465-9q4k.cloudera.site:/tmp/hbase-site.xml
scp -i ../cnelson2-basecamp-keypair.pem hbase-site.xml cnelson2@cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site:/tmp/hbase-site.xml
scp -i ../cnelson2-basecamp-keypair.pem hbase-site.xml cnelson2@cnelson2-nifi-nifi2.cnelson2.a465-9q4k.cloudera.site:/tmp/hbase-site.xml

scp -i ../cnelson2-basecamp-keypair.pem core-site.xml cnelson2@cnelson2-nifi-nifi0.cnelson2.a465-9q4k.cloudera.site:/tmp/core-site.xml
scp -i ../cnelson2-basecamp-keypair.pem core-site.xml cnelson2@cnelson2-nifi-nifi1.cnelson2.a465-9q4k.cloudera.site:/tmp/core-site.xml
scp -i ../cnelson2-basecamp-keypair.pem core-site.xml cnelson2@cnelson2-nifi-nifi2.cnelson2.a465-9q4k.cloudera.site:/tmp/core-site.xml
```

permissions will probably be a thing.

