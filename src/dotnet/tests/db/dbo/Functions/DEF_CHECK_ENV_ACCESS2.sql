CREATE function [dbo].[DEF_CHECK_ENV_ACCESS2](@UserID int,@aDate datetime, @aEType int,@aClass int,@aReport int,@aOperation int)
returns int as 
begin
   declare @res int
   
   if @aEType = 1 /*report*/
   begin
     select @res = dbo.DEF_F_ACCESS(A.ARC,null,11,@aDate,@UserID,0) from DEF_REPORTS A with (nolock) where A.OID = @aReport
     return @res
   end
   else if @aEType = 2 /*context list*/
   begin
     select @res = dbo.DEF_F_ACCESS(A.ARC,null,2,@aDate,@UserID,0) from DEF_CLASSES A with (nolock) where A.OID = @aClass
     return @res
   end
   else if @aEType = 3 /*context add document*/
   begin
     select @res = dbo.DEF_F_ACCESS(A.ARC,null,6,@aDate,@UserID,0) from DEF_CLASSES A with (nolock) where A.OID = @aClass
     return @res
   end
   else if (@aEType in (4,7,12)) /*operation*/
   begin
     select @res = dbo.DEF_F_ACCESS(A.ARC,null,99,@aDate,@UserID,0) from DEF_OPERATION A with (nolock) where A.OID = @aOperation
     return @res
   end
   
   return 1
end