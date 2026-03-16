CREATE function dbo.COM_DATE_PERIOD_SUBSTRACT_TABLE (@source as DatePeriodTableType readonly, @target as DatePeriodTableType readonly)
returns @res table (DBEG datetime, DEND datetime)
as 
begin

  declare @allPoints table (DATE datetime, ISBEGIN bit, ISSOURCE bit)

  insert into @allPoints (DATE, ISBEGIN, ISSOURCE)
  select BeginDate, 1, 1
  from @source

  insert into @allPoints (DATE, ISBEGIN, ISSOURCE)
  select EndDate, 0, 1
  from @source

  insert into @allPoints (DATE, ISBEGIN, ISSOURCE)
  select BeginDate, 1, 0
  from @target

  insert into @allPoints (DATE, ISBEGIN, ISSOURCE)
  select EndDate, 0, 0
  from @target


  declare @prevdate datetime
  declare @previsBegin bit
  declare @previsSource bit

  declare @date datetime
  declare @isBegin bit
  declare @isSource bit
    
  declare @isInsideSource bit = 0

  declare cur cursor fast_forward read_only local
  for
    select *
    from @allPoints
    order by DATE,ISSOURCE*-1,ISBEGIN

  open cur

  fetch next from cur into @date,@isBegin,@isSource

  while @@FETCH_STATUS = 0
  begin

    if (@isSource=1 and @isBegin=1)
    begin
      set @isInsideSource=1
    end

    if (@isInsideSource=1 and @isSource=1 and @isBegin=0)
    begin
      set @isInsideSource=0
    end

    if (@previsBegin is null and @previsSource is null) 
    begin
    	if (@isSource=1 and @isBegin=1) --x1
      begin
        Goto Cont
      end
    end

    if (@previsSource=1 and @previsBegin=1) --x1
    begin

    	if (@isSource=1 and @isBegin=1) --x1
      begin
        Goto Cont
      end

    	if (@isSource=1 and @isBegin=0) --x2
      begin
        insert into @res (DBEG, DEND)
        values (@prevdate, @date);
        Goto Cont
      end

    	if (@isSource=0 and @isBegin=1) --.1
      begin
        insert into @res (DBEG, DEND)
        values (@prevdate, @date);
        Goto Cont
      end

    	if (@isSource=0 and @isBegin=0) --.2
      begin          
        Goto Cont
      end

    end

    if (@previsSource=1 and @previsBegin=0) --x2
    begin

    	if (@isSource=1 and @isBegin=1) --x1
      begin
        Goto Cont
      end

    	if (@isSource=1 and @isBegin=0) --x2
      begin
        Goto Cont
      end

    	if (@isSource=0 and @isBegin=1) --.1
      begin
        Goto Cont
      end

    	if (@isSource=0 and @isBegin=0) --.2
      begin
        Goto Cont
      end

    end

    if (@previsSource=0 and @previsBegin=1) --.1
    begin

    	if (@isSource=1 and @isBegin=1) --x1
      begin
        --Goto Cont
        Goto Ret
      end

    	if (@isSource=1 and @isBegin=0) --x2
      begin
        --Goto Cont
        Goto Ret
      end

    	if (@isSource=0 and @isBegin=1) --.1
      begin
        Goto Cont
      end

    	if (@isSource=0 and @isBegin=0) --.2
      begin
        Goto Cont
      end

    end

    if (@previsSource=0 and @previsBegin=0) --.2
    begin

    	if (@isSource=1 and @isBegin=1) --x1
      begin
        Goto Cont
      end

    	if (@isSource=1 and @isBegin=0) --x2
      begin
        insert into @res (DBEG, DEND)
        values (@prevdate, @date);
        Goto Cont
      end

    	if (@isSource=0 and @isBegin=1) --.1
      begin
        if (@isInsideSource=1)
        begin
          insert into @res (DBEG, DEND)
          values (@prevdate, @date);
        end

        Goto Cont
      end

    	if (@isSource=0 and @isBegin=0) --.2
      begin
        Goto Cont
      end

    end

Cont:        	
    set @prevdate=@date
    set @previsSource=@isSource
    set @previsBegin=@isBegin

Ret: 
    fetch next from cur into @date,@isBegin,@isSource

  end

  close cur
  deallocate cur
  
  delete from @res
  where DEND <= DBEG

  return

end