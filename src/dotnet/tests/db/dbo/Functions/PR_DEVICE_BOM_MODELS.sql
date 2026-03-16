CREATE function [dbo].[PR_DEVICE_BOM_MODELS] (@DeviceID int)
returns @res table (BOMID int,PARTMODELID int,PARTONLYREVID int,PARTMODELFROM int,BOMIDMODELSCOUNT int,OPTQTY int, OPTION1 int, QTY decimal(10,4))
as 
begin

declare @allBOM table (BOMID int)

declare @opt table (OPTID int,BOMID int,FROMBOMID int,OPTQTY int)

declare @RevID int
declare @MtID int

select @RevID = F.REVID 
      ,@MtID = M.TYPEID
from PR_DEVICE F with (nolock) 
left join PR_MODELS M on M.ID = F.MODELID
where F.ID = @DeviceID

insert into @allBOM (BOMID)
select A.ID from PR_MODELTYPE_BOM A with (nolock) where A.MTID = @MtID

insert into @opt (OPTID,BOMID,OPTQTY)
select G.OPTID,G.BOMID,G.QUANTITY from PR_DEVICE_OPT G where G.DEVICEID = @DeviceID

/* 1 из ревизии с опциями */
insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMID,A.PARTMODELID,1,A.ONLYOPTION,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMID)
  and A.ONLYOPTION2 in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMID)  
  and A.ONLYOPTION3 in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMID)    
  and A.BOMID in (select BOMID from @allBOM)  
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMID,A.PARTMODELID,1,A.ONLYOPTION,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G )
  and A.ONLYOPTION2 in (select G.OPTID from @opt G )  
  and A.ONLYOPTION3 in (select G.OPTID from @opt G )    
  and A.BOMID in (select BOMID from @allBOM)  
delete from @allBOM where BOMID in (select BOMID from @res)  


insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMID,A.PARTMODELID,1,A.ONLYOPTION,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMID)    
  and A.ONLYOPTION2 in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMID)    
  and A.ONLYOPTION3 is null    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMID,A.PARTMODELID,1,A.ONLYOPTION,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G )    
  and A.ONLYOPTION2 in (select G.OPTID from @opt G )    
  and A.ONLYOPTION3 is null    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  


insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMID,A.PARTMODELID,1,A.ONLYOPTION,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMID)    
  and A.ONLYOPTION2 is null  
  and A.ONLYOPTION3 is null    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMID,A.PARTMODELID,1,A.ONLYOPTION,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION in (select G.OPTID from @opt G )    
  and A.ONLYOPTION2 is null  
  and A.ONLYOPTION3 is null    
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  


/* 2 из типа */  
insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMITEM ,A.MODELID ,2,A.OPTIONID,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMITEM)    
  and A.OPTIONID2 in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMITEM)    
  and A.OPTIONID3 in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMITEM)    
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMITEM ,A.MODELID ,2,A.OPTIONID,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G )    
  and A.OPTIONID2 in (select G.OPTID from @opt G )    
  and A.OPTIONID3 in (select G.OPTID from @opt G )    
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  


insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMITEM ,A.MODELID ,2,A.OPTIONID,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMITEM)    
  and A.OPTIONID2 in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMITEM)    
  and A.OPTIONID3 is null
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMITEM ,A.MODELID ,2,A.OPTIONID,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G )    
  and A.OPTIONID2 in (select G.OPTID from @opt G )    
  and A.OPTIONID3 is null
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  


insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMITEM ,A.MODELID ,2,A.OPTIONID,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G where G.BOMID is null or G.BOMID = A.BOMITEM)    
  and A.OPTIONID2 is null
  and A.OPTIONID3 is null
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  

insert into @res (BOMID,PARTMODELID,PARTMODELFROM,OPTION1,QTY)
select distinct A.BOMITEM ,A.MODELID ,2,A.OPTIONID,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID in (select G.OPTID from @opt G )    
  and A.OPTIONID2 is null
  and A.OPTIONID3 is null
  and A.BOMITEM in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)  


if exists(select A.BOMID 
            from @allBOM A
            left join @opt G on G.BOMID = A.BOMID
            where G.OPTID is not null
              and G.BOMID is not null) 
begin
/* остались модели для BOMItems cо следующими номерами "optional collimator 2", "optional collimator 3" и т.д. */
/* 6 модели для множественных опций */

  update @opt set FROMBOMID = dbo.PR_FIND_FIRST_BOMID(@MtID,BOMID)
  where BOMID is not null

	insert into @res (BOMID,PARTMODELID,PARTMODELFROM)
	select distinct A.BOMID ,B.MODELID ,6
	from @opt A 
	left join PR_MODELTYPE_OPTIONS_BOM B with (nolock) on B.BOMITEM = A.FROMBOMID
	left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = B.TYPEID
	where A.FROMBOMID is not null
	  and AA.MTID = @MtID
	  and B.OPTIONID in (select G.OPTID from @opt G where G.BOMID = A.BOMID)    
	  and B.OPTIONID2 is null
	  and B.OPTIONID3 is null
	  and A.BOMID in (select BOMID from @allBOM)
  
  delete from @allBOM where BOMID in (select BOMID from @res)  
end 

update @res set OPTQTY = (select sum(B.OPTQTY) from @opt B where B.OPTID = "@res".OPTION1 and B.BOMID is null)
update @res set OPTQTY = 1 where OPTQTY is null

/* 3 из ревизии без опций */
insert into @res (BOMID,PARTMODELID,PARTMODELFROM,QTY)
select distinct A.BOMID,A.PARTMODELID,3,A.QTY
from PR_REV_BOM2 A with (nolock) 
where A.REVID = @RevID
  and A.ONLYOPTION is null 
  and A.ONLYOPTION2 is null   
  and A.ONLYOPTION3 is null   
  and A.BOMID in (select BOMID from @allBOM)
delete from @allBOM where BOMID in (select BOMID from @res)    
  
/* 4 из типа без опций */  
insert into @res (BOMID,PARTMODELID,PARTMODELFROM,QTY)
select distinct A.BOMITEM ,A.MODELID ,4,A.QTY
from PR_MODELTYPE_OPTIONS_BOM A  with (nolock) 
left join PR_MODELTYPE_COMMON AA  with (nolock) on AA.ID = A.TYPEID
where AA.MTID = @MtID
  and A.OPTIONID is null
  and A.OPTIONID2 is null
  and A.OPTIONID3 is null  
  and A.BOMITEM in (select BOMID from @allBOM)
  

/* 5 совместимые модели */

insert into @res (BOMID,PARTMODELID,PARTMODELFROM)
select distinct BOMID,PARTMODELID,5
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