CREATE procedure [dbo].[PR_CHECK_EQ_WORKCYCLES2] @OperationID int, @aMode int
as 
set nocount on

declare @state int
declare @processed int

declare @eq table (ID int not null)

/*в заявке сказано что брать кол-во операций с использованием оборудования 
    => если одно оборудование указано > 1 раз, взять 1 
    => distinct
*/
insert into @eq (ID)
select distinct G.EQID 
from PR_OPERATION_PARAMS G with (nolock)
where G.OPERID = @OperationID
  and G.EQID is not null

if @@rowcount = 0
begin
  set nocount off
  return
end  

select 
   @state = A.S_S
  ,@processed = isnull(A.EQ_WORKCYCLES_FLAG,0)
from PR_OPERATION A with (nolock)
where A.ID = @OperationID


if @state in (1000013,1000019) /*cmpl,cmpl w err*/ 
begin

  if @processed = 1
  begin
    /*повторный вызов не считаем повторным использованием оборудования*/
    set nocount off
    return
  end
  
  update A set A.WORKCYCLES = isnull(A.WORKCYCLES,0) + dbo.MNT_EQ_CYCLES_FROMPARAMS(@OperationID,B.ID)/*KB3719*/ 
  from MNT_PLAN_EQ A
  left join MNT_PLAN B with (nolock) on B.ID = A.VNESHID
  where A.EQID in (select ID from @eq)
    and B.SPERIOD = 100000
    and B.S_S = 1
    and B.CRMODE in (3,4)  /*by eq*/
  
  update PR_OPERATION set EQ_WORKCYCLES_FLAG = 1 where ID = @OperationID    

    
end  
else 
begin

  if @processed = 0
  begin
    /*повторный вызов не считаем повторным использованием оборудования*/
    set nocount off
    return
  end

  update A set A.WORKCYCLES = isnull(A.WORKCYCLES,0) - dbo.MNT_EQ_CYCLES_FROMPARAMS(@OperationID,B.ID)/*KB3719*/ 
  from MNT_PLAN_EQ A
  left join MNT_PLAN B with (nolock) on B.ID = A.VNESHID
  where A.EQID in (select ID from @eq)
    and B.SPERIOD = 100000
    and B.S_S = 1
    and B.CRMODE in (3,4)  /*by eq*/
  
  update PR_OPERATION set EQ_WORKCYCLES_FLAG = 0 where ID = @OperationID    

end

-- KB2654: дополнительный вызов проверки и отправки сообщений с настройкой отправки немедленно
exec [dbo].MNT_NOTIFICATION_CYCLES_NOW @OperationID

set nocount off