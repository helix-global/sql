CREATE FUNCTION [dbo].[COM_SUBSTRACT_ADDEDWT_BAL](@addedTimeID int,@dbeg datetime,@dend datetime,@emplID int)
RETURNS decimal(16,2)
AS
BEGIN
/*
по KB2631 вычитать duration переработки с типом Time Adjustment Account если они попали в этот период
*/
    declare @ret decimal(16,2)
    set @ret = DATEDIFF(MINUTE, @dbeg, @dend)
    
    declare @substr decimal(16,2)
    
    select @substr = DATEDIFF(MINUTE, DBEG, DEND)
    from (
      select case when A.DBEG < @dbeg then @dbeg else A.DBEG end as DBEG
            ,case when A.DEND > @dend then @dend else A.DEND end as DEND
        from COM_ADDED_WORKTIME A with (nolock)
        where A.EMPLID = @emplID
          and A.ID <> @addedTimeID
          and A.OVERTIME_TYPE = 2        
          and A.DBEG <= @dend
          and A.DEND >= @dbeg
    )M
    
    if isnull(@substr,0) > 0
    begin
    
      set @ret = @ret - isnull(@substr,0)
      if @ret > 0
        set @ret = 0
    
    end
    
    
    return @ret
END