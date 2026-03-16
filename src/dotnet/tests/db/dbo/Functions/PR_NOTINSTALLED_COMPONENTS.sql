CREATE function [dbo].[PR_NOTINSTALLED_COMPONENTS] (@aMode int,@aID int,@aParamID int)
returns @res table (MODELID int,DD date,QUANTITY int,COMPATIBLECODES nvarchar(max),COMPATIBLENAMES nvarchar(max),COMPATIBLEIDS nvarchar(max))
as 
begin
/* @aMode 1 - по типу модели; в @aParamID - интересующий тип модели компонент */
/* @aMode 2 - по типу модели, кроме Postponed; в @aParamID - интересующий тип модели компонент */
   
  if (@aMode = 1)
  begin
  
    insert into @res (MODELID ,DD ,QUANTITY ,COMPATIBLECODES ,COMPATIBLENAMES ,COMPATIBLEIDS )
    select MM.PARTMODELID, GG.DD,COUNT(*),MM.COMPATIBLECODES,MM.COMPATIBLENAMES,MM.COMPATIBLEIDS
    from  
       (
		select A.ID,cast(ISNULL(C.DD,B.EXPDATE)as DATE) as DD 
		from PR_DEVICE A with (nolock)
		left join PR_MODELS E with (nolock) on E.ID = A.MODELID
		left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
		left join PR_SUPPLY C with (nolock) on C.ID = A.SORDERID
		where E.TYPEID = @aID
		  and A.COMPLETED_DT is null
		  and A.ORDERID is not null
		  and A.S_S <> 1000101 /*canceled*/
	   ) GG
       cross apply dbo.PR_DEVICE_BOM_MODELS2(GG.ID,@aParamID,1) MM
    group by GG.DD,MM.PARTMODELID,MM.COMPATIBLECODES,MM.COMPATIBLENAMES,MM.COMPATIBLEIDS
  
  end
  else if (@aMode = 2)
  begin
  
    insert into @res (MODELID ,DD ,QUANTITY ,COMPATIBLECODES ,COMPATIBLENAMES ,COMPATIBLEIDS )
    select MM.PARTMODELID, GG.DD,COUNT(*),MM.COMPATIBLECODES,MM.COMPATIBLENAMES,MM.COMPATIBLEIDS
    from  
       (
		select A.ID,cast(ISNULL(C.DD,B.EXPDATE)as DATE) as DD 
		from PR_DEVICE A with (nolock)
		left join PR_MODELS E with (nolock) on E.ID = A.MODELID
		left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
		left join PR_SUPPLY C with (nolock) on C.ID = A.SORDERID
		where E.TYPEID = @aID
		  and A.COMPLETED_DT is null
		  and A.ORDERID is not null
		  and A.S_S <> 1000069 /*postponed*/
		  and A.S_S <> 1000101 /*canceled*/
	   ) GG
       cross apply dbo.PR_DEVICE_BOM_MODELS2(GG.ID,@aParamID,1) MM
    group by GG.DD,MM.PARTMODELID,MM.COMPATIBLECODES,MM.COMPATIBLENAMES,MM.COMPATIBLEIDS
  
  end

  return


end