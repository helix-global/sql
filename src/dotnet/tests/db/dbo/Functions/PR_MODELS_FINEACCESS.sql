CREATE function [dbo].[PR_MODELS_FINEACCESS](@aModelID int, @aDepID int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin

declare @res nvarchar(max)
set @res = ''

if dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUserID,@aDate) <> 1
begin
  set @res = 'FullReadOnly;NoAllActions'
  /*KB764  > */  
  if exists (select B.ID 
               from PR_MODEL_SHARINGR B with (nolock) 
              where B.MODELID = @aModelID
                and B.RULETYPE = 2 /*visible 4 designers*/
                and dbo.COM_DEP_ACCESS(null,B.DEPARTMENTID,1,@aUserID,@aDate) = 1
             )
             begin
                set @res = @res + ';BypassActionsMarked=ifShareRule'
             end 
  /*KB764  < */                 

end  
  
	                
if LEN(@res) = 0
   return null
     
return @res  

end;