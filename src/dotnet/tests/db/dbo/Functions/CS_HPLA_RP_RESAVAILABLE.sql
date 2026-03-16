CREATE function [dbo].[CS_HPLA_RP_RESAVAILABLE](@mtID int, @untilDate datetime, @amode int)
returns @res table (STAGEID int, DD date, AVAILRES decimal(18,2), AVAILINPRODRES decimal(18,2))
begin
  /* 
  вспомогательная функция для отчета cs_ila_resource_report
  возвращает кол-во доступных часов по стадии по привязанным сотрудникам
  
  основной вопрос: если сотрудник привязан к нескольким стадиям - как его делить? 
  пока поделил пропорционально
  
  */
  declare @nowD date = cast(getdate() as date)
  
  declare @depid int
  select @depid = A.DEPARTMENTID
  from PR_MODELTYPE A with (nolock)
  where A.ID = @mtID
  
  declare @resources table (EMPLID int not null, DD date, AVAIL decimal(12,2), AVAILINPROD decimal(12,2), STCOUNT int)
  
  insert into @resources(EMPLID,DD,AVAIL,AVAILINPROD)
  select EMPLID,DD,AVAIL,AVAILINPROD from dbo.COM_DEP_EMPLWORKDAYS_TAB(@depid,@nowD,@untilDate,1)
  --TODO вложенные подразделения ?  
  
  
  declare @empl2stages table (ID int not null, STAGEID int,DBEG datetime, DEND datetime)
  
  insert into @empl2stages (ID,STAGEID,DBEG,DEND)
  select distinct A.EMPLOYEEID,B.STAGEID,A.DBEG,A.DEND
  from PR_EMPL_TO_OPERGR A with (nolock)
  left join PR_OPERATIONS B with (nolock) on B.OPERGRID = A.GROUPID
  where A.DEPID = @depid
    and B.MTID = @mtID
    and A.EMPLOYEEID in (select distinct KK.EMPLID from @resources KK)
  
  /*сколько стадий может делать человек в день - на столько делить его доступные ресурсы в этот день*/
  /*??что если у него еще и стадии других типов моделей??*/
  
  update @resources set STCOUNT = (select count(distinct A.STAGEID)
                                     from @empl2stages A 
                                    where A.ID = "@resources".EMPLID
                                      and isnull(A.DBEG,'20000101') <= "@resources".DD
                                      and isnull(A.DEND,'40000101') >= "@resources".DD 
                                    )
  
  insert into @res (DD,STAGEID)
  select distinct A.DD, B.STAGEID 
  from @resources A
  cross join @empl2stages B
  where A.DD is not null
    and B.STAGEID is not null
    
  
  update @res set AVAILRES = (select sum(A.AVAIL/A.STCOUNT) 
                               from @resources A
                               where A.EMPLID in (select B.ID from @empl2stages B
                                                   where B.STAGEID = "@res".STAGEID
                                                     and isnull(B.DBEG,'20000101') <= "@res".DD
                                                     and isnull(B.DEND,'40000101') >= "@res".DD
                                                  ) 
                                 and A.DD = "@res".DD                     
                              ),
				AVAILINPRODRES = (select sum(A.AVAILINPROD/A.STCOUNT) 
                               from @resources A
                               where A.EMPLID in (select B.ID from @empl2stages B
                                                   where B.STAGEID = "@res".STAGEID
                                                     and isnull(B.DBEG,'20000101') <= "@res".DD
                                                     and isnull(B.DEND,'40000101') >= "@res".DD
                                                  ) 
                                 and A.DD = "@res".DD                     
                              )
                               
  
  return    
  
end