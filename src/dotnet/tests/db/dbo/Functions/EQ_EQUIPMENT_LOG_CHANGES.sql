CREATE function [dbo].[EQ_EQUIPMENT_LOG_CHANGES] (@EqID int, @aMode int)
returns @res table (DT datetime not null,USERID int, NAME nvarchar(500) not null, LOGID int)
as 
begin

   /*
      вычленяет из DEF_LOG изменения серийного номера и модели по маркерам: 
      <EQMODELID>x</EQMODELID><EQMODELID_Original>y</EQMODELID_Original>
      <SN>x</SN><SN_Original>y</SN_Original>
      
      !!!! если дойдет дело до очистки DEF_LOG (выноса в архив),
       то нужно озаботится чтобы записи по оборудованию остались или были перенесены в EQ_LOGEVENTS
       чтобы не потерять данные в отчете EquipmentLog
   
   */
   
   declare @logrows table (ID int, ROWTYPE int, NAME nvarchar(500), XMLDOC xml, VALOLD nvarchar(max), VALNEW nvarchar(max))
   
   insert into @logrows (ID, ROWTYPE, XMLDOC)
     select ID, 1, cast(A.EV_TEXT as xml)
      from DEF_LOG A with (nolock)
      where A.DOCOID = 1000247 /*equipment*/
        and A.DOCID = @EqID
        and A.LEV = 1
        and A.EV_TYPE = 20001 /* save */   
        and A.EV_TEXT like '%<eq_card>%<EQMODELID>%</EQMODELID><EQMODELID_Original>%</EQMODELID_Original>%</eq_card>%'

   insert into @logrows (ID, ROWTYPE, XMLDOC)
     select ID, 2, cast(A.EV_TEXT as xml)
      from DEF_LOG A with (nolock)
      where A.DOCOID = 1000247 /*equipment*/
        and A.DOCID = @EqID
        and A.LEV = 1
        and A.EV_TYPE = 20001 /* save */   
        and A.EV_TEXT like '<eq_card>%<SN>%</SN><SN_Original>%</SN_Original>%</eq_card>%'
        
   insert into @logrows (ID, ROWTYPE, XMLDOC)
     select ID, 3, cast(A.EV_TEXT as xml)
      from DEF_LOG A with (nolock)
      where A.DOCOID = 1000247 /*equipment*/
        and A.DOCID = @EqID
        and A.LEV = 1
        and A.EV_TYPE = 20001 /* save */   
        and A.EV_TEXT like '%<eq_card>%<DEPID>%</DEPID><DEPID_Original>%</DEPID_Original>%</eq_card>%'
        

   update @logrows set VALOLD = XMLDOC.value('(/eq_card//EQMODELID_Original/node())[1]', 'nvarchar(max)') 
                      ,VALNEW = XMLDOC.value('(/eq_card//EQMODELID/node())[1]', 'nvarchar(max)') 
   where ROWTYPE = 1

   update @logrows set VALOLD = XMLDOC.value('(/eq_card//SN_Original/node())[1]', 'nvarchar(max)') 
                      ,VALNEW = XMLDOC.value('(/eq_card//SN/node())[1]', 'nvarchar(max)') 
   where ROWTYPE = 2

  update @logrows set VALOLD = (select B.CODE from EQ_MODELS B with (nolock) where B.ID = cast(VALOLD as int))
                     ,VALNEW = (select B.CODE from EQ_MODELS B with (nolock) where B.ID = cast(VALNEW as int))
   where ROWTYPE = 1
   
   update @logrows set VALOLD = XMLDOC.value('(/eq_card//DEPID_Original/node())[1]', 'nvarchar(max)') 
                      ,VALNEW = XMLDOC.value('(/eq_card//DEPID/node())[1]', 'nvarchar(max)') 
   where ROWTYPE = 3
   
  update @logrows set VALOLD = (select B.NAME from COM_DEPARTMENTS B with (nolock) where B.ID = cast(VALOLD as int))
                     ,VALNEW = (select B.NAME from COM_DEPARTMENTS B with (nolock) where B.ID = cast(VALNEW as int))
   where ROWTYPE = 3
   
  
  update @logrows set NAME = 'Model was changed from "'+ltrim(rtrim(isnull(VALOLD,'NA')))+'" to "'+ltrim(rtrim(isnull(VALNEW,'NA')))+'"' where ROWTYPE = 1

  update @logrows set NAME = 'SN was changed from "'+ltrim(rtrim(isnull(VALOLD,'NA')))+'" to "'+ltrim(rtrim(isnull(VALNEW,'NA')))+'"' where ROWTYPE = 2

  update @logrows set NAME = 'Department was changed from "'+ltrim(rtrim(isnull(VALOLD,'NA')))+'" to "'+ltrim(rtrim(isnull(VALNEW,'NA')))+'"' where ROWTYPE = 3

  insert into @res (DT,USERID,NAME,LOGID)
  select B.DD
        ,B.S_USERID 
        ,A.NAME
        ,A.ID
    from @logrows A 
    left join DEF_LOG B with (nolock) on B.ID = A.ID
  
  return

end