create procedure [dbo].[COM_CUSTOMER_CHECK_ADDRESS] @aCustID int, @aMode int, @aUserID int 
as 
set nocount on


declare @fullAddress nvarchar(350)
declare @city nvarchar(150)
declare @code nvarchar(50)

select @fullAddress = A.ADR_STREET
      ,@city = A.ADR_CITY
      ,@code = A.ADR_CODE
from COM_CUSTOMER A with (nolock)
where A.ID = @aCustID


if @code is not null
begin
  
   if @fullAddress is not null
     set @fullAddress = @fullAddress + ', ' + @code
   else
     set @fullAddress = @code

end  

if @city is not null
begin
  
   if @fullAddress is not null
     set @fullAddress = @fullAddress + ', ' + @city
   else
     set @fullAddress = @city

end  


update COM_CUSTOMER set ADDRESS = @fullAddress where ID = @aCustID and ADDRESS is null

set nocount off