CREATE procedure [dbo].[PR_CHECK_G_NUMBER]
 @Number nvarchar(50), @RowID int, @aMode int
as 
SET nocount on

  declare @nextNN nvarchar(50)
  declare @err nvarchar(max)
  
  declare @OSign nvarchar(1)
  set @OSign = 'G'
  
  declare @Origin int
  select @Origin = A.VALUEINT from DEF_SYSCONST A with (nolock) where A.LABEL = 'pr_origin'
  
  if @Origin = 1 /*IPM*/
     set @OSign = 'M'

  if @Origin = 3 /*IPGP*/
     set @OSign = 'P'

  if @Origin = 5 /*IPGRT*/
     set @OSign = 'B'


  if (@aMode = 1) /*форма операции G67*/
  begin
  
    if len(@Number) <> 9 or SUBSTRING(@Number,2,3) <> '67-' or SUBSTRING(@Number,1,1) <> @OSign
    begin   
      set @err = 'ISO Number should match "'+@OSign+'67-00000" value template.'
      raiserror(@err,16,1)
      set nocount off
      return
    end
  
    if exists(select A.ID from PR_OPERATIONS A where A.CODE = @Number and A.ID <> ISNULL(@RowID,-444)) /*можно создать ревизию уже имеющегося*/
    begin
      set nocount off
      return
    end
    
    set @nextNN = dbo.PR_NEW_G_CODE(1,@RowID)
    if @Number <> @nextNN
    begin   
      set @err = 'The value of "ISO number" field should be "'+@nextNN+'" or "<auto>" or equal to existsing operation form number.'
      raiserror(@err,16,1)
      set nocount off
      return
    end
  
  end  
  else if (@aMode = 2) /*карта G68*/
  begin

    if len(@Number) <> 9 or SUBSTRING(@Number,2,3) <> '68-' or SUBSTRING(@Number,1,1) <> @OSign
    begin   
      set @err = 'ISO Number should match "'+@OSign+'68-00000" value template.'
      raiserror(@err,16,1)
      set nocount off
      return
    end

    if exists(select A.ID from PR_MAP A where A.NN = @Number and A.ID <> ISNULL(@RowID,-444)) /*можно создать ревизию уже имеющегося*/
    begin
      set nocount off
      return
    end
    
    set @nextNN = dbo.PR_NEW_G_CODE(2,@RowID)
    if @Number <> @nextNN
    begin   
      set @err = 'The value of "ISO number" field should be "'+@nextNN+'" or "<auto>" or equal to existsing operation map number.'
      raiserror(@err,16,1)
      set nocount off
      return
    end
  
  end
  else if (@aMode = 3) /*форма отчета G69*/
  begin

    if len(@Number) <> 9 or SUBSTRING(@Number,2,3) <> '69-' or SUBSTRING(@Number,1,1) <> @OSign
    begin   
      set @err = 'ISO Number should match "'+@OSign+'69-00000" value template.'
      raiserror(@err,16,1)
      set nocount off
      return
    end

    if exists(select A.ID from PR_REPORTS A where A.CODE = @Number and A.ID <> ISNULL(@RowID,-444)) /*можно создать ревизию уже имеющегося*/
    begin
      set nocount off
      return
    end
    
    set @nextNN = dbo.PR_NEW_G_CODE(3,@RowID)
    if @Number <> @nextNN
    begin   
      set @err = 'The value of "ISO number" field should be "'+@nextNN+'" or "<auto>" or equal to existsing report number.'
      raiserror(@err,16,1)
      set nocount off
      return
    end
  
  end
  else if (@aMode = 4) /* sw&tools G73 */
  begin

    if len(@Number) <> 9 or SUBSTRING(@Number,2,3) <> '73-' or SUBSTRING(@Number,1,1) <> @OSign
    begin   
      set @err = 'ISO Number should match "'+@OSign+'73-00000" value template.'
      raiserror(@err,16,1)
      set nocount off
      return
    end
    
    set @nextNN = dbo.PR_NEW_G_CODE(4,@RowID)
    if @Number <> @nextNN
    begin   
      set @err = 'The value of "ISO number" field should be "'+@nextNN+'" or "<auto>" .'
      raiserror(@err,16,1)
      set nocount off
      return
    end
  
  end
  

SET nocount off