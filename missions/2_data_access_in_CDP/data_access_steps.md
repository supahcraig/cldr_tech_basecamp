# CDP Data Access Steps

*NOTE:* There were some steps around adding users & creating admin groups, syncing users, sync users to FreeIPA....I missed documenting those steps, and they absolutely were not covered in the instructions.

## sudo access
You may need to sudo to your EC2 instance, note that steps 1-3 may not be necessary
1.  ssh into the box
2.  copy pem file to box, chmod 400
3.  exit
4.  ssh into the box using cloudbreak user and your pem file
  * `ssh -i <your pem file> cloudbreak@<your host>`
5.  `sudo -i`
6.  use workload password (if necessary)

## Test Cloudera Manager UI
If CM doesn't come up, you'll need to sudo & look at logs and/or restart the CM service:

```
systemctl restart cloudera-scm-server
tail -f /var/log/cloudera-scm-server/cloudera-scm-server.log
```

## The Actual Exercise

```
hdfs dfs -ls s3a://cnelson2-data/external/

echo "hello world" > text.txt

hdfs dfs -put test.txt s3a://cnelson2-data/external/test.txt
hdfs dfs -ls s3a://cnelson2-data/external/
hdfs dfs -rm -skipTrash s3a://cnelson2-data/external/
```

You must use `-skipTrash` or else it will fail.
