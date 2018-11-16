I'd want to consult with the query author to understand the intent, since the query seems to have some inconsistency. ("With the 'manual_hash in' test, do you really mean to return all existing rows, but only when there's a single inbound row?") But, plunging ahead...

It looks like you've got a staging table (vie_conform_01_hashed) and a target table (vie_consolidate_queue). I'm guessing the intent is to run this query after some minimal processing has occurred to populate manual_hash_from_cq in the staging table with corresponding manual_hash from the target, and then the query will show incoming vs. existing hashes so a mismatch can be visually identified.

None of the sample data has values in vie_conform_01_hashed.manual_hash_from_cq, so returned results will be pretty boring here.

The cost at this point is 9.01; see metrics_as_is.png.

The first problem I see is with the "where manual_hash in (select distinct ...)". The subquery is nearly a "no-op" since it refers to a column from the outer query, which is very likely unintended - the inner query is probably meant to refer to manual_hash_from_cq. (Once that change is made, then the query returns nothing because of the NULLs in the sample data.)

The cost has balloned to 27.08; see repaired.png.

(Side note: if for some reason that "IN" were intended to be "NOT IN", then you'd need to watch out for the inner query returning a NULL, since that would cause the test to always return false.)

An "IN"/"NOT IN" test is often better handled with either "EXISTS"/"NOT EXISTS" or a join/anti-join. The EXISTS version of the query (see exists.sql) looks to do better than the original, but due to lack of indexes, the JOIN version doesn't help. Data volume & frequency of writes would be factors when considering whether to pursue an index.

The EXISTS version drops the cost to 6.00; see exists.png.

As for identifying performance problems in a MySQL instance, I'd be sure to start digging in on some MySQL education (reading, maybe training). But right off I'd poke around the "Performance Reports" offered by MySQL Workbench.
