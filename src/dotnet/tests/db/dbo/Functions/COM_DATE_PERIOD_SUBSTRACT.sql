CREATE function [dbo].[COM_DATE_PERIOD_SUBSTRACT] (@dBeg1 datetime, @dEnd1 datetime, @dBeg2 datetime, @dEnd2 datetime)
returns @res table (DBEG datetime, DEND datetime)
as 
begin

  if (@dBeg2 is null or @dEnd2 is null)
  begin
    insert into @res (DBEG, DEND)
    values (@dBeg1, @dEnd1);

    return
  end

  /*period1 is in period2*/
  if (@dBeg1 >= @dBeg2 and @dEnd1 <= @dEnd2)
  begin
    return
  end

  /*period1 does not ovelap period2*/
  if (@dBeg1 >= @dEnd2 or @dEnd1 <= @dBeg2)
  begin
    insert into @res (DBEG, DEND)
    values (@dBeg1, @dEnd1);

    return
  end

  /*period2 is in period1*/
  if (@dBeg2 >= @dBeg1 and @dEnd2 <= @dEnd1)
  begin
    insert into @res (DBEG, DEND)
    values (@dBeg1, @dBeg2);

    insert into @res (DBEG, DEND)
    values (@dEnd2, @dEnd1);

    return
  end

  /*period1 ovelaps period2 from left*/
  if (@dBeg1 <= @dBeg2)
  begin
    insert into @res (DBEG, DEND)
    values (@dBeg1, @dBeg2);

    return
  end

  /*period1 ovelaps period2 from right*/
  if (@dEnd1 >= @dEnd2)
  begin
    insert into @res (DBEG, DEND)
    values (@dEnd2, @dEnd1);

    return
  end
  
  return

end