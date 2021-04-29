from pyspark.sql import SparkSession


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