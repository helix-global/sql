
-- KB4395:2024-02-29: Removes record if DBEG=DEND.
CREATE function [dbo].[COM_DATE_PERIOD_OVERLAP]
  (
    @dBeg1 datetime
   ,@dEnd1 datetime
   ,@dBeg2 datetime
   ,@dEnd2 datetime
  )
returns @res table
  (
    DBEG datetime
   ,DEND datetime
  )
as
  begin

    if (@dBeg1 is null or @dEnd1 is null or @dBeg2 is null or @dEnd2 is null)
    begin
      return
    end

    /* are overlaped */
    if (@dBeg1 >= @dBeg2 and @dBeg1 <= @dEnd2 or @dEnd1 >= @dBeg2 and @dEnd1 <= @dEnd2 or @dBeg2 >= @dBeg1 and @dEnd2 <= @dEnd1 or @dBeg1 >= @dBeg2 and @dEnd1 <= @dEnd2)
    begin
      insert into @res (DBEG, DEND)
      values (dbo.COM_MAX_DATE(@dBeg1, @dBeg2), dbo.COM_MIN_DATE(@dEnd1, @dEnd2));
      delete from @res where DBEG=DEND
      return
    end
  
    return

  end