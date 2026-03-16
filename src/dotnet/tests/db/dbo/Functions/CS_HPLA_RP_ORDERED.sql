CREATE function [dbo].[CS_HPLA_RP_ORDERED](@mtID int, @UserID int, @aMode int)
returns @res table (ID int not null, MODELID int not null,MGROUP nvarchar(200),ORDDD date,ORDMONTH date)
begin
  
  /* вспомогательная функция для отчета cs_ila_resource_report
  возвращает список заказанных изделий с плановыми датами
  */
  declare @MTdepID int
  select @MTdepID = A.DEPARTMENTID from PR_MODELTYPE A with (nolock) where A.ID = @mtID
  
  insert into @res(ID,MODELID,MGROUP,ORDDD,ORDMONTH)		  
  select DEV.ID
    ,DEV.MODELID
    ,isnull(MG.NAME,'NA')
    ,cast(isnull(S.CDD,O.CDD) as date) /*сделал на confirmed date, но точно неизвестно*/
    ,dbo.COM_ENCODE_DATE(year(isnull(S.CDD,O.CDD)),month(isnull(S.CDD,O.CDD)),1) as ORDMONTH
FROM PR_DEVICE DEV with (nolock)
left JOIN PR_MODELS MDL with (nolock) ON DEV.MODELID = MDL.ID
left JOIN PR_PRORDER O with (nolock) on O.ID = DEV.ORDERID
left join PR_SUPPLY S with (nolock) on S.ID = DEV.SORDERID
left join PR_MODEL_GROUP MG with (nolock) on MG.ID = MDL.MODELGROUPID
WHERE O.DEPARTMENTID = @MTdepID /*151*/
  AND DEV.ORDERID IS NOT NULL
  and DEV.COMPLETED_DT is null
  and MDL.TYPEID = @mtID
  and DEV.S_S in (1000008,1000029)
    

  return

end