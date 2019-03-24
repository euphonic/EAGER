use patents_20181127;
select count(pa.assignee_id), p.id
from patent p, patent_assignee pa
where p.id in
(select p.id
from patent p, patent_assignee pa, eager_assignee ea
where ea.id = pa.assignee_id
and pa.patent_id = p.id)
group by p.id
INTO OUTFILE '/home/ubuntu/EAGER/data/patents/measures/assignees_overall.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n';
