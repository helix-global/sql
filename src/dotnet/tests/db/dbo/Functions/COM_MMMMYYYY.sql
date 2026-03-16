create function [dbo].[COM_MMMMYYYY](@aDate datetime,@aMode int)
returns nvarchar(50) as 
begin
   
   
   return dbo.DEF_ENUM_V_EN(1000103,'com_months' ,month(@aDate))+' '+ltrim(rtrim(str(year(@aDate))))

  
end