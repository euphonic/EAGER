select count(*) from assignee;
select count(*) from patent_inventor;
select count(*) from eager_assignee;
select count(*) from assignee_clnd;
select count(distinct(id)) from eager_patent_all; -- 12,714 total patents vs 12,417 unique ones