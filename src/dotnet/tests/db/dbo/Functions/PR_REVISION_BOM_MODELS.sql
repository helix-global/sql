CREATE function [dbo].[PR_REVISION_BOM_MODELS] (@RevID int)
returns @res table (BOMID int,PARTMODELID int,PARTONLYREVID int,PARTMODELFROM int,BOMIDMODELSCOUNT int, QTY decimal(10,4))
as 
begin

declare @allBOM table (BOMID int)

declare @MtID int
declare @ModelID int

select @MtID = M.TYPEID
      ,@ModelID = F.MODELID
from PR_REVISION F with (nolock) 
left join PR_MODELS M on M.ID = F.MODELID
where F.ID = @RevID

insert into @allBOM (BOMID)
select A.ID from PR_MODELTYPE_BOM A with (nolock) where A.MTID = @MtID

declare @opt table (OPTID int)

insert into @opt (OPTID)
select A.OPTIONID from PR_MODEL_OPTIONS A with (nolock) where A.MODELID = @ModelID and ISNULL(A.PREDEFINEDOPT,0) = 1

/* 1 из ревизии c опциями */
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM,QTY)
select distinct A.BOMID,A.PARTMODELID,A.PARTONLYREVID ,1,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G) 
  and A.ONLYOPTION2 in (select G.OPTID from @opt G) 
  and A.ONLYOPTION3  in (select G.OPTID from @opt G) 
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)      

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM,QTY)
select distinct A.BOMID,A.PARTMODELID,A.PARTONLYREVID ,1,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G) 
  and A.ONLYOPTION2 in (select G.OPTID from @opt G) 
  and A.ONLYOPTION3  is null
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)      

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM,QTY)
select distinct A.BOMID,A.PARTMODELID,A.PARTONLYREVID ,1,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G) 
  and A.ONLYOPTION2 is null
  and A.ONLYOPTION3  is null
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)      

/* 2 из типа */  
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM,QTY)
select distinct A.BOMITEM ,A.MODELID ,null ,2,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G)    
  and A.OPTIONID2 in (select G.OPTID from @opt G)    
  and A.OPTIONID3 in (select G.OPTID from @opt G)    
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM,QTY)
select distinct A.BOMITEM ,A.MODELID ,null ,2,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G)    
  and A.OPTIONID2 in (select G.OPTID from @opt G)    
  and A.OPTIONID3 is null
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM,QTY)
select distinct A.BOMITEM ,A.MODELID ,null ,2,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G)    
  and A.OPTIONID2 is null
  and A.OPTIONID3 is null
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  



/* 3 из ревизии без опций */
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM,QTY)
select distinct A.BOMID,A.PARTMODELID,A.PARTONLYREVID ,3,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION is null 
  and A.ONLYOPTION2 is null   
  and A.ONLYOPTION3 is null   
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)    


  
/* 4 из типа без опций */  
insert into @res (BOMID,PARTMODELID,PARTONLYREVID,PARTMODELFROM,QTY)
select distinct A.BOMITEM ,A.MODELID ,null ,4,A.QTY
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

/* 6 совместимые модели с common настройки*/

insert into @res (BOMID,PARTMODELID,PARTMODELFROM)
select distinct BOMID,PARTMODELID,6
from (
select distinct A.BOMID,B.COMPMODELID as PARTMODELID
from @res A
left join PR_MODELTYPE_COMPM B on B.MODELID = A.PARTMODELID
where A.PARTONLYREVID is null
  and A.PARTMODELFROM not in (5,6)
  and B.MTID = @MtID   
  and B.COMPMODELID <> A.PARTMODELID
) M
where M.PARTMODELID is not null
  and not exists (select * from @res L where L.BOMID = M.BOMID and L.PARTMODELID = M.PARTMODELID and L.PARTMODELFROM = 5)


update @res set BOMIDMODELSCOUNT = (select COUNT(*) from @res B where B.BOMID = "@res".BOMID)


return


end