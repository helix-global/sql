CREATE function [dbo].[PR_DEVICE_REST_PROD_TIME_T] (@DeviceID int)
returns @res table (MAPOPERID int not null
                   ,OPERID int not null   
                   ,OTIME decimal (14,4)
                   ,OPAUSE decimal (14,4)
                   ,FROMBEGIN_TIME decimal (14,4)
                   ,FROMEND_TIME decimal (14,4)
                   ,CONDITION int
                   ,WILLSKIPPED int
                   ,DONE int)
as 
begin

declare @MapID int
declare @OrderID int

select @MapID = A.MAPID
      ,@OrderID = A.ORDERID
from PR_DEVICE A with (nolock)
where A.ID = @DeviceID

insert into @res (MAPOPERID,OPERID,OTIME,OPAUSE,DONE,CONDITION)
select A.ID,A.OPERID,coalesce(C.MANHOUR2,B.MANHOUR,0),0,0,isnull(A.CONDITION,0)
from PR_DEVICE D with (nolock)
left join PR_MAP_OPER A with (nolock) on A.MAPID = D.MAPID 
left join PR_REVISION R with (nolock) on R.ID = D.REVID
left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERID
left join PR_REV_OVER_MH C with (nolock) on C.OPERID = B.ID and C.REVID = R.ID
where D.ID = @DeviceID

update @res set WILLSKIPPED = 1,OTIME = 0, OPAUSE = 0 where CONDITION > 0 and dbo.PR_FLOW_OR_OPER_ALLOWED(null,OPERID,@DeviceID) = 0 

update @res set DONE = 1 where MAPOPERID in (select A.REVOPERID from PR_OPERATION A with (nolock) where A.DEVICEID = @DeviceID and A.COMPLETED_DT is not null)
update @res set DONE = 2 where MAPOPERID in (select S.REVOPERID from PR_DEVICE_SKIPPED_OP S with (nolock) where S.DEVICEID = @DeviceID and ORDERID = @OrderID)


declare @ttf table (OP_FROM int,OP_TO int,OPAUSE decimal(20,4))
insert into @ttf (OP_FROM,OP_TO,OPAUSE)
select A.OP_FROM,A.OP_TO,case when A.DELAYPARAM is not null then dbo.PR_DEVICE_PARAM_DEC(@DeviceID,A.DELAYPARAM) else 0 end 
  from PR_MAP_FLOW A with (nolock) 
 where A.MAPID = @MapID

update @res set FROMBEGIN_TIME = OTIME
where MAPOPERID in (select A.OP_TO from @ttf A where A.OP_FROM is null)
and not exists (select A.OP_TO from @ttf A where A.OP_FROM is not null and A.OP_TO = "@res".MAPOPERID)

update @res set OPAUSE = (select MAX(isnull(B.OPAUSE,0)) from @ttf B where B.OP_TO = "@res".MAPOPERID)
where MAPOPERID in (select OP_TO from @ttf)


while 1=1
begin
  
   update @res set FROMBEGIN_TIME = OTIME + OPAUSE + (select MAX(B.FROMBEGIN_TIME) from @res B where B.MAPOPERID in (select A.OP_FROM from @ttf A where A.OP_TO = "@res".MAPOPERID))
   where MAPOPERID in (select A.OP_TO from @ttf A where A.OP_FROM in (select B.MAPOPERID from @res B where B.FROMBEGIN_TIME is not null))
     and FROMBEGIN_TIME is null
     and not exists (select B.FROMBEGIN_TIME from @res B where B.MAPOPERID in (select A.OP_FROM from @ttf A where A.OP_TO = "@res".MAPOPERID) and B.FROMBEGIN_TIME is null)
     
   if @@ROWCOUNT = 0 break;
   
end

/*
update @res set FROMEND_TIME = (select MAX(B.FROMBEGIN_TIME) from @res B ) - FROMBEGIN_TIME
*/

update @res set FROMEND_TIME = OTIME
where MAPOPERID in (select A.OP_FROM from @ttf A where A.OP_TO is null)
  and not exists (select A.OP_FROM from @ttf A where A.OP_TO is not null and A.OP_FROM = "@res".MAPOPERID)

/*тупиковые ветки не закрытые в точку Finish */
update @res set FROMEND_TIME = OTIME
where MAPOPERID in (select A.OP_TO from @ttf A )
  and not exists (select A.OP_FROM from @ttf A where A.OP_FROM = "@res".MAPOPERID)

while 1=1
begin
  
   update @res set FROMEND_TIME = OTIME + OPAUSE + (select max(B.FROMEND_TIME) from @res B where B.MAPOPERID in (select A.OP_TO from @ttf A where A.OP_FROM = "@res".MAPOPERID))
   where MAPOPERID in (select A.OP_FROM from @ttf A where A.OP_TO in (select B.MAPOPERID from @res B where B.FROMEND_TIME is not null))
     and FROMEND_TIME is null
     and not exists (select B.FROMEND_TIME from @res B where B.MAPOPERID in (select A.OP_TO from @ttf A where A.OP_FROM = "@res".MAPOPERID) and B.FROMEND_TIME is null)
     
   if @@ROWCOUNT = 0 break;
   
end

return

end