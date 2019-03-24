use patents_20181127;
select year(min(p.`date`)), ea.final_lookup_firm_clnd -- need to get year
from patent p, eager_assignee ea, patent_assignee pa
where p.id = pa.patent_id
and pa.assignee_id = ea.id
group by ea.final_lookup_firm_clnd -- could also segment by industry if needed
INTO OUTFILE '/home/ubuntu/EAGER/data/patents/measures/assignees_first-year.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n';
