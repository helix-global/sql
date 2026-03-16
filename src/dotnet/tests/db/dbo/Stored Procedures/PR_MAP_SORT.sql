CREATE procedure [dbo].[PR_MAP_SORT] @MapID int
as 
set nocount on

declare @res table (ID int, X int, Y int, ORD int )
insert into @res (ID,X,Y)
select A.ID, A.SCHEME_X, A.SCHEME_Y from PR_MAP_OPER A with (nolock) where A.MAPID = @MapID 

declare @ttf table (OP_FROM int,OP_TO int)
insert into @ttf (OP_FROM,OP_TO)
select A.OP_FROM,A.OP_TO from PR_MAP_FLOW A with (nolock) where A.MAPID = @MapID

declare @i int 
declare @parent int 
set @i = 0
set @parent = null

update @res set ORD = @i where ID in (select OP_TO from @ttf where OP_FROM is null)

while 1=1 
begin
  set @i = @i + 1
  
  update @res set ORD = @i 
  where ID in (select A.OP_TO from @ttf A where A.OP_FROM in (select B.ID from @res B where B.ORD is not null))
    and ORD is null
  
  if @@ROWCOUNT = 0 
    break

end

update @res set ORD = 9999999 where ORD is null

declare @res2 table (ID int, SORTID int identity)
insert into @res2 (ID)
select A.ID from @res A 
 order by A.ORD,A.Y,A.X

update PR_MAP_OPER set PR_MAP_OPER.INMAPORDER = (select A.SORTID from @res2 A where A.ID = PR_MAP_OPER.ID)
 where MAPID = @MapID 

/*присвоение PR_MAP_OPER.MAPSTAGEID*/
/*
update PR_MAP_OPER set MAPSTAGEID = (select B.ID 
                                       from PR_MAP_STAGE B 
                                      where B.MAPID = @MapID 
                                        and B.SCHEME_Y <= PR_MAP_OPER.SCHEME_Y 
                                        and B.SCHEME_Y + B.SCHEME_H > PR_MAP_OPER.SCHEME_Y )
where MAPID = @MapID 
*/


set nocount off