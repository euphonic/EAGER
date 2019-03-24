use patents_20181127;
select count(epa.id), ea.final_lookup_firm_clnd -- or number?
from eager_patent_all epa, eager_assignee ea, patent_assignee pa
where epa.id = pa.patent_id
and pa.assignee_id = ea.id
group by ea.final_lookup_firm_clnd
INTO OUTFILE '/home/ubuntu/EAGER/data/patents/measures/patents_3industries.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n';
