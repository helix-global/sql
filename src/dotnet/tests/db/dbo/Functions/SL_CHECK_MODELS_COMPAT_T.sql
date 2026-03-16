CREATE function [dbo].[SL_CHECK_MODELS_COMPAT_T](@aExisting nvarchar(max), @aMode int, @aUserID int)
returns @res table (ID int)
as
begin
  /* возвращает спиcок ID моделей (не опций), которые можно добавить к конфигурации на основании настроек совместимости */
  /*
  @aMode =  1 - с учетом совместимости
  @aMode <> 0 - без учета совместимости - просто возвращает все что есть в SL_MODELS
  */
  
  if isnull(@aMode,0) <> 1
  begin
  
     insert into @res (ID)
     select A.ID from SL_MODELS A with (nolock)
     
     return
  
  end
  


  /* 
  declare @ex table (ID int,ID2 int)
  insert into @ex (ID,ID2)
  select ID,ID2 from dbo.COM_STR2TABLE_INT_2COL(@aExisting)
  */
  declare @ex table (ID int)
  insert into @ex (ID)
  select ID from dbo.COM_STR2TABLE_INT(@aExisting)
  
  /*если пусто, то можно выбирать все что есть в документах совместимости*/
  if not exists(select ID from @ex)
  begin
  
     insert into @res (ID)
     select distinct A.MODELID from PR_MODEL_COMPAT_T A with (nolock)
     union 
     select distinct B.MODELID from PR_MODEL_COMPAT_WITH B with (nolock)
  
  end
  else
  begin
	  /*можно выбирать:
	  1) когда в конфигурации уже есть, то с чем совместима модель (с учетом опций - см ниже)
	  2) когда в конфигурации есть совместимая для этой модели модель
	  во втором случае опции можно проверить только при сохранении (что к подобранной модели добавили опции при которых действует совместимость
	  т.к. опции все равно проверять при сохранении, то для ускорения списка подбора здесь они не проверяются и для первого случая
	  */

     insert into @res (ID)
     select distinct A.MODELID 
     from PR_MODEL_COMPAT_T A with (nolock)
     left join PR_MODEL_COMPAT B with (nolock) on B.ID = A.VNESHID
     left join PR_MODEL_COMPAT_WITH C with (nolock) on C.VNESHID = B.ID
     where C.MODELID in (select ID from @ex)
       and isnull(B.CMODE,0) = 1	/*Listed models (t) are compatible with listed models (with)*/
     
     insert into @res (ID)
     select distinct A.MODELID 
     from PR_MODEL_COMPAT_T A with (nolock)
     left join PR_MODEL_COMPAT B with (nolock) on B.ID = A.VNESHID
     where B.COMPATWITH_MTID in (select distinct TYPEID from PR_MODELS with (nolock) where ID in (select ID from @ex))
       and isnull(B.CMODE,0) = 2	/*Listed models (t) are compatible with all models from 'model type with'*/

     /* обратный вариант (пункт 2)) */
     insert into @res (ID)
     select distinct A.MODELID 
     from PR_MODEL_COMPAT_WITH A with (nolock)
     left join PR_MODEL_COMPAT B with (nolock) on B.ID = A.VNESHID
     left join PR_MODEL_COMPAT_T C with (nolock) on C.VNESHID = B.ID
     where C.MODELID in (select ID from @ex)
       and isnull(B.CMODE,0) = 1	/*Listed models (t) are compatible with listed models (with)*/
     
     /* обратный вариант (пункт 2)) для случая когда все модели указанного типа можно выбрать т.к. уже подобрана модель совместимая с любой моделью этого типа*/
     insert into @res (ID)
     select distinct C.ID 
     from PR_MODEL_COMPAT_T A with (nolock)
     left join PR_MODEL_COMPAT B with (nolock) on B.ID = A.VNESHID
     left join SL_MODELS C with (nolock) on C.TYPEID = B.COMPATWITH_MTID
     where A.MODELID in (select ID from @ex)
       and isnull(B.CMODE,0) = 2	/*Listed models (t) are compatible with all models from 'model type with'*/
         
  end
  
  return 
  
end;