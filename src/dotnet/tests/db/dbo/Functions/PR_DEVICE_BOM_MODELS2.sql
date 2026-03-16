CREATE function [dbo].[PR_DEVICE_BOM_MODELS2] (@DeviceID int,@OnlyMTID int,@NotInstalled int)
returns @res table (BOMID int,PARTMODELID int,COMPATIBLECODES nvarchar(max),COMPATIBLENAMES nvarchar(max),COMPATIBLEIDS nvarchar(max))
as 
begin

declare @tmp table (ID int identity, BOMID int,PARTMODELID int,BOMIDMODELSNUMBER int, MODELCODE nvarchar(50), MODELNAME nvarchar(250))

insert into @tmp (BOMID,PARTMODELID,MODELCODE,MODELNAME)
select A.BOMID,A.PARTMODELID,B.CODE,B.NAME
from dbo.PR_DEVICE_BOM_MODELS (@DeviceID) A
left join PR_MODELS B with (nolock) on B.ID = A.PARTMODELID
where @OnlyMTID is null or @OnlyMTID = B.TYPEID
order by A.BOMID,A.PARTMODELFROM

if (@NotInstalled = 1)
begin
  delete from @tmp where BOMID in (select B.BOMID from PR_DEVICE_BOM B where B.DEVICEID = @DeviceID)

end

update @tmp set BOMIDMODELSNUMBER = (select COUNT(*) from @tmp B where B.BOMID = "@tmp".BOMID and B.ID <= "@tmp".ID) 

insert into @res (BOMID,PARTMODELID)
select BOMID,PARTMODELID 
from @tmp 
where BOMIDMODELSNUMBER = 1

update @res set COMPATIBLEIDS = (select dbo.IDCONCAT(B.PARTMODELID) from @tmp B where B.BOMID = "@res".BOMID and B.BOMIDMODELSNUMBER > 1)

update @res 
   set COMPATIBLECODES = stuff((select B.MODELCODE + ', ' AS [text()]
		from @tmp B where B.BOMID = "@res".BOMID and B.BOMIDMODELSNUMBER > 1
		for XML PATH(''), TYPE).value('(./text())[1]','nvarchar(max)'),1,2,'')
      ,COMPATIBLENAMES = stuff((select B.MODELNAME + ', ' AS [text()]
		from @tmp B where B.BOMID = "@res".BOMID and B.BOMIDMODELSNUMBER > 1
		for XML PATH(''), TYPE).value('(./text())[1]','nvarchar(max)'),1,2,'')
 where COMPATIBLEIDS is not null
  
update @res 
   set COMPATIBLECODES = dbo.COM_CUT_LAST(COMPATIBLECODES,',')
      ,COMPATIBLENAMES = dbo.COM_CUT_LAST(COMPATIBLENAMES,',')
where COMPATIBLEIDS is not null      

  
return

end