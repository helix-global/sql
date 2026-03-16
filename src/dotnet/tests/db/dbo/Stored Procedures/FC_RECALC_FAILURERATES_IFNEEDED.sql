CREATE PROCEDURE [dbo].[FC_RECALC_FAILURERATES_IFNEEDED]  
AS
BEGIN
  set nocount on

  declare @now datetime = getdate()

  declare @mm int
  declare @yy int
  declare @dd int
 
  set @yy = year(@now)   
  set @mm = month(@now)  
  set @dd = day(@now) 
  
  if @dd in (5,10,15,20,25) and datepart(hour,@now) > 20
  begin
  
      if not exists (select * from FC_FAILURERATES_RECALCDATES where YY = @yy and MM = @mm and DD = @dd)
      BEGIN
		
		declare @ddd datetime = dbo.COM_ENCODE_DATE(@yy,@mm,@dd)
		declare @ddd1 datetime = dateadd(month,-1,@ddd)
		declare @ddd2 datetime = dateadd(month,-2,@ddd)
		/*
		exec FC_RECALC_FAILURERATES @ddd2, null, 0
		
		WAITFOR DELAY '00:03' 
		*/
		
		exec FC_RECALC_FAILURERATES @ddd1, null, 0
		
		WAITFOR DELAY '00:03' 
		
		exec FC_RECALC_FAILURERATES @ddd, null, 0
		
		insert into FC_FAILURERATES_RECALCDATES (YY,MM,DD) values (@yy,@mm ,@dd)
      
      END
      
  
  end
  
  set nocount off
END