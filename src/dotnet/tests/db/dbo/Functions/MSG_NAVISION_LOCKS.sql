CREATE function [dbo].[MSG_NAVISION_LOCKS] (@dtBeg datetime, @dtEnd datetime)
returns @res table (ID int, CAPTION nvarchar(max), USERID int, DD datetime, OPERID int, OPERCLOSED datetime, ADDINFO nvarchar(max))
as 
begin
/*
insert into @res (ID, CAPTION, USERID, DD, OPERID, ADDINFO)
select A.ID, A.CAPTION, A.S_USERID, A.DD, case when A.DOCOID = 1000039 /*pr.oper*/ and A.DOCID > 0 then A.DOCID else null end
      , cast(A.ADDINFO as nvarchar(max))
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100,1000)
  and A.CAPTION like '%locked%'
  and A.EV_TEXT like '%Navision%'
  */
  
declare @locationCode nvarchar(200) = dbo.DEF_SYS_CONST_STR('com_remotelocation_code',null)  

insert into @res (ID, CAPTION, USERID, DD, OPERID, ADDINFO)
select A.ID, cast(A.EV_TEXT as nvarchar(max)), A.S_USERID, A.DD, case when A.DOCOID = 1000039 /*pr.oper*/ and A.DOCID > 0 then A.DOCID else null end
     , cast(A.ADDINFO as nvarchar(max))
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100,1000)
  and A.EV_TYPE in (89012,65656,65657,50021/*добавлена для IPM*/) /*doc.method,SilentIstMeldund.., onetransactionerr*/
  and (A.EV_TEXT like '%locked%' or A.EV_TEXT like '%deadlocked%' /*or A.EV_TEXT like '%Ledger%'*/ or A.EV_TEXT like '%заблокирован%' )
 /* and A.ADDINFO is not null*/
  and not exists (select J.ID from @res J where J.ID = A.ID)
  and not (@locationCode = 'IPGL' and A.CAPTION like '%stmeldung%' and A.EV_TYPE in (65656,65657)) /*по таким есть отдельные NAV Lock 86424*/

insert into @res (ID, CAPTION, USERID, DD, OPERID, ADDINFO)
select A.ID, cast(A.EV_TEXT as nvarchar(max)), A.S_USERID, A.DD, case when A.DOCOID = 1000039 /*pr.oper*/ and A.DOCID > 0 then A.DOCID else null end
     , cast(A.ADDINFO as nvarchar(max))
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100,1000)
  and A.EV_TYPE = 86424  /*NAV lock*/
  and not exists (select J.ID from @res J where J.ID = A.ID)

  
insert into @res (ID, CAPTION, USERID, DD, OPERID, ADDINFO)
select A.ID
     , dbo.COM_STRING_BETWEEN(cast(A.EV_TEXT as nvarchar(max)),'Navision returns','if necessary',0)
     , A.S_USERID, A.DD, case when A.DOCOID = 1000039 /*pr.oper*/ and A.DOCID > 0 then A.DOCID else null end
     , cast(A.ADDINFO as nvarchar(max))
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100)
  and A.EV_TYPE = 20002  
  and A.DOCOID = 1000051 /*sh.request*/
  and A.EV_TEXT like '%Navision returns%was locked by another user%Please retry the activity.%'
  and not exists (select J.ID from @res J where J.ID = A.ID)

insert into @res (ID, CAPTION, USERID, DD, OPERID, ADDINFO)
select A.ID
     , dbo.COM_STRING_BETWEEN(cast(A.EV_TEXT as nvarchar(max)),'Navision returns','if necessary',0)
     , A.S_USERID, A.DD, case when A.DOCOID = 1000039 /*pr.oper*/ and A.DOCID > 0 then A.DOCID else null end
     , cast(A.ADDINFO as nvarchar(max))
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100)
  and A.EV_TYPE = 20002  
  and A.DOCOID = 1000051 /*sh.request*/
  and A.EV_TEXT like '%Navision returns%was deadlocked with another user%Please retry the activity.%'
  and not exists (select J.ID from @res J where J.ID = A.ID)

insert into @res (ID, CAPTION, USERID, DD)
select A.ID
     , A.CAPTION
     , A.S_USERID
     , A.DD
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100)
  and A.EV_TYPE = 50000  
  and A.EV_TEXT like '%.NavisionUtils.%'
  and A.CAPTION like 'The activity was deadlocked with another user who was modifying%Please retry the activity.%' 
  and not exists (select J.ID from @res J where J.ID = A.ID)


update @res set CAPTION = CAPTION + char(13)+char(10)+ ADDINFO
where ADDINFO is not null

update @res set OPERID = null where exists (select B.ID from @res B where B.OPERID = "@res".OPERID and B.ID < "@res".ID)
/*
update @res set OPERCLOSED = (select min(B.DD) 
                                from DEF_LOG B 
                               where B.DOCOID = 1000039 /*pr.oper*/ 
                                 and B.DOCID = "@res".OPERID 
                                 and B.ID > "@res".ID 
                                 and B.EV_TYPE = 20002 /*method*/
                                 and B.CAPTION like '%1000023%') /*complete*/
 where OPERID is not null
 */

return				

end