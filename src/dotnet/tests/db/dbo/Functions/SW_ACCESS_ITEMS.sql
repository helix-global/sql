CREATE function [dbo].[SW_ACCESS_ITEMS] (@UserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID) 
select A.ID 
from SW_TOOLS A with(nolock)
where A.GROUPID in (select AA.ID from SW_ACCESS_GROUPS(@UserID,@aMode,getdate()) AA)  		

/*+KB3038 отдельные элементы по настройкам*/
insert into @res (ID) 
select distinct A.VNESHID
  from SW_TOOL_SHARING A with(nolock)
 where A.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID,@aMode,getdate())) 

/*+KB3174 отдельные элементы по настройкам*/
insert into @res (ID) 
select distinct A.VNESHID
  from SW_TOOL_SHARING_E A with(nolock)
 where A.EMPLID=dbo.DEF_EMPLOYEE(@UserID)


return

end