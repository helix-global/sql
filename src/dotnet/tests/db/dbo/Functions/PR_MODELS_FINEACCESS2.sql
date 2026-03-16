CREATE function [dbo].[PR_MODELS_FINEACCESS2](@aModelID int, @mtid int, @aDepID int, @aUserID int, @aMode int, @aDate datetime)
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
  
  /*KB1530 > */
  if exists (select A.ID 
               from PR_OVERRIDE_DEVICE_VIS A with (nolock) 
              where A.MTID = @mtid
                and dbo.COM_DEP_ACCESS(null,A.DEPID,1,@aUserID,@aDate) = 1)
       set @res = ''                
  /*KB1530 < */

end  
  
	                
if LEN(@res) = 0
   return null
     
return @res  

end;