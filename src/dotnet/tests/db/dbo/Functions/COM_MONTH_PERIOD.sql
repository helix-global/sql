--KB5112:2024-11-29: Refactored. Added option "MAXRECURSION=0".
CREATE function [dbo].[COM_MONTH_PERIOD] (@DBeg datetime, @DEnd datetime)
returns @res table
  (
   [YY] int, [MM] int
  ,[DBEG] datetime,[DEND] datetime
  ,[DEND_NEXT] datetime,[DBEG2] datetime
  ,[DEND2] datetime,[DEND2_NEXT] datetime
  )
as
begin
  if (@DEnd < @DBeg) return;
  with
  [CTE] as
    (
    select @DBeg [DD]
    union all
    select dateadd(mm,1,[DD]) [DD]
    from [CTE]
    where dateadd(mm,1,[DD]) < @DEnd
    ),
  [CTE2] as
    (
    select distinct
       [YY]
      ,[MM]
    from (
      select
          year([DD])  [YY]
         ,month([DD]) [MM]
      from [CTE]
      union
      select
         year(@DEnd)  [YY]
        ,month(@DEnd) [MM]
      ) [M]
    ),
  [CTE3] as
    (
    select
       [YY]
      ,[MM]
      ,dateadd(mm,[MM]-1,dateadd(yy,[YY]-1900,0)) [DBEG]
    from [CTE2]
    ),
  [CTE4] as
    (
    select
       [YY]
      ,[MM]
      ,[DBEG]
      ,dateadd(dd,-1,dateadd(m,1,[DBEG])) [DEND]
    from [CTE3]
    ),
  [CTE5] as
    (
    select
       [YY]
      ,[MM]
      ,[DBEG]
      ,[DEND]
      ,case when @DBeg > [DBEG] then @DBeg else [DBEG] end [DBEG2]
      ,case when @DEnd < [DEND] then @DEnd else [DEND] end [DEND2]
    from [CTE4]
    )
insert into @res ([YY],[MM],[DBEG],[DEND],[DBEG2],[DEND2],[DEND_NEXT],[DEND2_NEXT])
  select
     [YY]
    ,[MM]
    ,[DBEG]
    ,[DEND]
    ,[DBEG2]
    ,[DEND2]
    ,dateadd(dd,1,[DEND])
    ,dateadd(dd,1,[DEND2])
  from [CTE5]
  option (maxrecursion 0)
  return
end