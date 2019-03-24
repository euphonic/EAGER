use patents_20181127;
select count(pi.inventor_id), p.id
from patent p, patent_assignee pa, eager_assignee ea, patent_inventor pi
where ea.id = pa.assignee_id
and pa.patent_id = p.id
and p.id = pi.patent_id
group by p.id
INTO OUTFILE '/home/ubuntu/EAGER/data/patents/measures/inventors_overall.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n';
