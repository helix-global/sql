create function [dbo].[SW_GET_TOOL_FILES] (@aToolID int,@aMode int)
returns @res table (ID int)
as 
begin
/* возвращает ID записей файлов с учетом ссылок в LINKVER */

declare @vers table (VERID int, LINKVER int)


insert into @vers (VERID, LINKVER) 
select top 1 A.ID, A.LINKVER 
from SW_TOOL_VERSIONS A with (nolock)
where A.TOOLID = @aToolID
  and A.S_S = 1000061 /*approved*/
order by ID desc  


declare @i int
set @i = 1 
while @i < 10
begin

  insert into @vers (VERID, LINKVER)
  select B.ID,B.LINKVER from SW_TOOL_VERSIONS A with (nolock) 
  left join SW_TOOL_VERSIONS B with (nolock) on B.ID = A.LINKVER
  where A.ID in (select VERID from @vers)
    and A.LINKVER is not null
    and A.LINKVER not in (select VERID from @vers)
	
  if @@rowcount = 0
    break
  set @i = @i + 1
end

insert into @res (ID)
select A.ID from SW_TOOL_VER_FILES A with (nolock)
where A.VERID in (select VERID from @vers where LINKVER is null)

return

end