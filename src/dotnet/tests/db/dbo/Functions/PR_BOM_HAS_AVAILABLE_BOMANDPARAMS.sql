create function [dbo].[PR_BOM_HAS_AVAILABLE_BOMANDPARAMS](@BomID int,@aMode int, @UserID int)
returns int as 
begin

   declare @childmodeltypes table (ID int)
   insert into @childmodeltypes (ID)
   select distinct ID from dbo.PR_MTYPES_4_BOMITEM(@BomID,0)

   if exists (select N.ID 
               from PR_MODELTYPE_BOM N with (nolock) 
			  where N.MTID in (select ID from @childmodeltypes)
			    and N.SHAREBOM = 1 
			  )
			  return 1  
  
   if exists (select D.ID 
	            from PR_MODELTYPE_PARAMS D with (nolock)
				left join PR_MODELTYPE_PARAMS_GR FG with (nolock) on FG.ID = D.PGROUP
				where D.TYPEID in (select ID from @childmodeltypes)
				  and (D.SHAREPRM = 1 or dbo.COM_DEP_ACCESS2(FG.DEPID, @aMode ,@UserID,getdate()) = 1 )
			 )	  
			return 1	
   
  
   return 0
  
end