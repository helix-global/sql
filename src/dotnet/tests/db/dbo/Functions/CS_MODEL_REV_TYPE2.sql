CREATE function [dbo].[CS_MODEL_REV_TYPE2](@mtID int, @Models nvarchar(max), @TagsAND nvarchar(max), @TagsOR nvarchar(max))
returns @res table (ID int)
begin
  /*
  KB3875 
  изменения по сравнению с CS_MODEL_REV_TYPE:
  - возвращает модели, а не ревизии
  - убраны ревизии
  - добавлены теги "AND"
  - добавлены теги "OR"
  - если @Models = "NONE", то работает только по тегам
  */
  
  declare @tmodels table (ID int)
  declare @hasModels int = 0
  declare @hasTAnd int = 0  
  declare @hasTOr int = 0  
  
  if @Models = 'NONE'  
  begin
    set @hasModels = -1
  end
  else
  begin  
  
	  insert into @tmodels (ID) 
	  select distinct ID from dbo.COM_STR2TABLE_INT(@Models)
	  if @@rowcount > 0
		set @hasModels = 1

  end
  

  declare @tAnd table (ONE nvarchar(max))	
  insert into @tAnd (ONE)
  select ITEM from dbo.COM_STR2TABLE_STR(@TagsAND)
  if @@rowcount > 0
    set @hasTAnd = 1
  
  declare @tOr table (ONE nvarchar(max))	
  insert into @tAnd (ONE)
  select ITEM from dbo.COM_STR2TABLE_STR(@TagsOR)
  if @@rowcount > 0
    set @hasTOr = 1
  
  
  insert into @res(ID)
  select A.ID
  from PR_MODELS A with(nolock) 
  where A.TYPEID = @mtID
    and (@hasModels = 0 or A.ID in (select ID from @tmodels))
    and (@hasTAnd = 0 or exists (select * from @tAnd H where H.ONE in (select dbo.COM_STR_DEL_BEFORE(ITEM,'|') from dbo.COM_STR2TABLE_STR(A.TAGS))))

  if @hasTOr = 1
  begin
	  insert into @res(ID)
	  select A.ID
	  from PR_MODELS A with(nolock) 
	  where A.TYPEID = @mtID
		and (exists (select * from @tOr H where H.ONE in (select ITEM from dbo.COM_STR2TABLE_STR(A.TAGS))))
        and (@hasTAnd = 0 or exists (select * from @tAnd H where H.ONE in (select dbo.COM_STR_DEL_BEFORE(ITEM,'|') from dbo.COM_STR2TABLE_STR(A.TAGS))))		

  end    
    
  return

end