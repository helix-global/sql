CREATE function [dbo].[PR_NEW_G75_CODE]()
returns nvarchar(20) as 
begin
  declare @res nvarchar(20)
  declare @maxN int
  declare @maxN2 int

  declare @Origin int
  select @Origin = A.VALUEINT from DEF_SYSCONST A with (nolock) where A.LABEL = 'pr_origin'
  
  IF @Origin = 1 /*IPM*/
  BEGIN
  
	select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from SW_TOOLS A where A.CODE like 'M75-_____' 
	select @maxN2 = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_DOC_BYOPERATIONS A where A.CODE like 'M75-_____'
	if @maxN2 > @maxN
	  set @maxN = @maxN2
	set @maxN = isnull(@maxN,0)
	set @res = 'M75-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
  
  END
  ELSE  IF @Origin = 3 /*IPGP*/
  BEGIN
  
	select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from SW_TOOLS A where A.CODE like 'P75-_____' 
	select @maxN2 = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_DOC_BYOPERATIONS A where A.CODE like 'P75-_____'
	if @maxN2 > @maxN
	  set @maxN = @maxN2
	set @maxN = isnull(@maxN,0)
	set @res = 'P75-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
  END
  ELSE  IF @Origin = 5 /*IPGRT*/
  BEGIN
  
	select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from SW_TOOLS A where A.CODE like 'B75-_____' 
	select @maxN2 = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_DOC_BYOPERATIONS A where A.CODE like 'B75-_____'
	if @maxN2 > @maxN
	  set @maxN = @maxN2
	set @maxN = isnull(@maxN,0)
	set @res = 'B75-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
  END
  ELSE
  BEGIN

	select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from SW_TOOLS A where A.CODE like 'G75-_____' 
	select @maxN2 = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_DOC_BYOPERATIONS A where A.CODE like 'G75-_____'
	if @maxN2 > @maxN
	  set @maxN = @maxN2
	set @maxN = isnull(@maxN,0)  
	set @res = 'G75-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
  
  END
  
  return @res;
end