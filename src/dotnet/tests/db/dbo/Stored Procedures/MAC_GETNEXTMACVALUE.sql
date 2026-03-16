CREATE PROCEDURE [dbo].[MAC_GETNEXTMACVALUE]  @UserID int, @PoolN int, @ParamString nvarchar(100), @aMode int
AS
BEGIN
set nocount on

declare @poolID int
declare @st1 tinyint
declare @st2 tinyint
declare @st3 tinyint
declare @st4 tinyint
declare @st5 tinyint
declare @st6 tinyint

declare @en4 tinyint
declare @en5 tinyint
declare @en6 tinyint

declare @errMsg nvarchar(max)

select @poolID = A.ID
, @st1 = A.ST1
, @st2 = A.ST2
, @st3 = A.ST3
, @st4 = A.ST4
, @st5 = A.ST5
, @st6 = A.ST6
, @en4 = A.EN4
, @en5 = A.EN5
, @en6 = A.EN6
from MAC_POOLS A where A.NN = @PoolN

if @poolID is null
begin
    set @errMsg = 'Pool with number "'+cast(@PoolN as nvarchar(15))+'" not found.' 
	raiserror(@errMsg,16,0)
	set nocount off
	return
end

declare @result nvarchar(50)
declare @resultID int

select @result = dbo.MAC_MACSTR(A.A1,A.A2,A.A3,A.A4,A.A5,A.A6)
      ,@resultID = A.ID
from MAC_POOL_USAGE A where A.POOLID = @poolID and A.PARAMSTR = @ParamString

if @resultID is not null
begin
  select @result
  set nocount off
  return
end  

if exists(select ID from MAC_POOL_USAGE where POOLID = @poolID and A1 = @st1 and A2 = @st2 and A3 = @st3 and A4 = @en4 and A5 = @en5 and A6 = @en6)
begin
	raiserror('Pool is empty.',16,0)
	set nocount off
	return
end


declare @newid table(ID int)

insert into MAC_POOL_USAGE(GID,S_CR,S_CDT,POOLID,PARAMSTR,A1,A2,A3
,A4
,A5
,A6)
output inserted.ID into @newid
select top 1 newid(),@UserID,getdate(),@poolID,@ParamString,@st1,@st2,@st3,N4,N5,N6
from (
select
 case when A.A6 = 255 and A.A5 = 255 and A.A4 = 255 then 0 when A.A6 = 255 and A.A5 = 255 then A.A4+1 else A.A4 end as N4
,case when A.A6 = 255 and A.A5 = 255 then 0 when A.A6 = 255 then A.A5+1 else A.A5 end as N5
,case when A.A6 = 255 then 0 else A.A6+1 end as N6
from MAC_POOL_USAGE A
where A.POOLID = @poolID and A.A1 = @st1 and A.A2 = @st2 and A.A3 = @st3
union 
select @st4,@st5,@st6
)M
order by N4 desc,N5 desc,N6 desc

if isnull(@aMode,0) <> 2  /*no verbose */
begin
	select dbo.MAC_MACSTR(A.A1,A.A2,A.A3,A.A4,A.A5,A.A6)
	from MAC_POOL_USAGE A where A.ID in (select ID from @newid)
end

set nocount off
END