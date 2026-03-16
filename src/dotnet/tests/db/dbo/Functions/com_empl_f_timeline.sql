
--DECLARE @UserID int = 998 --26052
--
--DECLARE @ListBeginDate Date = '20220516'
--DECLARE @ListEndDate	   Date = '20220520'



CREATE function dbo.com_empl_f_timeline ( @UserID int, @ListBeginDate datetime, @ListEndDate datetime)

returns @res table (ID int, CAPTION nvarchar(200), IDSROWS nvarchar(max))
as 
begin


declare @groups table (ID int, NAME nvarchar(200), IDS nvarchar(max))

insert into @groups (ID, NAME)
select distinct C.ID, C.NAME
from PR_OPERATIONS_GR C with (nolock)
where C.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID, 1, getdate()))
  and exists (select B.ID 
                from PR_EMPL_TO_OPERGR B with (nolock) 
				left join COM_EMPLOYEE A with (nolock) on A.ID = B.EMPLOYEEID
               where B.GROUPID = C.ID 
			     and A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID, 1, getdate())))

update @groups set IDS = dbo.PR_EMPL_IDS_IN_GROUP_STR(ID,@ListBeginDate,@ListEndDate,0)

insert into @res
select ID
     , NAME as CAPTION
	 , IDS  as IDSROWS
	 from @groups
order by NAME	



return

end