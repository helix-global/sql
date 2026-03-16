CREATE function [dbo].[SL_ROWS_ARE_COMPATIBLE](@aRow1 int, @aRow2 int)
returns int
as
begin

   /*KB2600 
     проверяет что для моделей из двух строк есть правило совместимости что @aRow1 совместимо с @aRow2
   */
   declare @Model1 int
   declare @Model2 int
   declare @Model2MT int
   
   select @Model1 = A.MODELID from SL_QUOTE2_T A with (nolock) where A.ID = @aRow1
   
   select @Model2 = A.MODELID 
         ,@Model2MT = B.TYPEID
     from SL_QUOTE2_T A with (nolock) 
     left join PR_MODELS B with (nolock) on B.ID = A.MODELID
    where A.ID = @aRow2
   

   if exists (select A.MODELID 
				 from PR_MODEL_COMPAT_T A with (nolock)
				 left join PR_MODEL_COMPAT B with (nolock) on B.ID = A.VNESHID
				 left join PR_MODEL_COMPAT_WITH C with (nolock) on C.VNESHID = B.ID
				 where A.MODELID = @Model1
				   and C.MODELID = @Model2
				   /*опции не заданы*/
				   and not exists (select K.ID from PR_MODEL_COMPAT_WITH_OPT K with (nolock) where K.VNESHID = B.ID)
				   and isnull(B.CMODE,0) = 1	/*Listed models (t) are compatible with listed models (with)*/
				)
      return 1   

   if exists (select A.MODELID 
				 from PR_MODEL_COMPAT_T A with (nolock)
				 left join PR_MODEL_COMPAT B with (nolock) on B.ID = A.VNESHID
				 left join PR_MODEL_COMPAT_WITH C with (nolock) on C.VNESHID = B.ID
				 where A.MODELID = @Model1
				   and C.MODELID = @Model2
				   /*опции заданы и...*/
				   and exists (select K.ID from PR_MODEL_COMPAT_WITH_OPT K with (nolock) where K.VNESHID = B.ID)
				   /*... и что-то из них должно присутствовать в выборе*/
				   and exists (select J.ID 
				                 from SL_QUOTE2_TO J with (nolock) 
				                where J.OPOSID = @aRow2
				                  and J.OPTID in (select K.OPTID from PR_MODEL_COMPAT_WITH_OPT K with (nolock) where K.VNESHID = B.ID)
			                   )
				   and isnull(B.CMODE,0) = 1	/*Listed models (t) are compatible with listed models (with)*/
				)
      return 1   
     
    
    if exists (select A.MODELID 
				 from PR_MODEL_COMPAT_T A with (nolock)
				 left join PR_MODEL_COMPAT B with (nolock) on B.ID = A.VNESHID
				 where A.MODELID = @Model1
				   and B.COMPATWITH_MTID = @Model2MT
				   /*опции не заданы*/
				   and not exists (select K.ID from PR_MODEL_COMPAT_WITH_OPT K with (nolock) where K.VNESHID = B.ID)
				   and isnull(B.CMODE,0) = 2	/*Listed models (t) are compatible with all models from 'model type with'*/
               )
       return 1        
       
    if exists (select A.MODELID 
				 from PR_MODEL_COMPAT_T A with (nolock)
				 left join PR_MODEL_COMPAT B with (nolock) on B.ID = A.VNESHID
				 where A.MODELID = @Model1
				   and B.COMPATWITH_MTID = @Model2MT
				   /*опции заданы и...*/
				   and exists (select K.ID from PR_MODEL_COMPAT_WITH_OPT K with (nolock) where K.VNESHID = B.ID)
				   /*... и что-то из них должно присутствовать в выборе*/
				   and exists (select J.ID 
				                 from SL_QUOTE2_TO J with (nolock) 
				                where J.OPOSID = @aRow2
				                  and J.OPTID in (select K.OPTID from PR_MODEL_COMPAT_WITH_OPT K with (nolock) where K.VNESHID = B.ID)
			                   )
				   and isnull(B.CMODE,0) = 2	/*Listed models (t) are compatible with all models from 'model type with'*/
				)
      return 1             

  
  return 0
  
end;