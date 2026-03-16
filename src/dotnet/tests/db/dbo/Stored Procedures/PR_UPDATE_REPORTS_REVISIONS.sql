CREATE procedure [dbo].[PR_UPDATE_REPORTS_REVISIONS] @aOnlyRevID int, @aOnlyReport int, @aMode int
as 
SET nocount on

/*
@aOnlyRevID int, @aOnlyReport int, @aMode int зарезервированы, пока не используются

create table PR_REPORTS_REVISIONS (REVID int not null, REPORTID int not null)

create clustered index IX_PR_REPORTS_REVISIONS on PR_REPORTS_REVISIONS (REVID)
*/

declare @new table (REVID int, REPORTID int primary key (REVID, REPORTID))

insert into @new (REVID , REPORTID)
select A.ID as REVID
      ,C.ID as REPORTID
from PR_REVISION A with (nolock)
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
left join PR_REPORTS C with (nolock) on C.MTID = B.TYPEID
where C.S_S = 1000075 /* Approved */
   and dbo.PR_REPORT_USING2(C.ID,B.ID,A.ID) = 1
   
delete from PR_REPORTS_REVISIONS where not exists (select B.REVID from @new B where B.REVID = PR_REPORTS_REVISIONS.REVID and B.REPORTID = PR_REPORTS_REVISIONS.REPORTID)  
   
insert into PR_REPORTS_REVISIONS (REVID, REPORTID, S_MDT)
select A.REVID, A.REPORTID, getdate() from @new A
where not exists (select B.REVID from PR_REPORTS_REVISIONS B where B.REVID = A.REVID and B.REPORTID = A.REPORTID)
   
  
SET nocount off