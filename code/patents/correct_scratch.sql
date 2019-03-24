SELECT * FROM patents_20181127.eager_assignee;

select min(date)from patent where id in 
(select id from eager_patent_all);

select count(*) from eager_temp_assignee;
select count(*) from eager_assignee;

SELECT t1.lookup_firm
FROM eager_assignee t1
    LEFT JOIN eager_temp_assignee t2 ON t1.lookup_firm = t2.lookup_firm
WHERE t2.lookup_firm IS NULL;

# save this to a file and search below; then update assignee_clnd by hand to improve match rates :(

select * from eager_assignee where lookup_firm = 'BASF Plant Science';
select * from assignee where `organization` like 'BASF Plant Science%';

select ac.organization_clnd, count(pa.patent_id)  cpid
from assignee_clnd ac, patent_assignee pa 
where organization_clnd like 'Hewlett-Packasrd Development Comany%'
and ac.id = pa.assignee_id
group by organization_clnd
order by cpid desc;

select count(*) from patent_assignee
where assignee_id = 'org_imh45O8Eg9GmDlcsMW5G';

# Battelle Energy Alliance

SELECT ac.organization_clnd, count(pa.patent_id) cpid FROM assignee_clnd ac, patent_assignee pa WHERE organization_clnd LIKE 'ABB %' AND ac.id = pa.assignee_id GROUP BY organization_clnd ORDER BY cpid desc LIMIT 5;