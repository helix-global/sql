create function [dbo].[HH_POINTS](@cvID int)
returns int
as
begin

   declare @res int
   
   select @res = sum(case when AA.PRESENT = 1 then BB.LVL /*when AA.NOTPRESENT = 1 then -BB.LVL*/ else 0 end) from HH_CV_SKILLS AA left join HH_SKILLS BB on BB.ID = AA.SKILLID where AA.VNESHID = @cvID
     
   return @res  

end;