CREATE function [dbo].[PR_OPTIONS_BY_ORDERROW] (@OrderRowID int)
returns @res table (ID int identity,OPTID int,BOMID int,QTY int,N int,BOMNAME nvarchar(100),NFROM int)
as 
begin

insert into @res (OPTID,BOMID,QTY,N,BOMNAME)
select A.OPTID,C.SNBOMID,1,B.N,D.NAME
from PR_PRORDER_TO A with (nolock)
left join PR_MODELTYPE_OPTIONS C with (nolock) on C.ID = A.OPTID
left join COM_NUMBER B with (nolock) on B.N > 0 and B.N <= A.QUANTITY
left join PR_MODELTYPE_BOM D with (nolock) on D.ID = C.SNBOMID
where A.OPID = @OrderRowID
  and isnull(C.SNTRACKING,0) = 1
  
insert into @res (OPTID,BOMID,QTY,N,BOMNAME)
select A.OPTID,C.SNBOMID,A.QUANTITY,1,D.NAME
from PR_PRORDER_TO A with (nolock)
left join PR_MODELTYPE_OPTIONS C with (nolock) on C.ID = A.OPTID
left join PR_MODELTYPE_BOM D with (nolock) on D.ID = C.SNBOMID
where A.OPID = @OrderRowID
  and isnull(C.SNTRACKING,0) = 0

declare @nnn table (BOMID int,N int)
insert into @nnn(BOMID,N)
select A.BOMID,count(*)
from @res A
where A.BOMID is not null
group by A.BOMID
having count(*) > 1

declare @nn int
declare @CuBOMID int
declare nxx cursor local read_only for select BOMID from @nnn 
open nxx 
WHILE 1=1
BEGIN
    FETCH NEXT FROM nxx INTO @CuBOMID;
    IF @@FETCH_STATUS<>0 BREAK;
    set @nn = 0
    update @res set @nn = @nn + 1, N = @nn  where BOMID = @CuBOMID
END
close nxx;
deallocate nxx;

declare @mtID int
select @mtID = B.TYPEID
from PR_PRORDER_T A with (nolock)
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
where A.ID = @OrderRowID

update @res set NFROM = dbo.PR_OPTIONBOM_N_FROMNAME(BOMNAME) where N > 1
update @res set BOMNAME = dbo.PR_OPTIONBOM_NAME_FROM_N(BOMNAME,N,isnull(NFROM,1)) where N > 1

update @res set BOMID = (select B.ID 
                           from PR_MODELTYPE_BOM B with (nolock) 
                          where B.MTID = @mtID
                            and upper(B.NAME) = upper("@res".BOMNAME))
where N > 1

  
return

end