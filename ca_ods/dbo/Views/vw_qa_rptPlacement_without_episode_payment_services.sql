create view dbo.vw_qa_rptPlacement_without_episode_payment_services
as
select * from base.rptPlacement rpt
where not exists (select * from base.episode_payment_services eps where eps.id_removal_episode_fact=rpt.id_removal_episode_fact)
and rpt.discharge_dt > '2000-01-01'