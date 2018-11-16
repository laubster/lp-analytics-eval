‐‐ Here are the queries that were fed to a graphing tool named
-- ubiq (including results pasted in here); I downloaded a free
-- trial of it from http://ubiq.co/ .
-- The tool has a browser interface that was easy to use; it even
-- walks you through the steps to take, so I won't duplicate
-- them here, but the steps to install/start the tool:
--     sudo curl -O http://ubiq.co/static/ubiq_linux_deb.tar.gz
--     sudo tar -pzxf ubiq_linux_deb.tar.gz
--     cd ubiq_linux_deb
--     chmod +x manage.sh
--     ./manage.sh
--
--
SELECT c.sex, AVG(a.score)
FROM   assessments a
    JOIN customers c ON (a.customer_id = c.id)
GROUP BY c.sex
;
-- +--------+--------------+
-- | sex    | AVG(a.score) |
-- +--------+--------------+
-- | Female |      50.5069 |
-- | Male   |      50.5600 |
-- +--------+--------------+
-- 2 rows in set (0.45 sec)
--
--
SELECT CASE c.has_ged WHEN 0 THEN 'Lacks GED' ELSE 'Has GED' END has_ged, AVG(a.score)
FROM   assessments a
    JOIN customers c ON (a.customer_id = c.id)
GROUP BY c.has_ged
;
-- +-----------+--------------+
-- | has_ged   | AVG(a.score) |
-- +-----------+--------------+
-- | Lacks GED |      50.5362 |
-- | Has GED   |      50.5307 |
-- +-----------+--------------+
-- 2 rows in set (0.40 sec)
--
--
-- For the assessments-by-race query below, I focus only on single-race
-- customers, because otherwise the water gets muddy really quickly. I
-- opted to distrust customers.more_than_one_race as an exercise.
--
-- STEP 2: get the races.display_name, and analyze the score
SELECT COALESCE(r.display_name, '(Unknown)') race, AVG(v.score)
     , STD(v.score)
FROM   (
    -- STEP 1: identify assessments tied to single-race customers
    SELECT a.id, a.score, cr.customer_id, MIN(cr.race_id) race_id
    FROM   assessments a
        LEFT JOIN customers_races cr ON (a.customer_id = cr.customer_id)
    GROUP BY a.id, a.score, cr.customer_id
    HAVING 1 = COUNT(*) -- could use customers.more_than_one_race instead
) v
    LEFT JOIN races r ON (v.race_id = r.id)
GROUP BY r.display_name
-- STEP 3: sort by race, ensuring unknown comes last
ORDER BY CASE WHEN r.display_name IS NULL THEN 1 ELSE 0 END, r.display_name
;
-- +-----------------+--------------+--------------------+
-- | race            | AVG(v.score) | STD(v.score)       |
-- +-----------------+--------------+--------------------+
-- | Alaskan Native  |      51.3456 |  28.22536185554637 |
-- | Asian           |      49.3601 | 29.253472959200035 |
-- | Black           |      48.9740 |  28.77466883751178 |
-- | Filipino        |      50.4362 | 29.268204861325025 |
-- | Native American |      49.8969 | 28.872838132480897 |
-- | White           |      50.9249 |  28.70217894176204 |
-- | (Unknown)       |      51.6043 | 29.058291818346124 |
-- +-----------------+--------------+--------------------+
-- 7 rows in set (0.84 sec)
