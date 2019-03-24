-- simple_measures.sql 
-- This script creates simple patent-based measures for the firms in the study 

-- First: create eager_patent_all and eager_assignee through excel 
-- load into  RDBMS thru an import script, e.g., python (don't use workbench wizard) 

-- Second: may need to clean up assignee organization names in assignee table; created assignee_clnd to do that

-- Third: add assignee_id to eager_assignee 

create table eager_temp_assignee
as 
select distinct(final_lookup_firm_clnd), min(id) cid 
	from 
		(select ea.firm, ea.final_lookup_firm_clnd, ac.id
		from eager_assignee ea 
		inner join assignee_clnd ac on ea.final_lookup_firm_clnd = ac.organization_clnd -- returns 2,282
		) as temp1 
group by temp1.final_lookup_firm_clnd;

ALTER TABLE
 eager_assignee
ADD COLUMN `id` VARCHAR(36) NULL AFTER `size_state`,
ADD INDEX `IDX_assignee` (`id` ASC);

select count(*) from eager_assignee; -- returns 1,487

SET SQL_SAFE_UPDATES = 0;
update eager_assignee 
set eager_assignee.id = 
	(select eager_temp_assignee.cid 
    from eager_temp_assignee
    where eager_temp_assignee.final_lookup_firm_clnd = eager_assignee.final_lookup_firm_clnd
    )
;
SET SQL_SAFE_UPDATES = 1;

select * from eager_assignee where id is null;

-- FOURTH: produce measures (remove count and group by to produce output files)
-- count number of patents (overall), group by organization in study
select count(p.id), ea.final_lookup_firm_clnd -- or number?
from patent p, patent_assignee pa, eager_assignee ea
where ea.id = pa.assignee_id
and pa.patent_id = p.id
group by ea.final_lookup_firm_clnd;

-- count number of patents (just those falling in the three industries), group by organization 
select count(epa.id), ea.final_lookup_firm_clnd -- or number?
from eager_patent_all epa, eager_assignee ea, patent_assignee pa
where epa.id = pa.patent_id
and pa.assignee_id = ea.id
group by ea.final_lookup_firm_clnd;
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

-- count number of assignees (overall for patents assigned to an organization in this study), group by patent (some of which may fall outside the study's scope)
select count(pa.assignee_id), p.id
from patent p, patent_assignee pa
where p.id in 
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
select year(min(p.`date`)), ea.final_lookup_firm_clnd -- need to get year
from patent p, eager_assignee ea, patent_assignee pa
where p.id = pa.patent_id
and pa.assignee_id = ea.id
group by ea.final_lookup_firm_clnd; -- could also segment by industry if needed


-- FIFTH: export patent and assignee numbers (all)
select ea.final_lookup_firm_clnd, p.id from 
eager_assignee ea, patent_assignee pa, patent p
where ea.id = pa.assignee_id
and p.id = pa.patent_id;

select distinct(year(`date`)) from patent 
where id in (select id from eager_patent_all);

select * from eager_patent_all;

-- SIXTH:
/*For each patent, create the 5 year citation counts and weighted citation counts
Does not require any other new tables to be pre-generated
 */
 

-- table with all patents and any citations within 5 years
-- table has the id and date of both cited and citing patent ids
drop table patent_20180528_restored.eager_5yr_citations_by_cite;
create table patent_20180528_restored.eager_5yr_citations_by_cite as 
select * from (
select b.cited_patent_id, p2.date as cited_patent_date, b.citing_patent_id,b.citing_patent_date, b.num_times_cited_by_us_patents from (
select a.cited_patent_id, a.citing_patent_id, p.date as citing_patent_date, p.num_times_cited_by_us_patents from (
select * from PatentsView_20180528.uspatentcitation  where cited_patent_id in 
(select distinct(id) from patent_20180528_restored.eager_patent_all)) as a
left join PatentsView_20180528.patent p on a.citing_patent_id = p.patent_id) as b
left join PatentsView_20180528.patent p2 on b.cited_patent_id = p2.patent_id) as c
where datediff(c.citing_patent_date, c.cited_patent_date) <=365*5;

-- derivative table with citation counts and weighted citation count
drop table patent_20180528_restored.eager_5yr_citations;
create table patent_20180528_restored.eager_5yr_citations as
select cited_patent_id as patent_id, count(citing_patent_id) as num_citations, sum(num_times_cited_by_us_patents) as weighted_cites_5yrs from 
patent_20180528_restored.eager_5yr_citations_by_cite group by cited_patent_id;

select * from patent_20180528_restored.eager_5yr_citations_by_cite;
select * from patent_20180528_restored.eager_5yr_citations;
