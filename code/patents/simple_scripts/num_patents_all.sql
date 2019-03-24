use patents_20181127;
select count(p.id), ea.final_lookup_firm_clnd 
from patent p, patent_assignee pa, eager_assignee ea
where ea.id = pa.assignee_id
and pa.patent_id = p.id
group by ea.final_lookup_firm_clnd
INTO OUTFILE '/home/ubuntu/EAGER/data/patents/measures/patents_overall.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n';
