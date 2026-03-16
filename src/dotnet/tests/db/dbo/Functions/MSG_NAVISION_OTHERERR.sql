CREATE function [dbo].[MSG_NAVISION_OTHERERR] (@dtBeg datetime, @dtEnd datetime)
returns @res table (ID int, CAPTION nvarchar(max), USERID int, DD datetime, OPERID int, OPERCLOSED datetime, ADDINFO nvarchar(max))
as 
begin


insert into @res (ID, CAPTION, USERID, DD)
select A.ID, A.CAPTION, A.S_USERID, A.DD
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100,1000)
  and A.EV_TYPE in (50000,50021) 
  and A.EV_TEXT like '%.NavisionException:%'
  and A.EV_TEXT not like '%is not on inventory.%'
  and A.EV_TEXT not like '%Serial Number is required for%'
  and A.EV_TEXT not like '%locked%'
  and A.CAPTION not like N'%URI: Das URI-Format%'
  and A.CAPTION not like N'%Invalid URI: The format%'
  and A.ID not in (select HH.ID from dbo.MSG_NAVISION_LOCKS(@dtBeg, @dtEnd) HH)


insert into @res (ID, CAPTION, USERID, DD)
select A.ID, cast(A.EV_TEXT as nvarchar(max)), A.S_USERID, A.DD
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100,1000,75)
  and A.EV_TYPE in (65657,61341) 
  and A.EV_TEXT not like '%is not on inventory.%'
  and A.EV_TEXT not like '%Serial Number is required for%'
  and A.EV_TEXT not like '%locked%'
  and A.EV_TEXT not like '%Utils: Method not%'
  and A.EV_TEXT not like N'%URI: Das URI-Format%'
  and A.EV_TEXT not like N'%Недопустимый URI: Невозможно%'
  and A.ID not in (select HH.ID from dbo.MSG_NAVISION_LOCKS(@dtBeg, @dtEnd) HH)
  and A.ID not in (select ID from @res)

insert into @res (ID, CAPTION, USERID, DD)
select A.ID, cast(A.EV_TEXT as nvarchar(max)), A.S_USERID, A.DD
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100,1000,75)
  and A.EV_TYPE in (89012/*,20002*/) 
  and (A.EV_TEXT like '%you retrieved it%' 
       or A.EV_TEXT like '%permission%'  
       or A.EV_TEXT like 'Prod. Order Line%' 
       or A.EV_TEXT like '%etadata is not in sync for table%'
       or A.EV_TEXT like '%contact your system administrator%'
       )
  and A.ID not in (select HH.ID from dbo.MSG_NAVISION_LOCKS(@dtBeg, @dtEnd) HH)
  and A.ID not in (select ID from @res)


insert into @res (ID, CAPTION, USERID, DD)
select A.ID
     , dbo.COM_STRING_BETWEEN(cast(A.EV_TEXT as nvarchar(max)),'Navision returns','if necessary',0)
     , A.S_USERID, A.DD
from DEF_LOG A with (nolock) 
where A.DD >= @dtBeg
  and A.DD < @dtEnd
  and A.LEV in (100)
  and A.EV_TYPE = 20002  
  and A.DOCOID = 1000051 /*sh.request*/
  and (A.EV_TEXT like '%Navision returns%user has modified%start the interrupted activity again%'
        or A.EV_TEXT like '%failure has occurred%'
      )  
  and A.ID not in (select HH.ID from dbo.MSG_NAVISION_LOCKS(@dtBeg, @dtEnd) HH)
  and A.ID not in (select ID from @res)

return	

end