CREATE procedure [dbo].[PR_UPDATE_REPORTS] @aOnlyRevID int, @aOnlyReport int, @aMode int
as 
SET nocount on

/*
@aOnlyRevID int, @aOnlyReport int, @aMode int зарезервированы, пока не используются
*/


declare @new table (REVID int, CRC int, CMPL nvarchar(max), NOCMPL nvarchar(max) primary key (REVID, CRC))
insert into @new (REVID, CRC, CMPL , NOCMPL)
select REVID, checksum(CMPL, NOCMPL) as CRC, CMPL, NOCMPL
from (
select A.ID as REVID
      ,dbo.PR_DEVICE_ADDEDREPORTS(0,1,A.ID,A.MODELID,B.TYPEID) as CMPL
      ,dbo.PR_DEVICE_ADDEDREPORTS(0,null,A.ID,A.MODELID,B.TYPEID) as NOCMPL
from PR_REVISION A with (nolock)
left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
) M
where CMPL is not null or NOCMPL is not null

delete from PR_REPORTS_2DEVICE where not exists (select B.REVID from @new B where B.REVID = PR_REPORTS_2DEVICE.REVID and B.CRC = PR_REPORTS_2DEVICE.CRC)

insert into PR_REPORTS_2DEVICE (REVID, CRC, CMPL , NOCMPL, S_MDT)
select A.REVID, A.CRC, A.CMPL , A.NOCMPL, getdate() from @new A
where not exists (select B.REVID from PR_REPORTS_2DEVICE B where B.REVID = A.REVID)
  
SET nocount off