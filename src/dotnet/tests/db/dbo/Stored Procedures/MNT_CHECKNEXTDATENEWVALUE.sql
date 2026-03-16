create PROCEDURE [dbo].[MNT_CHECKNEXTDATENEWVALUE] @EgRowID int, @UpdateKind int, @newValue datetime, @aMode int
AS
BEGIN
  set nocount on

  /*KB1248 не давать вводить дату если последняя операция не завершена*/

  if @UpdateKind = 2 /*update*/
  begin
  
    if @newValue is not null
    begin
    
      declare @EqID int
      declare @ShiftMode int
      declare @PlanID int
      declare @EqSN nvarchar(50)
      
      select @EqID = A.EQID
            ,@ShiftMode = isnull(B.SHIFTFROMLASTCMPLDATE,0)
            ,@PlanID = B.ID
            ,@EqSN = G.SN
      from MNT_PLAN_EQ A with (nolock)
      left join MNT_PLAN B with (nolock) on B.ID = A.VNESHID
      left join EQ_EQUIPMENT G with (nolock) on G.ID = A.EQID
      where A.ID = @EgRowID
     
      if @ShiftMode = 1
      begin
         
         declare @lastOperID int
         select top 1 @lastOperID = G.ID from PR_OPERATION G with (nolock) where G.MNT_PLANID = @PlanID and G.EQID = @EqID order by G.ID desc
         
         if @lastOperID is not null
         begin
           
           if exists (select G.ID 
                        from PR_OPERATION G with (nolock) 
                       where G.ID = @lastOperID 
                         and G.COMPLETED_DT is null 
                         and G.S_S <> 1000023 /*canceled*/
                         )
                         begin
                         
                            declare @mess nvarchar(max)
                            set @mess = 'Unable to assign next execution date for '+@EqSN+' if last operation is not completed.'
                            raiserror(@mess,16,0)
                         
                         end
         
         end
         
      
      
      end
    
    end
  
  end
  
  set nocount off
END