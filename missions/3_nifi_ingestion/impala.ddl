drop table if exists detectors.astronomers;
drop table if exists detectors.astronomers_new;
drop table if exists detectors.galaxies;


drop database detectors;


drop table detectors.astronomers_try;
CREATE EXTERNAL TABLE detectors.astronomers_try
(  astrophysicist_id double,
  astrophysicist_name varchar,
  year_of_birth int,
  nationality varchar)
  STORED AS PARQUET
  LOCATION 's3a://cnelson2-data/external/astronomers_try';
  
--like parquet 's3a://cnelson2-data/external/astronomers/1ab66ca7-dca1-4d88-a08f-9d0238da888e.parquet'
--64eb881d-85e4-41ce-913a-0c5b41544d0c.parquet 
--c323a87b-28b6-4a40-a7de-fc01e4c6d10d.parquet

invalidate metadata;

select * from detectors.astronomers_try order by 1;


create external table if not exists detectors.galaxies
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

select * from detectors.galaxies;
