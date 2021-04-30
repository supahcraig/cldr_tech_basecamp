drop table if exists detectors.measurements_subset;
create table detectors.measurements_subset as
select * from detectors.measurements limit 1000;

alter table detectors.measurements_subset add columns (is_gravitational_wave int);

update detectors.measurements_subset
set is_gravitational_wave = (case when amplitude_1 > 0.5
                                    and amplitude_2 > 0.5
                                    and amplitude_3 > 0.5 then 1
                                  else 0
                              end)
where 1 = 1;

select count(*), nvl(is_gravitational_wave, 'total') as is_gravitational_wave
from detectors.measurements_subset
group by rollup(is_gravitational_wave)
order by 1;
