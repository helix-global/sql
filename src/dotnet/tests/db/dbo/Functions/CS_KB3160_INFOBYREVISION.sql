
CREATE function [dbo].[CS_KB3160_INFOBYREVISION](@aRevisionID int, @aMode int, @dd datetime, @prm1 nvarchar(max))
returns nvarchar(max)
as
begin
/*
KB3160
@aMode = 1: BOMItemRevision("HPLE").Remove(2).Replace ("0","") всех произведенных за 12 месяцев до даты создания отчета лазеров
            distinct
*/

  declare @dbeg datetime = dateadd(month,-12,@dd)

  declare @res nvarchar(max)
  set @res = '';
  
  if @aMode = 1
  BEGIN
	  select @res = @res + case when len(@res) > 0 then ', ' else '' end + NN 
	  from (

      select replace(NN,'0','') as NN
      
      from ( 	  

	  select distinct substring(ltrim(NN),0,3) as NN 
	  from (
	     
		 select distinct C.NAME as NN
		 from PR_DEVICE A with(nolock)
		 left join PR_DEVICE B with(nolock) on B.ID = dbo.PR_DEVICE_BOMITEM(A.ID,325/*HPLE*/)
		 left join PR_REVISION C with(nolock) on C.ID = B.REVID
		 where A.REVID = @aRevisionID
		   and A.COMPLETED_DT >= @dbeg
		   and A.COMPLETED_DT < @dd 
		   and C.NAME is not null
	     
	  )M1
	  where NN is not null
	  
	  )M
	  )M2
  END
  else if @aMode = 2
  BEGIN
    
    select @res = @res + case when len(@res) > 0 then ', ' else '' end + GG.NAME
    from PR_REVISION A with(nolock)
    left join PR_MODEL_OPTIONS B with(nolock) on B.MODELID = A.MODELID
    left join PR_MODELTYPE_OPTIONS GG with(nolock) on GG.ID = B.OPTIONID
    where A.ID = @aRevisionID
      and GG.ID is not null
      and GG.ID in (select ID from dbo.COM_STR2TABLE_INT(@prm1))
  
  END
  /* KB3297 */
  else if @aMode = 3
  BEGIN
    
    select @res = @res + case when len(@res) > 0 then ', ' else '' end + convert(varchar(50),GG.ID)
    from PR_REVISION A with(nolock)
    left join PR_MODEL_OPTIONS B with(nolock) on B.MODELID = A.MODELID
    left join PR_MODELTYPE_OPTIONS GG with(nolock) on GG.ID = B.OPTIONID
    where A.ID = @aRevisionID
      and GG.ID is not null
      and GG.ID in (select ID from dbo.COM_STR2TABLE_INT(@prm1))
  
  END
    

  return @res;
end;