use patents_20181127;
select count(pa.assignee_id), pa.patent_id
from eager_patent_all epa, patent_assignee pa
where epa.id = pa.patent_id
group by pa.patent_id
INTO OUTFILE '/home/ubuntu/EAGER/data/patents/measures/assignees_3industries.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n';
