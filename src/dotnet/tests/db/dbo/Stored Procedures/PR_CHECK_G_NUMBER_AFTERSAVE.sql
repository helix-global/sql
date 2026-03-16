CREATE procedure [dbo].[PR_CHECK_G_NUMBER_AFTERSAVE]
  @RowID int, @aMode int
as 
  SET nocount on

  /* проверка что такой-же номер, если он есть, то в том-же типе модели */

  declare @mtid int
  declare @Number nvarchar(100)
  declare @err nvarchar(max)

  if (@aMode = 1) /*форма операции G(M)67*/
  begin
  
    select @Number = A.CODE
         , @mtid = A.MTID
      from PR_OPERATIONS A where A.ID = @RowID
  
    if exists(select A.ID from PR_OPERATIONS A where A.CODE = @Number and A.MTID <> @mtid) 
    begin
      set @err = 'Operation form with ISO Number "'+@Number+'" cannot be used in different model types.'
      raiserror(@err,16,1)
      set nocount off
      return
    end
  
  end  
  else if (@aMode = 2) /*карта G(M)68*/
  begin

    select @Number = A.NN
         , @mtid = A.MTID
      from PR_MAP A where A.ID = @RowID
  
    if exists(select A.ID from PR_MAP A where A.NN = @Number and A.MTID <> @mtid) 
    begin
      set @err = 'Production map with ISO Number "'+@Number+'" cannot be used in different model types.'
      raiserror(@err,16,1)
      set nocount off
      return
    end

  
  end
  else if (@aMode = 3) /*форма отчета G(M)69*/
  begin

    select @Number = A.CODE
         , @mtid = A.MTID
      from PR_REPORTS A where A.ID = @RowID
  
    if exists(select A.ID from PR_REPORTS A where A.CODE = @Number and A.MTID <> @mtid) 
    begin
      set @err = 'Report form with ISO Number "'+@Number+'" cannot be used in different model types.'
      raiserror(@err,16,1)
      set nocount off
      return
    end
  
  end
  

SET nocount off