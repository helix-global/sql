CREATE function [dbo].[FC_ACCESS_EXTERNAL_REPORT_TAB](@aUserID int, @aMode int, @aDate datetime)
returns @res table (ID int) as 
begin
     
     insert into @res (ID)
     select A.ID from FC_REPORT A with (nolock) 
     where A.EXTREQDEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@aDate))
       and A.EXTPARENTID is not null
 
  return
end