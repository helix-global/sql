CREATE function [dbo].[EQ_EQUIPMENT_LOG] (@EqID int, @aMode int)
returns @res table (DT datetime not null,USERID int, NAME nvarchar(500) not null,OPERID int,EQFRID int)
as 
begin
 
  insert into @res (DT, USERID, NAME)
  select A.S_CDT,A.S_CR,'Device registation' from EQ_EQUIPMENT A with (nolock) where A.ID = @EqID
  
  insert into @res (DT, USERID, NAME,OPERID)
  select A.COMPLETED_DT, A.S_MR, 'Operation: '+isnull(B.NAME,''),A.ID
  from PR_OPERATION A with (nolock)
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
  where A.EQID = @EqID
    and A.COMPLETED_DT is not null

  insert into @res (DT, USERID, NAME,OPERID)
  select A.COMPLETED_DT, A.S_MR, 'Operation: '+isnull(B.NAME,''),A.ID
  from PR_OPERATION A with (nolock)
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
  where A.ID in (select distinct G.OPERID from PR_OPERATION_EQUIPMENT G with (nolock) where G.EQID = @EqID)
    and A.COMPLETED_DT is not null

  
  /*
      
      !!!! если дойдет дело до очистки DEF_LOG (выноса в архив),
       то нужно озаботится чтобы записи по оборудованию остались или были перенесены в EQ_LOGEVENTS
       чтобы не потерять данные в отчете EquipmentLog
   
   */

  insert into @res (DT, USERID, NAME)
  select DD,S_USERID,NAME
  from 
  (
     select A.DD
           ,A.S_USERID
           ,case 
            when CAPTION like '%(1000251)' then 'Device state changed to "Reserve"'
            when CAPTION like '%(1000250)' then 'Device state changed to "Reserve"'
            when CAPTION like '%(1000252)' then 'Device state changed to "Deprecated"'
            when CAPTION like '%(1000253)' then 'Device state changed to "Deprecated"'
            when CAPTION like '%(1000282)' then 'Device state changed to "Deprecated"'
            when CAPTION like '%(1000254)' then 'Device state changed to "In Use"'
            when CAPTION like '%(1000255)' then 'Device state changed to "In Use"'
            when CAPTION like '%(1000281)' then 'Device state changed to "Written Off"'
             when CAPTION like '%(2000009)' then 'Device state changed to "In Repair"'
             when CAPTION like '%(2000010)' then 'Device state changed to "In Repair"'
             when CAPTION like '%(2000018)' then 'Device state changed to "Defect"'
             when CAPTION like '%(2000019)' then 'Device state changed to "Defect"'
             when CAPTION like '%(2000021)' then 'Device state changed to "Deprecated"'
             when CAPTION like '%(2000012)' then 'Device state changed to "Deprecated"'
             when CAPTION like '%(2000020)' then 'Device state changed to "In Use"'
             when CAPTION like '%(2130027)' then 'Device state changed to "In Repair"'
             when CAPTION like '%(2000011)' then 'Device state changed to "In Use"'
             WHEN CAPTION LIKE '%(2130080)' THEN 'Device state changed to "In Calibration"'
			 WHEN CAPTION LIKE '%(2130081)' THEN 'Device state changed to "In Calibration"'
             WHEN CAPTION LIKE '%(2130082)' THEN 'Device state changed to "In Use"'
             WHEN CAPTION LIKE '%(2130093)' THEN 'Device state changed to "Reserve"'
             WHEN CAPTION LIKE '%(2130094)' THEN 'Device state changed to "In Repair"'
             WHEN CAPTION LIKE '%(2130095)' THEN 'Device state changed to "Defect"'
             WHEN CAPTION LIKE '%(2130096)' THEN 'Device state changed to "Deprecated"'
            end as NAME
      from DEF_LOG A with (nolock)
      where A.DOCOID = 1000247 /*equipment*/
        and A.DOCID = @EqID
        and A.EV_TYPE = 20002 /* method */
     
  ) M where M.NAME is not null
  
  insert into @res (DT, USERID, NAME)
  select A.DT, A.USERID, A.NAME
  from dbo.EQ_EQUIPMENT_LOG_CHANGES(@EqID,0) A
  
  
  insert into @res (DT, USERID, NAME)
  select A.DD
        ,A.USERID
        ,case A.LACTION 
         when 1 then 'Linked equipment "'+B.SN+'" ('+isnull(C.CODE,'NA')+') was added'
         when 2 then 'Link to equipment was changed. New link to: "'+B.SN+'" ('+isnull(C.CODE,'NA')+')'
         when 3 then 'Link to equipment "'+isnull(B.SN,'NA')+'" ('+isnull(C.CODE,'NA')+') was deleted'
         end 
  from EQ_EQUIPMENT_LIKS_HISTORY A with (nolock)
  left join EQ_EQUIPMENT B with (nolock) on B.ID = A.TO_EQID
  left join EQ_MODELS C with (nolock) on C.ID = B.EQMODELID
  where A.EQID = @EqID
    and B.ID is not null
  
  insert into @res (DT, USERID, NAME)
  select A.DD
        ,A.USERID
        ,case A.LACTION 
         when 1 then 'Device was linked to "'+B.SN+'" ('+isnull(C.CODE,'NA')+')'
         when 2 then 'Device was linked to "'+B.SN+'" ('+isnull(C.CODE,'NA')+')'
         when 3 then 'Link from "'+B.SN+'" ('+isnull(C.CODE,'NA')+') was deleted'
         end 
  from EQ_EQUIPMENT_LIKS_HISTORY A with (nolock)
  left join EQ_EQUIPMENT B with (nolock) on B.ID = A.EQID
  left join EQ_MODELS C with (nolock) on C.ID = B.EQMODELID
  where A.TO_EQID = @EqID
    and B.ID is not null
    
  insert into @res (DT, USERID, NAME)
  select DT, USERID, NAME from dbo.EQ_EQUIPMENT_LOG_LINKDELETED(@EqID,0)  /*KB634 описание внутри функции*/
    
  insert into @res (DT, USERID, NAME)    
  select A.DD, A.S_CR, A.NAME
  from EQ_LOGEVENTS A with (nolock)
  where A.EQID = @EqID
  
  
  /*KB2003*/
  insert into @res (DT, USERID, NAME, EQFRID)    
  select A.S_CDT, A.S_CR, 'Equipment failure report created', A.ID 
  from EQ_FR A with (nolock)
  where A.EQID = @EqID
  
  
  return

end