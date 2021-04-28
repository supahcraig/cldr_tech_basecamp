spark-submit --master yarn --deploy-mode cluster \
  --jars /tmp/zeppelin/hive-warehouse-connector-assembly-1.0.0.7.2.1.4-4.jar \
  --py-files /tmp/zeppelin/pyspark_hwc-1.0.0.7.2.1.4-4.zip \
  --conf spark.security.credentials.hiveserver2.enabled=false \
  --conf spark.sql.hive.hiveserver2.jdbc.url="jdbc:hive2://cnelson2-de-master0.cnelson2.a465-9q4k.cloudera.site/;ssl=true;transportMode=http;httpPath=cnelson2-de/cdp-proxy-api/hive;user=cnelson2;password=workload" \
  --conf spark.datasource.hive.warehouse.load.staging.dir=/tmp \
  --conf spark.datasource.hive.warehouse.metastoreUri=thrift://cnelson2-de-master0.cnelson2.a465-9q4k.cloudera.site:9083 \
  all_everything.py
