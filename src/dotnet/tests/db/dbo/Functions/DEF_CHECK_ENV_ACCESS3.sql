CREATE function [dbo].[DEF_CHECK_ENV_ACCESS3](@UserID int,@aDate datetime, @aEType int,@aClass int,@aReport int,@aOperation int,@aViewOID int)
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
   else if (@aEType in (4,7,12,10)) /*operation*/
   begin
     select @res = dbo.DEF_F_ACCESS(A.ARC,null,99,@aDate,@UserID,0) from DEF_OPERATION A with (nolock) where A.OID = @aOperation
     return @res
   end
   else if @aEType = 6 /*view*/
   begin
     
     declare @checkOID int
     declare @viewARC int
     select @res = dbo.DEF_F_ACCESS(B.ARC,null,2,@aDate,@UserID,0) 
           ,@checkOID = B.OID
           ,@viewARC = A.ARC
       from DEF_VIEWS A with (nolock) 
       left join DEF_CLASSES B with (nolock) on B.OID = A.CLASSOID
      where A.OID = @aViewOID
      
      if @checkOID is null /*если view без ссылки на класс - то это view по основному классу*/
        set @res = 1
        
      if @viewARC is not null /*30.04.2018 если у view есть собственный маркер доступа - проверить его*/
         set @res = dbo.DEF_F_ACCESS(@viewARC,null,200,@aDate,@UserID,0) 
      
       
     return @res
   end
   
   return 1
end