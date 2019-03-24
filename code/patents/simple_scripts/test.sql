use patents_20181127;
select count(*) from eager_assignee into outfile '/home/ubuntu/EAGER/data/patents/measures/test.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n';
