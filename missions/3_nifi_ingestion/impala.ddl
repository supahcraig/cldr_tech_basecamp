
drop table if exists detectors.astronomers;
CREATE EXTERNAL TABLE detectors.astronomers
(  astrophysicist_id double,
  astrophysicist_name varchar,
  year_of_birth int,
  nationality varchar)
  STORED AS PARQUET
  LOCATION 's3a://cnelson2-data/external/astronomers';
  
--like parquet 's3a://cnelson2-data/external/astronomers/1ab66ca7-dca1-4d88-a08f-9d0238da888e.parquet'
select count(*) from detectors.astronomers;



drop table if exists detectors.galaxies;
create external table detectors.galaxies
(  galaxy_id int,
  galaxy_name varchar,
  galaxy_type varchar,
  distance_ly bigint,
  absolute_magnitude bigint,
  apparent_magnitude bigint,
  galaxy_group varchar
  )
row format delimited
fields terminated by ','
stored as textfile
location 's3a://cnelson2-data/external/galaxies';

select count(*) from detectors.galaxies;

drop table if exists detectors.sqoop_astrophysicists;
create external table detectors.sqoop_astrophysicists (
  astrophysicist_id int,
  astrophysicist_name string,
  year_of_birth int,
  nationality string
)
stored as avro
location 's3a://cnelson2-data/external/sqoop_astrophysicists';

select count(*) from detectors.sqoop_astrophysicists;



drop table if exists detectors.measurements;
create external table detectors.measurements
( measurement_id varchar,
  detector_id int,
  galaxy_id int,
  astrophysicist_id int,
  measurement_time bigint,
  amplitude_1 double,
  amplitude_2 double,
  amplitude_3 double
)
row format delimited
fields terminated by ','
stored as textfile
location 's3a://cnelson2-data/external/measurements_small';

select count(*) from detectors.measurements;



drop table if exists detectors.galaxies;
create external table detectors.galaxies (
  galaxy_id int,
  galaxy_name varchar,
  galaxy_type string,
  distance_ly double,
  absolute_magnitude double,
  apparent_magnitude double,
  galaxy_group string
)
row format delimited
fields terminated by ','
stored as textfile
location 's3a://cnelson2-data/external/galaxies'
TBLPROPERTIES ('skip.header.line.count' = '1');

select count(*) from detectors.galaxies;



drop table if exists detectors.detectors;
create external table detectors.detectors (
  detector_id string,
  detector_name varchar,
  country varchar,
  latitude double,
  longitude double
)
row format delimited
fields terminated by ','
stored as textfile
location 's3a://cnelson2-data/external/detectors'
TBLPROPERTIES ('skip.header.line.count' = '1');

select count(*) from detectors.detectors;
