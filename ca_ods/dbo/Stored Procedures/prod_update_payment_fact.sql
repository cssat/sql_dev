create procedure [dbo].[prod_update_payment_fact]
as
update dbo.payment_fact
set  id_case =cd.id_case
from dbo.case_dim cd
where cd.id_case_dim=payment_fact.id_case_dim
and payment_fact.id_case_dim is not null;

