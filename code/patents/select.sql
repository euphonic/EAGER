-- first create eager patent table with just the patents I'm interested in using Sarvo's table?
-- called eager_patent_nano, eager_patent_green, eager_patent_synbio, eager_patent_all 

create table eager_patent_all as select * from  (
select * from patent p where p.id in ('a', 'b', 'c'))

create table eager_assignee as select * from (
select * from assignee a where a.organization in ('a','b','c'))

-- count number of patents (overall), group by organization in study
select count(p.id), ea.organization -- or number?
from patent p, patent_assignee pa, eager_assignee ea
where ea.id = pa.assignee_id
and pa.patent_id = p.id
group by ea.organization;

-- count number of patents (just those falling in the three industries), group by organization 
select count(epa.id), ea.organization -- or number?
from eager_patent_all epa, eager_assignee ea, patent_assignee pa
where epa.id = pa.patent_id
and pa.assignee_id = ea.id
group by ea.organization
 -- change table for specific industries 

-- count inventors (overall) group by patent 
select count(pi.iventor_id), p.id
from patent p, patent_assignee pa, eager_assignee ea, patent_inventor pi
where ea.id = pa.assignee_id
and pa.patent_id = p.id
and p.id = pi.patent_id
group by p.id;

-- count inventors (by just three industries), group by patent 
select count(pi.iventor_id), p.id
from eager_patent_all epa, patent_inventor pi
where epa.id = pi.patent_id
group by p.id;

-- count number of assignees (overall for patents assigned to an organization in this study), group by patentn (some of which may fall outside the study's scope)
select count(pa.assignee_id), p.id
from patent p, patent_assignee pa
where p.id in 
(select p.id
from patent p, patent_assignee pa, eager_assignee ea
where ea.id = pa.assignee_id
and pa.patent_id = p.id)
group by p.id

-- count number of assignees (limiting to focal patents), group by patent
select count(pa.assignee_id), p.id
from eager_patent_all epa, patent_assignee pa
where epa.id = pa.patent_id
group by p.id

-- employee data come from LinkedIn

-- first year of patent for assignees in study
select min(p.`date`), ea.organization -- need to get year
from patent p, eager_assignee ea, patent_assignee pa
where p.id = pa.patent_id
and pa.assignee_id = ea.id
group by ea.organization -- could also segment by industry if needed



-- citations
/*For each patent, create the 5 year citation counts and weighted citation counts
Uses only the government relationships in the government interest table (not government assignees)
Does not require any other new tables to be pre-generated
 */
 
-- --------------------------------------------------------------------------------
-- All Patents
-- --------------------------------------------------------------------------------
 
 -- table with all patents and any citations within 5 years
-- table has the id and date of both cited and citing patent ids


-- sarora@air.org modified code originally authored by skelley@air.org
-- march 5, 2018

-- table with each government interest patent and any citations within 5 years -- for each year 1 thru 5 (changed by ska)
-- patent_20171226.eager_updated_gi is the table with all the government interest and government assignee patents
drop table patent_20171226.eager_5yr_citations_by_cite_yr5;
create table patent_20171226.eager_5yr_citations_by_cite_yr5 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20171226.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*5 and datediff(c.citing_patent_date, c.cited_patent_date) > 365*4;

-- derivative table with citation counts and weighted citation count
a
drop table patent_20171226.eager_5yr_citations_yr5;
create table patent_20171226.eager_5yr_citations_yr5 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_5, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20171226.eager_5yr_citations_by_cite_yr5 group by cited_patent_id;


drop table patent_20171226.eager_5yr_citations_by_cite_yr4;
create table patent_20171226.eager_5yr_citations_by_cite_yr4 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20171226.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*4 and datediff(c.citing_patent_date, c.cited_patent_date) > 365*3;

drop table patent_20171226.eager_5yr_citations_yr4;
create table patent_20171226.eager_5yr_citations_yr4 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_4, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20171226.eager_5yr_citations_by_cite_yr4 group by cited_patent_id;

drop table patent_20171226.eager_5yr_citations_by_cite_yr3;
create table patent_20171226.eager_5yr_citations_by_cite_yr3 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20171226.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*3 and datediff(c.citing_patent_date, c.cited_patent_date) > 365*2;


drop table patent_20171226.eager_5yr_citations_yr3;
create table patent_20171226.eager_5yr_citations_yr3 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_3, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20171226.eager_5yr_citations_by_cite_yr3 group by cited_patent_id;

drop table patent_20171226.eager_5yr_citations_by_cite_yr2;
create table patent_20171226.eager_5yr_citations_by_cite_yr2 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20171226.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*2 and datediff(c.citing_patent_date, c.cited_patent_date) > 365*1;


drop table patent_20171226.eager_5yr_citations_yr2;
create table patent_20171226.eager_5yr_citations_yr2 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_2, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20171226.eager_5yr_citations_by_cite_yr2 group by cited_patent_id;


drop table patent_20171226.eager_5yr_citations_by_cite_yr1;
create table patent_20171226.eager_5yr_citations_by_cite_yr1 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20171226.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*1;

drop table patent_20171226.eager_5yr_citations_yr1;
create table patent_20171226.eager_5yr_citations_yr1 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_1, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20171226.eager_5yr_citations_by_cite_yr1 group by cited_patent_id;

select * from patent_20171226.eager_5yr_citations_yr1;

select * from patent_20171226.eager_5yr_citations_yr2;

select * from patent_20171226.eager_5yr_citations_yr3;

select * from patent_20171226.eager_5yr_citations_yr4;

select * from patent_20171226.eager_5yr_citations_yr5;


select count(distinct(patent_id)) from patent_20171226.government_interest;

select patent_id from patent_20171226.government_interest where patent_id 
not in (select distinct(patent_id) from patent_20171226.patent_inventor); 
