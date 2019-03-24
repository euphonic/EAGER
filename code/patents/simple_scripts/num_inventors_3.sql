use patents_20181127;
select count(pi.inventor_id), epa.id
from eager_patent_all epa, patent_inventor pi
where epa.id = pi.patent_id
group by epa.id
INTO OUTFILE '/home/ubuntu/EAGER/data/patents/measures/inventors_3industries.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n';
