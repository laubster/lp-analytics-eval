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
where exists (
select null from vie_conform_01_hashed i where q.manual_hash = i.manual_hash_from_cq
)
order by
2,3,1
