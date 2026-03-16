CREATE function [dbo].[EQ_EQUIPMENT_LOG_LINKDELETED] (@EqID int, @aMode int)
returns @res table (DT datetime not null,USERID int, NAME nvarchar(500) not null)
as 
begin

  /*
  KB634
  
  в EQ_EQUIPMENT_LIKS_HISTORY если ссылка меняется на другой связанный Equipment, то 
  по старому Equipment нужно вывести строчку что оно было удалено из связанных
  
  В таблице EQ_EQUIPMENT_LIKS_HISTORY это выглядит так:
    ID		DD					USERID	EQID	LACTION	TO_EQID
  	2024	08.06.2018 11:43	807		5834	1		5835
	4060	23.04.2019 11:12	3587	5834	2		8576
						
  Если рассматривать лог по Equipment 5835, то по строке 4060 должно быть событие 
  в его логе, что оно было вынуто. 
   
  */
  
  declare @temp table (INSTALLID int, REMOVEID int)
  insert into @temp (INSTALLID, REMOVEID)
  select A.ID
       ,(select top 1 B.ID 
           from EQ_EQUIPMENT_LIKS_HISTORY B with (nolock) 
          where B.EQID = A.EQID 
            and B.LACTION = 2
          order by B.ID 
            )
  from EQ_EQUIPMENT_LIKS_HISTORY A with (nolock)
  where A.TO_EQID = @EqID
    and A.LACTION = 1
  
  
  insert into @res (DT, USERID, NAME)
  select A.DD
        ,A.USERID
        ,'Link from "'+B.SN+'" ('+isnull(C.CODE,'NA')+') was deleted'
  from @temp AA
  left join EQ_EQUIPMENT_LIKS_HISTORY A with (nolock) on A.ID = AA.REMOVEID
  left join EQ_EQUIPMENT B with (nolock) on B.ID = A.EQID
  left join EQ_MODELS C with (nolock) on C.ID = B.EQMODELID
  where AA.REMOVEID is not null
  
  return

end