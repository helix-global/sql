create function [dbo].[IE_MTYPES_4IEPOS] (@PosID int)
returns @res table (ID int)
as 
begin
                      
   insert into @res (ID)
   select A.MTID
   from IE_ITEMPOSITIONS_T A with (nolock)
   where A.VNESHID = @PosID
                      
   return
    
end