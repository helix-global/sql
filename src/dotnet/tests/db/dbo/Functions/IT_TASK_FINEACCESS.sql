CREATE function [dbo].[IT_TASK_FINEACCESS](@aTaskID int, @aState int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin


declare @res nvarchar(max)
set @res = ''

if @aState not in (1,2000018/*на уточнении*/) 
begin
   if dbo.DEF_USERINGROUP7(@aUserID,'CFG') <> 1
       return 'FullReadOnly';
end  
	                
if LEN(@res) = 0
   return null
     
return @res  

end;