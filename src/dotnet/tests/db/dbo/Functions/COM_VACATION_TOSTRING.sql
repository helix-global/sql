
--KB5043:2024-11-29: Updated format message for 30,80,200.
CREATE function [dbo].[COM_VACATION_TOSTRING](@aID int,@aMode int)
returns nvarchar(max) as 
begin
  /*
  режим 2 добавляет информацию о начале и продолжительности short absence
  режим 10 (используется для hint списков Timeline) убирает длительность в рабочих днях, добавлет переносы строк 
  режим 11 добавляет html переносы строк
  */
  declare @res nvarchar(max)
  declare @dbeg datetime
  declare @dend datetime
  declare @vtype int
  declare @ptype int
  declare @shDuration int
  declare @vlen decimal(12,1)
  declare @shortStart datetime
  declare @emplID int

  select
     @dbeg = [A].[DBEG]
    ,@dend = [A].[DEND]
    ,@vtype = [A].[VACATIONTYPE]
    ,@ptype = [A].[PERIODTYPE]
    ,@shDuration = [A].[SHORTDURATION]
    ,@shortStart = [A].[SHORTSTART]
    ,@emplID = [A].[EMPLID]
  from [dbo].[COM_VACATION] [A] with(nolock)
  where [A].[ID] = @aID

  set @res = 'Vacation '
       if @vtype =  30 set @res = 'Short absence '
  else if @vtype =  15 set @res = 'Unpaid leave '
  else if @vtype =  20 set @res = 'Sick leave '
  else if @vtype =  80 set @res = 'Internal Appointment '
  else if @vtype =  90 set @res = 'Parental Leave '
  else if @vtype = 100 set @res = 'Child Care '
  else if @vtype = 200 set @res = 'Kurzarbeit '

  if @aMode = 10
    set @res = @res + char(13) + char(10)

  if @aMode = 11
    set @res = @res + '<br>'

  if @dend is null or @dbeg = @dend
  begin
    set @res = @res + convert(nvarchar,@dbeg,104)
    if @aMode = 10 and @vtype not in (30 ,80)
    begin
           if isnull(@ptype,1) = 2 set @res = @res + ' Forenoon'
      else if isnull(@ptype,1) = 3 set @res = @res + ' Afternoon'
      else                         set @res = @res + ' Full day'
     end
   end
   else
     set @res = @res + convert(nvarchar,@dbeg,104)+' - '+convert(nvarchar,@dend,104)

   if @vtype not in (30,80,200) and isnull(@aMode,0) <> 10
   begin
    /*
    if isnull(@ptype,1) = 1 /*full*/
    begin
       declare @wtID int 
       declare @CalendarID int

       select @wtID = isnull([A].[PERSONALWT],[B].[ID])
             ,@CalendarID = isnull([B2].[CALENDAR],[B].[CALENDAR])
       from [dbo].[COM_EMPLOYEE] [A] with(nolock)
         left join [dbo].[COM_WORKTIME]  [B] with(nolock) on [B].[DEPID]=[A].[DEPID] and isnull([B].[WTDEFAULT],0) = 1
         left join [dbo].[COM_WORKTIME] [B2] with(nolock) on [B2].[ID] = [A].[PERSONALWT]
       where [A].[ID] = @emplID

      set @vlen = [dbo].[COM_WORK_DAYS2](@dbeg,isnull(@dend,@dbeg),isnull(@CalendarID,1),@wtID)
     end
     else
       set @vlen = 0.5
      */
    set @vlen = [dbo].[COM_VACATION_LEN2](@aID,0)
    set @res = @res + ' (Work Days: '+convert(nvarchar,@vlen)+')'
  end

  if (@aMode in (2,10,11) and @vtype in (30,80,200))
  begin
    set @res = @res + ' from '+substring(convert(nvarchar,@shortStart,108),1,5)+' for '+convert(nvarchar,@shDuration)+' minutes'
  end
  if @aMode = 11
    set @res = @res + '<br>'

   return @res
end