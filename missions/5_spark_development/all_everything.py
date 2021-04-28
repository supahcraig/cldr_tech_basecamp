from pyspark.sql import SparkSession
from pyspark_llap import HiveWarehouseSession

spark = SparkSession.builder.appName('app').getOrCreate()

big_sql = '''select
  a.astrophysicist_name ,
  a.year_of_birth ,
  a.nationality,
  g.galaxy_name ,
  g.galaxy_type ,
  g.distance_ly ,
  g.absolute_magnitude ,
  g.apparent_magnitude ,
  g.galaxy_group,
  m.measurement_id ,
  m.detector_id ,
  m.galaxy_id ,
  m.astrophysicist_id ,
  m.measurement_time ,
  m.amplitude_1 ,
  m.amplitude_2 ,
  m.amplitude_3 ,
  d.detector_name ,
  d.country ,
  d.latitude ,
  d.longitude
from detectors.measurements m
   , detectors.galaxies g
   , detectors.detectors d
   , detectors.astronomers a
where 1 = 1
  and m.galaxy_id = g.galaxy_id
  and m.detector_id = cast(replace(d.detector_id, "'", "") as int)
  and m.astrophysicist_id = a.astrophysicist_id'''

all_everything = spark.sql(big_sql)

all_everything.count()
all_everything.show()

# write that result back to S3
all_everything.write.parquet("s3a://cnelson2-data/external/all_everything.parquet",mode="overwrite")

# create new external table against that S3 object
hive = HiveWarehouseSession.session(spark).build()

hive_ext_ddl = """create external table detectors.ext_all_everything (
astrophysicist_name string,
year_of_birth    int,
nationality    string,
galaxy_name    string,
galaxy_type    string,
distance_ly    double,
absolute_magnitude    double,
apparent_magnitude    double,
galaxy_group    string,
measurement_id    string,
detector_id    int,
galaxy_id    int,
astrophysicist_id    int,
measurement_time    bigint,
amplitude_1    double,
amplitude_2    double,
amplitude_3    double,
detector_name    string,
country    string,
latitude    double,
longitude    double)
stored as parquet
location 's3a://cnelson2-data/external/all_everything.parquet'"""

hive.executeUpdate(hive_ext_ddl)
