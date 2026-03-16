CREATE function [dbo].[FC_CODES_4_MODEL2] (@aModelID int,@UserID int)
returns @res table (ID int) as 
begin 
   
  /* отличается от FC_CODES_4_MODEL проверкой "внутренних" кодов */
  declare @flg int = 0
   
  declare @mtid int
  declare @depid int
  
  select @mtid = A.TYPEID
       , @depid = A.DEPID
    from PR_MODELS A with (nolock)
    where A.ID = @aModelID
    
  if dbo.COM_DEP_ACCESS2(@depid,1,@UserID,getdate()) = 1
     set @flg = 1  
   
  insert into @res (ID)
  select C.ID
   from FC_FAILURECODES C with (nolock)
  where C.MTID = @mtid
    and C.S_S = 1
    and isnull(C.INTUSE,0) in (0,@flg) 

  return
  
end