

create view [dbo].[vw_qa_ooh_point_in_time_child_parameters]
as

select ooh_point_in_time_child.bin_dep_cd [col],cd.bin_dep_desc [col_desc],count(*) [row_count],'bin_dep_cd' [col_name],ROW_NUMBER() over (order by ooh_point_in_time_child.bin_dep_cd) [sort_key]  from prtl.ooh_point_in_time_child 
join ref_filter_dependency cd on cd.bin_dep_cd=ooh_point_in_time_child.bin_dep_cd group by ooh_point_in_time_child.bin_dep_cd,cd.bin_dep_desc
union
select ooh_point_in_time_child.max_bin_los_cd [col],cd.bin_los_desc [col_desc],count(*),'max_bin_los_cd' [col_name],ROW_NUMBER() over (order by ooh_point_in_time_child.max_bin_los_cd) [sort_key]  from prtl.ooh_point_in_time_child 
join ref_filter_los cd on cd.bin_los_cd=ooh_point_in_time_child.max_bin_los_cd group by ooh_point_in_time_child.max_bin_los_cd,cd.bin_los_desc

union
select ooh_point_in_time_child.bin_placement_cd [col],cd.bin_placement_desc [col_desc],count(*),'bin_placement_cd' [col_name],ROW_NUMBER() over (order by ooh_point_in_time_child.bin_placement_cd) [sort_key]  from prtl.ooh_point_in_time_child 
join ref_filter_nbr_placement cd on cd.bin_placement_cd=ooh_point_in_time_child.bin_placement_cd group by ooh_point_in_time_child.bin_placement_cd,cd.bin_placement_desc
union
select ooh_point_in_time_child.bin_ihs_svc_cd [col],cd.bin_ihs_svc_tx [col_desc],count(*),'bin_ihs_svc_cd' [col_name],ROW_NUMBER() over (order by ooh_point_in_time_child.bin_ihs_svc_cd) [sort_key]  from prtl.ooh_point_in_time_child 
join ref_filter_ihs_services cd on cd.bin_ihs_svc_cd=ooh_point_in_time_child.bin_ihs_svc_cd group by ooh_point_in_time_child.bin_ihs_svc_cd,cd.bin_ihs_svc_tx
union
select ooh_point_in_time_child.cd_reporter_type [col],cd.tx_reporter_type [col_desc],count(*),'cd_reporter_type' [col_name],ROW_NUMBER() over (order by ooh_point_in_time_child.cd_reporter_type) [sort_key]  from prtl.ooh_point_in_time_child 
join ref_filter_reporter_type cd on cd.cd_reporter_type=ooh_point_in_time_child.cd_reporter_type group by ooh_point_in_time_child.cd_reporter_type,cd.tx_reporter_type


