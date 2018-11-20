-- simple_measures.sql 
-- This script creates simple patent-based measures for the firms in the study 

-- First: create eager_patent_all and eager_assignee through excel 
-- load into  RDBMS thru an import script, e.g., python (don't use workbench wizard) 

-- Second: may need to clean up assignee organization names in assignee table; created assignee_clnd to do that

-- Third: add assignee_id to eager_assignee 

create table eager_temp_assignee
as 
select distinct(organization_clnd), min(id) cid 
	from 
		(select ea.organization, ea.organization_clnd, ac.id
		from eager_assignee ea 
		inner join assignee_clnd ac on ea.organization_clnd = ac.organization_clnd -- returns 2,282
		) as temp1 
group by temp1.organization_clnd;

ALTER TABLE
 `patent_20180528_restored`.`eager_assignee` 
ADD COLUMN `id` VARCHAR(36) NULL AFTER `employees`,
ADD INDEX `id` (`index` ASC);

select count(*) from eager_assignee; -- returns 1,788

SET SQL_SAFE_UPDATES = 0;
update eager_assignee 
set eager_assignee.id = 
	(select eager_temp_assignee.cid 
    from eager_temp_assignee
    where eager_temp_assignee.organization_clnd = eager_assignee.organization_clnd
    )
;
SET SQL_SAFE_UPDATES = 1;

select * from eager_assignee where id is null;

-- FOURTH: produce measures
-- count number of patents (overall), group by organization in study
select count(p.id), ea.organization_clnd -- or number?
from patent p, temp_patent_assignee_backup pa, eager_assignee ea
where ea.id = pa.assignee_id
and pa.patent_id = p.id
group by ea.organization_clnd;

-- count number of patents (just those falling in the three industries), group by organization 
select count(epa.id), ea.organization_clnd -- or number?
from eager_patent_all epa, eager_assignee ea, patent_assignee pa
where epa.id = pa.patent_id
and pa.assignee_id = ea.id
group by ea.organization_clnd;
 -- change table for specific industries 

-- count inventors (overall) group by patent 
select count(pi.inventor_id), p.id
from patent p, patent_assignee pa, eager_assignee ea, patent_inventor pi
where ea.id = pa.assignee_id
and pa.patent_id = p.id
and p.id = pi.patent_id
group by p.id;

-- count inventors (by just three industries), group by patent 
select count(pi.inventor_id), epa.id
from eager_patent_all epa, patent_inventor pi
where epa.id = pi.patent_id
group by epa.id;

-- count number of assignees (overall for patents assigned to an organization in this study), group by patentn (some of which may fall outside the study's scope)
select count(pa.assignee_id), pa.patent_id
	(select p.id
	from patent p, patent_assignee pa, eager_assignee ea
	where ea.id = pa.assignee_id
	and pa.patent_id = p.id)
group by p.id;

-- count number of assignees (limiting to focal patents), group by patent
select count(pa.assignee_id), pa.patent_id
from eager_patent_all epa, patent_assignee pa
where epa.id = pa.patent_id
group by pa.patent_id;

-- employee data come from LinkedIn

-- first year of patent for assignees in study
select year(min(p.`date`)), ea.organization -- need to get year
from patent p, eager_assignee ea, patent_assignee pa
where p.id = pa.patent_id
and pa.assignee_id = ea.id
group by ea.organization; -- could also segment by industry if needed


-- FIFTH: export patent and assignee numbers
select ea.organization_clnd, p.id from 
eager_assignee ea, patent_assignee pa, patent p
where ea.id = pa.assignee_id
and p.id = pa.patent_id;

-- FIFTH: not written yet
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
-- patent_20180528_restored.eager_updated_gi is the table with all the government interest and government assignee patents
drop table patent_20180528_restored.eager_5yr_citations_by_cite_yr5;
create table patent_20180528_restored.eager_5yr_citations_by_cite_yr5 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20180528_restored.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*5 and datediff(c.citing_patent_date, c.cited_patent_date) > 365*4;

-- derivative table with citation counts and weighted citation count
a
drop table patent_20180528_restored.eager_5yr_citations_yr5;
create table patent_20180528_restored.eager_5yr_citations_yr5 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_5, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20180528_restored.eager_5yr_citations_by_cite_yr5 group by cited_patent_id;


drop table patent_20180528_restored.eager_5yr_citations_by_cite_yr4;
create table patent_20180528_restored.eager_5yr_citations_by_cite_yr4 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20180528_restored.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*4 and datediff(c.citing_patent_date, c.cited_patent_date) > 365*3;

drop table patent_20180528_restored.eager_5yr_citations_yr4;
create table patent_20180528_restored.eager_5yr_citations_yr4 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_4, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20180528_restored.eager_5yr_citations_by_cite_yr4 group by cited_patent_id;

drop table patent_20180528_restored.eager_5yr_citations_by_cite_yr3;
create table patent_20180528_restored.eager_5yr_citations_by_cite_yr3 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20180528_restored.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*3 and datediff(c.citing_patent_date, c.cited_patent_date) > 365*2;


drop table patent_20180528_restored.eager_5yr_citations_yr3;
create table patent_20180528_restored.eager_5yr_citations_yr3 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_3, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20180528_restored.eager_5yr_citations_by_cite_yr3 group by cited_patent_id;

drop table patent_20180528_restored.eager_5yr_citations_by_cite_yr2;
create table patent_20180528_restored.eager_5yr_citations_by_cite_yr2 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20180528_restored.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*2 and datediff(c.citing_patent_date, c.cited_patent_date) > 365*1;


drop table patent_20180528_restored.eager_5yr_citations_yr2;
create table patent_20180528_restored.eager_5yr_citations_yr2 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_2, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20180528_restored.eager_5yr_citations_by_cite_yr2 group by cited_patent_id;


drop table patent_20180528_restored.eager_5yr_citations_by_cite_yr1;
create table patent_20180528_restored.eager_5yr_citations_by_cite_yr1 as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20170808.uspatentcitation  where cited_patent_id in 
(select distinct(patent_id) from patent_20180528_restored.eager_patent_all)) as a
left join PatentsView_20170808.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20170808.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*1;

drop table patent_20180528_restored.eager_5yr_citations_yr1;
create table patent_20180528_restored.eager_5yr_citations_yr1 as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations_1, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20180528_restored.eager_5yr_citations_by_cite_yr1 group by cited_patent_id;

select * from patent_20180528_restored.eager_5yr_citations_yr1;

select * from patent_20180528_restored.eager_5yr_citations_yr2;

select * from patent_20180528_restored.eager_5yr_citations_yr3;

select * from patent_20180528_restored.eager_5yr_citations_yr4;

select * from patent_20180528_restored.eager_5yr_citations_yr5;


select count(distinct(patent_id)) from patent_20180528_restored.government_interest;

select patent_id from patent_20180528_restored.government_interest where patent_id 
not in (select distinct(patent_id) from patent_20180528_restored.patent_inventor); 
