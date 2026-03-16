CREATE function [dbo].[SM_CONVERT_ADDRESSES_EXT] (@CallID int, @CustomerID int, @From nvarchar(max), @To nvarchar(max), @Copy nvarchar(max))
returns @res table (CALLID int, CONTACTID int, USEASCOPY int )
as 
begin

  declare @nTo nvarchar(max) = @To
  declare @nCopy nvarchar(max) = @Copy
    
  set @nTo = replace(@nTo,';',',')
  set @nCopy = replace(@nCopy,';',',')

  declare @tmp table (ONE nvarchar(max), CONTACTID int, USEASCOPY int)

  if @CustomerID is not null
  begin

	  insert into @tmp (ONE, USEASCOPY)
	  select A.EMAIL, 0
	  from dbo.COM_STR_EMAIL_2TABLE(@nTo) A
	  
	  insert into @tmp (ONE, USEASCOPY)
	  select A.EMAIL, 1
	  from dbo.COM_STR_EMAIL_2TABLE(@nCopy) A
	  
      update @tmp set CONTACTID = (select top 1 B.ID from COM_CUST_CONTACTS B with (nolock) where B.CUSTOMERID = @CustomerID and upper(B.EMAIL) = upper("@tmp".ONE) and B.S_S = 1)
     
  end

  insert into @res (CALLID, CONTACTID, USEASCOPY)
  select distinct @CallID, A.CONTACTID, A.USEASCOPY
  from @tmp A
  where A.CONTACTID is not null
  
  
    
  return

end