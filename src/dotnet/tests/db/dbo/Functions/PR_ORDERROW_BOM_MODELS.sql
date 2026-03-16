CREATE function [dbo].[PR_ORDERROW_BOM_MODELS] (@OrderRowID int)
returns @res table (BOMID int,PARTMODELID int,PARTONLYREVID int,PARTMODELFROM int,BOMIDMODELSCOUNT int)
as 
begin
/* скопировано с PR_DEVICE_BOM_MODELS с заменой заголовка, где определяются @RevID,@MtID,@opt */
declare @allBOM table (BOMID int)

declare @opt table (OPTID int)

declare @RevID int
declare @MtID int
select @RevID = F.REVID 
      ,@MtID = M.TYPEID
from PR_PRORDER_T F with (nolock) 
left join PR_MODELS M on M.ID = F.MODELID
where F.ID = @OrderRowID

insert into @allBOM (BOMID)
select A.ID from PR_MODELTYPE_BOM A with (nolock) where A.MTID = @MtID

insert into @opt (OPTID)
select G.OPTID from PR_PRORDER_TO G where G.OPID = @OrderRowID

/* 1 из ревизии с опциями */
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select distinct A.BOMID,A.PARTMODELID,A.PARTONLYREVID,1
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G)
  and A.ONLYOPTION2 in (select G.OPTID from @opt G)  
  and A.ONLYOPTION3 in (select G.OPTID from @opt G)    
  and A.BOMID in (select BOMID from @allBOM)  
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select distinct A.BOMID,A.PARTMODELID,A.PARTONLYREVID,1
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G)    
  and A.ONLYOPTION2 in (select G.OPTID from @opt G)    
  and A.ONLYOPTION3 is null    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  
/*
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select A.BOMID,A.PARTMODELID,A.PARTONLYREVID,1
from PR_REV_BOM2 A
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G)    
  and A.ONLYOPTION2 is null
  and A.ONLYOPTION3 in (select G.OPTID from @opt G)    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select A.BOMID,A.PARTMODELID,A.PARTONLYREVID,1
from PR_REV_BOM2 A
where A.REVID = @RevID
  and A.ONLYOPTION is null
  and A.ONLYOPTION2 in (select G.OPTID from @opt G)    
  and A.ONLYOPTION3 in (select G.OPTID from @opt G)    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  
*/
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select distinct A.BOMID,A.PARTMODELID,A.PARTONLYREVID,1
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G)    
  and A.ONLYOPTION2 is null  
  and A.ONLYOPTION3 is null    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  
/*
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select A.BOMID,A.PARTMODELID,A.PARTONLYREVID,1
from PR_REV_BOM2 A
where A.REVID = @RevID
  and A.ONLYOPTION is null
  and A.ONLYOPTION2 in (select G.OPTID from @opt G)    
  and A.ONLYOPTION3 is null    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select A.BOMID,A.PARTMODELID,A.PARTONLYREVID,1
from PR_REV_BOM2 A
where A.REVID = @RevID
  and A.ONLYOPTION is null
  and A.ONLYOPTION2 is null
  and A.ONLYOPTION3 in (select G.OPTID from @opt G)    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  
*/

/* 2 из типа */  
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select distinct A.BOMITEM ,A.MODELID ,null ,2
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G)    
  and A.OPTIONID2 in (select G.OPTID from @opt G)    
  and A.OPTIONID3 in (select G.OPTID from @opt G)    
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select distinct A.BOMITEM ,A.MODELID ,null ,2
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G)    
  and A.OPTIONID2 in (select G.OPTID from @opt G)    
  and A.OPTIONID3 is null
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  
/*
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select A.BOMITEM ,A.MODELID ,null ,2
from PR_MODELTYPE_OPTIONS_BOM A 
where A.OPTIONID in (select G.OPTID from @opt G)    
  and A.OPTIONID2 is null
  and A.OPTIONID3 in (select G.OPTID from @opt G)    
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select A.BOMITEM ,A.MODELID ,null ,2
from PR_MODELTYPE_OPTIONS_BOM A 
where A.OPTIONID is null    
  and A.OPTIONID2 in (select G.OPTID from @opt G)    
  and A.OPTIONID3 in (select G.OPTID from @opt G)    
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  
*/

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select distinct A.BOMITEM ,A.MODELID ,null ,2
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G)    
  and A.OPTIONID2 is null
  and A.OPTIONID3 is null
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  
/*
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select A.BOMITEM ,A.MODELID ,null ,2
from PR_MODELTYPE_OPTIONS_BOM A 
where A.OPTIONID is null
  and A.OPTIONID2 in (select G.OPTID from @opt G)    
  and A.OPTIONID3 is null
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select A.BOMITEM ,A.MODELID ,null ,2
from PR_MODELTYPE_OPTIONS_BOM A 
where A.OPTIONID is null
  and A.OPTIONID2 is null
  and A.OPTIONID3 in (select G.OPTID from @opt G)    
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  
*/

/* 3 из ревизии без опций */
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select distinct A.BOMID,A.PARTMODELID,A.PARTONLYREVID ,3
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION is null 
  and A.ONLYOPTION2 is null   
  and A.ONLYOPTION3 is null   
  and A.BOMID in (select BOMID from @allBOM)

delete from @allBOM where BOMID in (select BOMID from @res)    
  
/* 4 из типа без опций */  
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select distinct A.BOMITEM ,A.MODELID ,null ,4
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID is null
  and A.OPTIONID2 is null
  and A.OPTIONID2 is null  
  and A.BOMITEM in (select BOMID from @allBOM)
  

/* совместимые модели */

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM)
select distinct BOMID,PARTMODELID,null,5
from (
select distinct A.BOMID,B.COMPMODELID as PARTMODELID
from @res A
left join PR_REV_COMPM B on B.MODELID = A.PARTMODELID
where A.PARTONLYREVID is null
  and B.REVID = @RevID 
  and B.COMPMODELID <> A.PARTMODELID
) M
where PARTMODELID is not null

update @res set BOMIDMODELSCOUNT = (select COUNT(*) from @res B where B.BOMID = "@res".BOMID)


return


end