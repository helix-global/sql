CREATE procedure [dbo].[PR_CHECK_PDMU_DUPL] @aRevisionID int
as 
set nocount on

/*KB3450*/

declare @duplicates table (CODE nvarchar(50))

insert into @duplicates (CODE)
select B.CODE
from PR_REV_PDMU A with(nolock)
left join PR_NAV_PN_CACHE B with(nolock) on B.ID = A.MID
where A.REVID = @aRevisionID
group by B.CODE,A.OPERID,A.ONLYOPTION,A.WITHOUTOPTION
having count(*) > 1

if exists (select * from @duplicates)
begin 
          
    declare @mess nvarchar(max)
    set @mess = ''
    select @mess = @mess + case when len(@mess)>0 then ', ' else '' end + CODE  
    from (select distinct CODE from @duplicates) M
    
    set @mess = '#WThe following materials are duplicated: ' + @mess
    
    print @mess
       
end
             


set nocount off