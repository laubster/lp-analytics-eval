-- Here I create some analytical data of phone rankings: is_primary ranks
-- higher than non-primaries, then Home>Mobile>Other>Work. The data gets
-- saved to a file, then loaded into a new table in an "lpa" analytical
-- database created separately.
--
-- Note that MySQL does not support using variables in views, so the logic
-- shown here can only appear in a populating query. Using triggers to
-- maintain the data (instead of reloading from scratch) would be an option.
use lp;
SELECT v3.id, v3.customer_id, v3.number, v3.is_primary, v3.type, v3.rnk
     , v3.most_preferable
FROM   (
    SELECT v2.id, v2.customer_id, v2.number, v2.is_primary, v2.type, v2.rnk
         , CASE
            WHEN @prev_customer_id = v2.customer_id THEN 0
            WHEN @prev_customer_id := v2.customer_id THEN 1
            END most_preferable
    FROM   (
        SELECT v1.id, v1.customer_id, v1.number, v1.is_primary, v1.type
             , v1.rnk1 + v1.rnk2 rnk
        FROM   (
            SELECT cp.id, cp.customer_id, cp.number, cp.is_primary
                 , cp.type
                 , CASE WHEN cp.is_primary > 0 THEN 0 ELSE 10 END rnk1
                 , CASE cp.type
                    WHEN 'Home'   THEN 1
                    WHEN 'Mobile' THEN 2
                    WHEN 'Other'  THEN 3
                    WHEN 'Work'   THEN 4
                    ELSE  5       END rnk2
            FROM   customer_phones cp


        ) v1
        ORDER BY v1.customer_id, rnk
    ) v2
) v3
INTO OUTFILE '/var/lib/mysql-files/e.csv'
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
;
use lpa;
DROP TABLE IF EXISTS `ranked_customer_voice_phones`;
CREATE TABLE `ranked_customer_voice_phones` (
  `id` int(10) unsigned NOT NULL,
  `customer_id` int(10) unsigned NOT NULL,
  `number` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `type` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rnk` tinyint(2) NOT NULL DEFAULT '0',
  `most_preferable` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ranked_customer_phones_customer_id_index` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
;
LOAD DATA INFILE '/var/lib/mysql-files/e.csv'
    INTO TABLE ranked_customer_voice_phones
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
;
