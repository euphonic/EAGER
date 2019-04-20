-- count number of patents (just those falling in the three industries), group by organization 
select count(epa.id), ea.final_lookup_firm_clnd -- or number?
from eager_patent_all epa, eager_assignee ea, patent_assignee pa
where epa.id = pa.patent_id
and pa.assignee_id = ea.id
group by ea.final_lookup_firm_clnd;
 -- change table for specific industries  
 
 -- why only 998 rows? 
 
 # check how many patents don't have assignees
 select * from eager_patent_all where id not in
 (select patent_id from patent_assignee); -- 476 (checks out outline, but surprising b/c these patents are supposed to have assignees I thought)
 
 select * from eager_assignee where id not in
 (select assignee_id from patent_assignee);

select * from eager_assignee where final_lookup_firm_clnd not in (
	select distinct(ea.final_lookup_firm_clnd) -- or number?
	from eager_patent_all epa, eager_assignee ea, patent_assignee pa
	where epa.id = pa.patent_id
	and pa.assignee_id = ea.id
);

select * from assignee_clnd where organization_clnd like '3M%';
select count(patent_id) cpid, assignee_id  from patent_assignee where assignee_id in 
(select id from assignee_clnd where organization_clnd like '3M%')
group by assignee_id
order by cpid desc;


select * from assignee_clnd where organization_clnd like 'Chevron%Phillips%';
select count(patent_id) cpid, assignee_id  from patent_assignee where assignee_id in 
(select id from assignee_clnd where organization_clnd like 'Chevron%Phillips%')
group by assignee_id
order by cpid desc;
 
 
 