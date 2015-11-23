-- execute this session setting statement to ensure that the dynamically generated statements are not truncated
-- the full dynamic statement can only be obtained by opening the query output in the viewer (right-click, option Open Value in Viewer)
SET SESSION group_concat_max_len = 4294967295;
SET @var_source_schema = 'review_annie';
SET @var_destination_schema = 'annie';
SET @var_backup_schema = 'annie_backup';
-- execute all five of these concat statements at the same time to generate the statements for the table moves and rollbacks
-- generate statement to drop tables from annie_backup that will be moved in from annie
SELECT 'drop old backup' as useage, CONCAT('DROP TABLE IF EXISTS ', GROUP_CONCAT(@var_backup_schema, '.', a.table_name, '\r\n'), ';') as stmt
FROM information_schema.TABLES a
WHERE a.table_schema = @var_destination_schema and a.table_type = 'BASE TABLE' and (a.table_name like 'cache%' or a.table_name like 'ref_match%' or a.table_name like 'prtl%'
	or a.table_name like 'ref_lookup_census%' or a.table_name = 'ref_last_dw_transfer' or a.table_name = 'ref_lookup_max_date' or a.table_name = 'ooh_point_in_time_measures')
    and a.table_name not in ('prtl_labels', 'prtl_college_enrollment', 'prtl_dropout', 'prtl_lit3_perc', 'prtl_post_secondary_completion')
    and exists(select * from information_schema.tables r where r.table_name = a.table_name and r.table_schema = @var_source_schema and r.table_type = 'BASE TABLE')
GROUP BY a.table_schema
UNION ALL
-- generate statement to move tables into annie_backup from annie that will be replaced from review_annie
SELECT 'backup' as useage, CONCAT('RENAME TABLE ', GROUP_CONCAT(a.table_schema, '.', a.table_name, ' TO ', @var_backup_schema, '.' ,a.table_name, '\r\n'), ';') as stmt
FROM information_schema.TABLES a
WHERE a.table_schema = @var_destination_schema and a.table_type = 'BASE TABLE' and (a.table_name like 'cache%' or a.table_name like 'ref_match%' or a.table_name like 'prtl%'
	or a.table_name like 'ref_lookup_census%' or a.table_name = 'ref_last_dw_transfer' or a.table_name = 'ref_lookup_max_date' or a.table_name = 'ooh_point_in_time_measures')
    and a.table_name not in ('prtl_labels', 'prtl_college_enrollment', 'prtl_dropout', 'prtl_lit3_perc', 'prtl_post_secondary_completion')
    and exists(select * from information_schema.tables r where r.table_name = a.table_name and r.table_schema = @var_source_schema and r.table_type = 'BASE TABLE')
GROUP BY a.table_schema
UNION ALL
-- generate statement to move tables into annie from review_annie that will be moved from into annie_backup from annie
SELECT 'transfer' as useage, CONCAT('RENAME TABLE ', GROUP_CONCAT(r.table_schema, '.', r.table_name, ' TO ', @var_destination_schema, '.', r.table_name, '\r\n'), ';') as stmt
FROM information_schema.TABLES r
WHERE r.table_schema = @var_source_schema and r.table_type = 'BASE TABLE' and (r.table_name like 'cache%' or r.table_name like 'ref_match%' or r.table_name like 'prtl%'
	or r.table_name like 'ref_lookup_census%' or r.table_name = 'ref_last_dw_transfer' or r.table_name = 'ref_lookup_max_date' or r.table_name = 'ooh_point_in_time_measures')
    and r.table_name not in ('prtl_labels', 'prtl_college_enrollment', 'prtl_dropout', 'prtl_lit3_perc', 'prtl_post_secondary_completion')
    and exists(select * from information_schema.tables a where a.table_name = r.table_name and a.table_schema = @var_destination_schema and a.table_type = 'BASE TABLE')
GROUP BY r.table_schema
UNION ALL
-- generate rollback statement to move tables back into review annie that were moved to annie
SELECT 'rollback transfer' as useage, CONCAT('RENAME TABLE ', GROUP_CONCAT(a.table_schema, '.', a.table_name, ' TO ', @var_source_schema, '.', a.table_name, '\r\n'), ';') as stmt
FROM information_schema.TABLES a
WHERE a.table_schema = @var_destination_schema and a.table_type = 'BASE TABLE' and (a.table_name like 'cache%' or a.table_name like 'ref_match%' or a.table_name like 'prtl%'
	or a.table_name like 'ref_lookup_census%' or a.table_name = 'ref_last_dw_transfer' or a.table_name = 'ref_lookup_max_date' or a.table_name = 'ooh_point_in_time_measures')
    and a.table_name not in ('prtl_labels', 'prtl_college_enrollment', 'prtl_dropout', 'prtl_lit3_perc', 'prtl_post_secondary_completion')
    and exists(select * from information_schema.tables r where r.table_name = a.table_name and r.table_schema = @var_source_schema and r.table_type = 'BASE TABLE')
GROUP BY a.table_schema
UNION ALL
-- generate rollback statement to move tables back into annie that were moved to annie_backup
SELECT 'restore backup' as useage, CONCAT('RENAME TABLE ', GROUP_CONCAT(@var_backup_schema, '.', table_name, ' TO ', table_schema, '.', table_name, '\r\n'), ';') as stmt
FROM information_schema.TABLES
WHERE table_schema = @var_destination_schema and table_type = 'BASE TABLE' and (table_name like 'cache%' or table_name like 'ref_match%' or table_name like 'prtl%'
	or table_name like 'ref_lookup_census%' or table_name = 'ref_last_dw_transfer' or table_name = 'ref_lookup_max_date' or table_name = 'ooh_point_in_time_measures')
    and table_name not in ('prtl_labels', 'prtl_college_enrollment', 'prtl_dropout', 'prtl_lit3_perc', 'prtl_post_secondary_completion')
GROUP BY table_schema;
