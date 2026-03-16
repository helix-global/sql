CREATE function [dbo].[PR_NEW_G_CODE2](@aMode int,@skipID int,@ObjectID int)
returns nvarchar(50) as 
begin
/*
в отличие от PR_NEW_G_CODE добавлен параметр, через который реализовано переключение на генерацию номеров G75 в отдельных группах SW&Tools
@ObjectID можно использовать в других режимах для аналогичных задач
*/

  declare @res nvarchar(50)
  declare @maxN int
  declare @maxN2 int

  declare @Origin int
  select @Origin = A.VALUEINT from DEF_SYSCONST A with (nolock) where A.LABEL = 'pr_origin'
  
  IF @Origin = 1 /*IPM*/
  BEGIN
  
	  if (@aMode = 1) /*форма операции M67*/
	  begin
	  
		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_OPERATIONS A where A.CODE like 'M67-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'M67-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end  
	  else if (@aMode = 2) /*карта M68*/
	  begin

		select @maxN = max(dbo.COM_EXTR_NUM(A.NN,5,5)) from PR_MAP A where A.NN like 'M68-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'M68-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end
	  else if (@aMode = 3) /*форма отчета M69*/
	  begin

		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_REPORTS A where A.CODE like 'M69-_____' and A.ID <> ISNULL(@skipID,-444)
		select @maxN2 = max(dbo.COM_EXTR_NUM(A.ISOCODE,5,5)) from DEF_REPORTS A where A.ISOCODE like 'M69-_____'
		if @maxN2 > @maxN
		  set @maxN = @maxN2
		set @maxN = isnull(@maxN,0)
		set @res = 'M69-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end
	  else if (@aMode = 4) /*sw&tools M73*/
	  begin

        if exists (select J.ID from PR_DOC_SETTINGS J with (nolock) where J.SWGROUP = @ObjectID)
        begin
        
          set @res = dbo.PR_NEW_G75_CODE()
        
        end
        else
        begin
		   select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from SW_TOOLS A where A.CODE like 'M73-_____' and A.ID <> ISNULL(@skipID,-444)
		   set @maxN = isnull(@maxN,0)
		   set @res = 'M73-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
		end   
	  
	  end
  
  
  END
  ELSE  IF @Origin = 3 /*IPGP*/
  BEGIN
  
	  if (@aMode = 1) /*форма операции P67*/
	  begin
	  
		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_OPERATIONS A where A.CODE like 'P67-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'P67-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end  
	  else if (@aMode = 2) /*карта P68*/
	  begin

		select @maxN = max(dbo.COM_EXTR_NUM(A.NN,5,5)) from PR_MAP A where A.NN like 'P68-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'P68-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end
	  else if (@aMode = 3) /*форма отчета P69*/
	  begin

		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_REPORTS A where A.CODE like 'P69-_____' and A.ID <> ISNULL(@skipID,-444)
		select @maxN2 = max(dbo.COM_EXTR_NUM(A.ISOCODE,5,5)) from DEF_REPORTS A where A.ISOCODE like 'P69-_____'
		if @maxN2 > @maxN
		  set @maxN = @maxN2
		set @maxN = isnull(@maxN,0)
		set @res = 'P69-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end
	  else if (@aMode = 4) /*sw&tools P73*/
	  begin

        if exists (select J.ID from PR_DOC_SETTINGS J with (nolock) where J.SWGROUP = @ObjectID)
        begin
        
          set @res = dbo.PR_NEW_G75_CODE()
        
        end
        else
        begin
			select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from SW_TOOLS A where A.CODE like 'P73-_____' and A.ID <> ISNULL(@skipID,-444)
			set @maxN = isnull(@maxN,0)
			set @res = 'P73-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
		end	
	  
	  end
	  
  END
  ELSE  IF @Origin = 5 /*IPGRT*/
  BEGIN
  
	  if (@aMode = 1) /*форма операции B67*/
	  begin
	  
		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_OPERATIONS A where A.CODE like 'B67-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'B67-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end  
	  else if (@aMode = 2) /*карта B68*/
	  begin

		select @maxN = max(dbo.COM_EXTR_NUM(A.NN,5,5)) from PR_MAP A where A.NN like 'B68-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'B68-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end
	  else if (@aMode = 3) /*форма отчета P69*/
	  begin

		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_REPORTS A where A.CODE like 'B69-_____' and A.ID <> ISNULL(@skipID,-444)
		select @maxN2 = max(dbo.COM_EXTR_NUM(A.ISOCODE,5,5)) from DEF_REPORTS A where A.ISOCODE like 'B69-_____'
		if @maxN2 > @maxN
		  set @maxN = @maxN2
		set @maxN = isnull(@maxN,0)
		set @res = 'B69-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end
	  else if (@aMode = 4) /*sw&tools B73*/
	  begin

        if exists (select J.ID from PR_DOC_SETTINGS J with (nolock) where J.SWGROUP = @ObjectID)
        begin
        
          set @res = dbo.PR_NEW_G75_CODE()
        
        end
        else
        begin
			select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from SW_TOOLS A where A.CODE like 'B73-_____' and A.ID <> ISNULL(@skipID,-444)
			set @maxN = isnull(@maxN,0)
			set @res = 'B73-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
		end	
	  
	  end
	  
  END
  ELSE
  BEGIN

	  if (@aMode = 1) /*форма операции G67*/
	  begin
	  
		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_OPERATIONS A where A.CODE like 'G67-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'G67-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end  
	  else if (@aMode = 2) /*карта G68*/
	  begin

		select @maxN = max(dbo.COM_EXTR_NUM(A.NN,5,5)) from PR_MAP A where A.NN like 'G68-_____' and A.ID <> ISNULL(@skipID,-444)
		set @maxN = isnull(@maxN,0)
		set @res = 'G68-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end
	  else if (@aMode = 3) /*форма отчета G69*/
	  begin

		select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from PR_REPORTS A where A.CODE like 'G69-_____' and A.ID <> ISNULL(@skipID,-444)
		select @maxN2 = max(dbo.COM_EXTR_NUM(A.ISOCODE,5,5)) from DEF_REPORTS A where A.ISOCODE like 'G69-_____'
		if @maxN2 > @maxN
		  set @maxN = @maxN2
		set @maxN = isnull(@maxN,0)  
		set @res = 'G69-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
	  
	  end
	  else if (@aMode = 4) /*sw&tools G73*/
	  begin

        if exists (select J.ID from PR_DOC_SETTINGS J with (nolock) where J.SWGROUP = @ObjectID)
        begin
        
          set @res = dbo.PR_NEW_G75_CODE()
        
        end
        else
        begin
			select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,5)) from SW_TOOLS A where A.CODE like 'G73-_____' and A.ID <> ISNULL(@skipID,-444)
			set @maxN = isnull(@maxN,0)
			set @res = 'G73-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',5)
		end
	  
	  end
	  
  
  END
  
  return @res;
end