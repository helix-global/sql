create function [dbo].[COM_CUSTOMER_ADDRESS](@aCustID int,@aMode int)
returns nvarchar(max) as 
begin

   declare @addr nvarchar(max)
   declare @country nvarchar(max)
   
   select @addr = A.ADDRESS
         ,@country = B.NAME
   from COM_CUSTOMER A with (nolock)
   left join COM_COUNTRIES B with (nolock) on B.ID = A.COUNTRY
   where A.ID = @aCustID

   
   if @aMode = 1
   begin
   
     if @addr is not null and @country is not null
       set @addr = @addr+', '+@country
   
   end
   
   return @addr

end