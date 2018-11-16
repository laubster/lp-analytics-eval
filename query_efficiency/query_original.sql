select
'incoming' rec_ind
,soft_hash
,hard_hash
,manual_hash_from_cq
from
vie_conform_01_hashed
where
manual_hash_from_cq is not null
union all
select
'existing' rec_ind
,customer_soft_hash
,customer_hard_hash
,manual_hash
from
vie_consolidate_queue
where
manual_hash in (select distinct manual_hash from vie_conform_01_hashed)
order by
2,3,1;
