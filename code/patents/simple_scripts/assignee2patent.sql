use patents_20181127;
select ea.final_lookup_firm_clnd, p.id from
eager_assignee ea, patent_assignee pa, patent p
where ea.id = pa.assignee_id
and p.id = pa.patent_id
INTO OUTFILE '/home/ubuntu/EAGER/data/patents/measures/assignee-2-patent-lookup.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n';
