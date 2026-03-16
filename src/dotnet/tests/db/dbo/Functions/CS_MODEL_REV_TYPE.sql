CREATE function [dbo].CS_MODEL_REV_TYPE(@mtID int, @Models nvarchar(max), @Revisions nvarchar(max))
returns @res table (ID int)
begin
  
  /* 
  вспомогательная функция возвращает ID ревизий в типе моделей
  если указан @Models, то только по этим моделям
  если указан @Revisions, то только по этим ревизиям
  */
  
  declare @tmodels table (ID int)
  declare @trevs table (ID int)
  declare @hasModels int = 0
  declare @hasRevs int = 0 
  
  
  insert into @tmodels (ID) 
  select distinct ID from dbo.COM_STR2TABLE_INT(@Models)
  if @@rowcount > 0
    set @hasModels = 1

  insert into @trevs (ID) 
  select distinct ID from dbo.COM_STR2TABLE_INT(@Revisions)
  if @@rowcount > 0
    set @hasRevs = 1
 
  
  insert into @res(ID)
  select A.ID
  from PR_REVISION A with(nolock)
  left join PR_MODELS B with(nolock) on B.ID = A.MODELID 
  where B.TYPEID = @mtID
    and (@hasModels = 0 or A.MODELID in (select ID from @tmodels))
    and (@hasRevs = 0 or A.ID in (select ID from @trevs))
    
    
  return

end