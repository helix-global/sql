create function [dbo].[COM_GET_LOGO] (@aMode int)
returns @res table (ORIGIN int, LOGO image)
as 
begin

   declare @Origin int
   select @Origin = A.VALUEINT from DEF_SYSCONST A with (nolock) where A.LABEL = 'pr_origin'

   insert into @res (ORIGIN, LOGO)
   select A.DEPORIGIN, A.LOGO
   from COM_LOGOS A with (nolock)
   where A.DEPORIGIN = @Origin
                      
   return
    
end