
create function [dbo].[DEF_STATE_NAME_U](@aStateOID int,@UserID int)
returns nvarchar(150) as 
begin

	declare @aLangCode nvarchar(2)

	select @aLangCode = E.NAME
		from DEF_SETTINGS S
			join DEF_ENUMERATION_T E on S.VALUE=E.CODE
		where S.USERID=@UserID and E.ENUMOID=1000005
				and S.LABEL='def_language'

	set @aLangCode = ISNULL(@aLangCode,'EN')

  declare @res nvarchar(150)
  set @res = dbo.DEF_STATE_NAME_X(@aStateOID, @aLangCode)

   return @res;
end