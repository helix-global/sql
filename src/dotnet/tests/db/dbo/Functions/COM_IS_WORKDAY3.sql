create function [dbo].[COM_IS_WORKDAY3](@dd datetime,@aEmplID int)
returns int as 
begin
   
   declare @res int
   declare @whid int
   declare @calendar int
   
   select @whid = dbo.COM_WORKTABLE_BY_DATE2(@dd,@aEmplID)
   
   select @calendar = A.CALENDAR
   from COM_WORKTIME A with(nolock)
   where A.ID = @whid   
     
   select @res = dbo.COM_IS_WORKDAY2(@dd,@calendar,@whid)
   
   return @res

end