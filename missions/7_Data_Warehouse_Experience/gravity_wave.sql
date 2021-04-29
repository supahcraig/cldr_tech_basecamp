select
  a.astrophysicist_name ,
  a.year_of_birth ,
  a.nationality,
  replace(g.galaxy_name, "'", "") as galaxy_name,
  replace(g.galaxy_type, "'", "") as galaxy_type,
  g.distance_ly ,
  g.absolute_magnitude ,
  g.apparent_magnitude ,
  replace(g.galaxy_group, "'", "") as galaxy_group,
  m.measurement_id ,
  m.detector_id ,
  m.galaxy_id ,
  m.astrophysicist_id ,
  m.measurement_time ,
  m.amplitude_1 ,
  m.amplitude_2 ,
  m.amplitude_3 ,
  case when m.amplitude_1 > 0.995
        and m.amplitude_2 > 0.995
        and m.amplitude_3 < 0.005 then 1
       else 0
  end as gravitational_wave_flag,
  replace(d.detector_name, "'", "") as detector_name,
  replace(d.country, "'", "") as country,
  d.latitude ,
  d.longitude
from detectors.measurements m
   , detectors.galaxies g
   , detectors.detectors d
   , detectors.astronomers a
where 1 = 1
  and m.galaxy_id = g.galaxy_id
  and m.detector_id = cast(replace(d.detector_id, "'", "") as int)
  and m.astrophysicist_id = a.astrophysicist_id
  and 1 = 1;
