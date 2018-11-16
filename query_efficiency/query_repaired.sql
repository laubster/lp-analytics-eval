select
'incoming' rec_ind
,h.soft_hash
,h.hard_hash
,h.manual_hash_from_cq
from
vie_conform_01_hashed h
where
h.manual_hash_from_cq is not null
union all
select
'existing' rec_ind
,q.customer_soft_hash
,q.customer_hard_hash
,q.manual_hash
from
vie_consolidate_queue q
where
q.manual_hash in (select distinct i.manual_hash_from_cq from vie_conform_01_hashed i)
order by
2,3,1;
