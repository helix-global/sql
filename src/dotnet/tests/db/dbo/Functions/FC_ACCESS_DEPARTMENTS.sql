create function [dbo].[FC_ACCESS_DEPARTMENTS] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin
/*отличается от COM_ACCESS_DEPARTMENTS тем, что выдает только подразделения где вообще есть модели*/


insert into @res (ID) 
select A.ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) A
where exists (select HH.ID from PR_MODELS HH where HH.DEPID = A.ID)

return

end