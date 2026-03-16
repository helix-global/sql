create function [dbo].[DEF_INTRF_ITEMS_ACCESS_ONE](@UserID int, @IntrfOID int, @OnDate datetime)  
 returns @res table(ID INT)
as 
begin  
					
declare @accesableOIDs table(CLASSOID int,REPORTOID int,OPEROID int,VIEWOID int)

insert into @accesableOIDs (CLASSOID)
select A.OID from DEF_CLASSES A with (nolock)
where A.OID in (select A.CLASSOID from DEF_INTERFACE_T A with (nolock) where A.INTERFACEOID = @IntrfOID)
  and dbo.DEF_F_ACCESS(A.ARC,null,2/*use*/,@OnDate,@UserID,0) = 1

insert into @accesableOIDs (REPORTOID)
select A.OID from DEF_REPORTS A with (nolock)
where A.OID in (select A.REPORTOID from DEF_INTERFACE_T A with (nolock) where A.INTERFACEOID = @IntrfOID)
  and dbo.DEF_F_ACCESS(A.ARC,null,11/*exec*/,@OnDate,@UserID,0) = 1

insert into @accesableOIDs (OPEROID)
select OID from DEF_OPERATION A with (nolock)
where A.OID in (select A.OPEROID from DEF_INTERFACE_T A with (nolock) where A.INTERFACEOID = @IntrfOID)
  and dbo.DEF_F_ACCESS(A.ARC,null,99/*exec*/,@OnDate,@UserID,0) = 1

insert into @accesableOIDs (VIEWOID)
select OID from DEF_VIEWS A with (nolock)
where A.OID in (select A.VIEWOID from DEF_INTERFACE_T A with (nolock) where A.INTERFACEOID = @IntrfOID)
  and dbo.DEF_F_ACCESS(A.ARC,null,200/*exec*/,@OnDate,@UserID,0) = 1


insert into @res (ID)
select A.ID
from DEF_INTERFACE_T A with (nolock)
where A.INTERFACEOID = @IntrfOID
  and (A.ONLY4GROUP is null 
       or dbo.DEF_USERINGROUP(@UserID,A.ONLY4GROUP,@OnDate) = 1 
	   or dbo.DEF_USERINGROUP(@UserID,8,@OnDate) = 1  ) /*adm*/
  and (A.CLASSOID is null or A.CLASSOID in (select distinct B.CLASSOID from @accesableOIDs B))
  and (A.REPORTOID is null or A.REPORTOID in (select distinct B.REPORTOID from @accesableOIDs B))
  and (A.OPEROID is null or A.OPEROID in (select distinct B.OPEROID from @accesableOIDs B))
  and (A.VIEWOID is null or A.VIEWOID in (select distinct B.VIEWOID from @accesableOIDs B))

  
return

end