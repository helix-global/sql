CREATE function [dbo].[PM_NEW_G_CODE](@aMode int,@skipID int)
returns nvarchar(50) as 
begin
  /*версия для Project Management */ 

  declare @res nvarchar(50)
  declare @maxN int
  declare @maxN2 int

  declare @Origin int
  select @Origin = A.VALUEINT from DEF_SYSCONST A with (nolock) where A.LABEL = 'pr_origin'
  
  IF @Origin = 1 /*IPM*/
  BEGIN
  
	  if (@aMode = 1) /*проект*/
	  begin
	  
		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PM_PROJECT A where A.CODE like 'M10-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'M10-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end  
  
  END
  ELSE IF @Origin = 3 /*IPGP*/
  BEGIN
  
	  if (@aMode = 1) /*проект*/
	  begin
	  
		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PM_PROJECT A where A.CODE like 'P10-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'P10-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
  
	  end  
	  
  END
  ELSE IF @Origin = 2 /*IPGL*/
  BEGIN

	  if (@aMode = 1) /*проект*/
	  begin
	  
		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PM_PROJECT A where A.CODE like 'G10-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'G10-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end  
	  
  
  END
  
  return @res;
end