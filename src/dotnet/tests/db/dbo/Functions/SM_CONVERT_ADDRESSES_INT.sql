CREATE function [dbo].[SM_CONVERT_ADDRESSES_INT] (@CallID int, @From nvarchar(max), @To nvarchar(max), @Copy nvarchar(max))
returns @res table (CALLID int, EMAIL nvarchar(250), NAME nvarchar(250) )
as 
begin

  declare @nTo nvarchar(max) = @To
  declare @nCopy nvarchar(max) = @Copy
    
  set @nTo = replace(@nTo,';',',')
  set @nCopy = replace(@nCopy,';',',')

  set @nTo = @nTo + ',' + @From /* добавлено, чтобы если свой сотрудник переслал письмо он тоже по умолчанию попал в internal contacts 
                                   сотрудник поддержки решит - оставлять ли его там */

  insert into @res (CALLID, EMAIL, NAME)
  select @CallID, A.EMAIL, A.NAME
  from dbo.COM_STR_EMAIL_2TABLE(@nTo) A
  where lower(A.EMAIL) like ('%@ipgphotonics.com')
     or lower(A.EMAIL) like ('%@ntoire-polus.ru')
	  
  insert into @res (CALLID, EMAIL, NAME)	  
  select @CallID, A.EMAIL, A.NAME
  from dbo.COM_STR_EMAIL_2TABLE(@nCopy) A
  where (lower(A.EMAIL) like ('%@ipgphotonics.com')
          or lower(A.EMAIL) like ('%@ntoire-polus.ru')
         )
      and not exists (select B.EMAIL from @res B where B.EMAIL = A.EMAIL)    
 
  
    
  return

end