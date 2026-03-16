CREATE function [dbo].[FC_PARENT_FAR_INFO](@aFarID int, @aParentFarID int, @aMode int)
returns nvarchar(max) as 
begin
/*
mode: 
1 - Parent FAR Item Model
2 - Parent FAR Item SN
3 - Parent FAR Main Reason
*/
  declare @res nvarchar(max)
  
  if (@aMode = 1)
  begin
    
     select @res = B.NAME
     from FC_REPORT A with (nolock)
     left join PR_MODELS B with (nolock) on B.ID = A.MODELID
     where A.ID = @aParentFarID
  
  end
  else if (@aMode = 2)
  begin
    
     select @res = A.SN
     from FC_REPORT A with (nolock)
     where A.ID = @aParentFarID
  
  end  
  else if (@aMode = 3)
  begin
    
     select top 1 @res = B.NAME
     from FC_REPORT_ANALYSIS_CODES A with (nolock)
     left join FC_FAILUREANALYSISCODES B with (nolock) on B.ID = A.ANALYSISCODEID
     where A.VNESHID = @aParentFarID
       and isnull(A.INITI,0) = 1
  
  end
      
  return @res;
end