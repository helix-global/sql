CREATE function dbo.IT_TASK_DONEDATE(@TaskId int)
returns datetime as 
begin
  
  declare @doneInVersion nvarchar(50)
  declare @lastModifiedDate datetime

  select 
    @doneInVersion=DONEINVERSION
    ,@lastModifiedDate=S_MDT
  from IT_TASKS
  where ID=@TaskId

  if (@doneInVersion is null)
  begin
    return @lastModifiedDate
  end 

  if (@doneInVersion like '1.%')
  begin
    return @lastModifiedDate
  end 

  if (@doneInVersion like '20%')
  begin
    declare @parts table (IDX int, PART int)
    insert into @parts
    select idx, cast(splitdata as int)
    from dbo.COM_STRING_SPLIT(@doneInVersion, '.')

    return 
      cast(
        cast((select PART from @parts where IDX=0) as nvarchar(20)) +
        right('00'+cast((select PART from @parts where IDX=1) as nvarchar(20)),2) +
        right('00'+cast((select PART from @parts where IDX=2) as nvarchar(20)),2) + ' ' +
        cast((select PART/100 from @parts where IDX=3) as nvarchar(20)) + ':' +
        cast((select PART%100 from @parts where IDX=3) as nvarchar(20)) + ':00'
      as datetime)

  end 

  return null   

end