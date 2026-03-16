create PROCEDURE [dbo].[PM_PLAN_CREATE] @PlanID int, @UserID int, @aMode int
AS
BEGIN
  set nocount on

/*KB3388
4) При создании нового Development Plan, если у сотрудника имеются неутвержденные планы (статус Created), созданные ранее, то переводить их так же в статус Deprecated, наравне и с утвержденными планами.
*/

  declare @emplid int
  
  select @emplid = A.EMPLID
   from PM_DEV_PLAN A 
   where A.ID = @PlanID

  
  update PM_DEV_PLAN set S_S = 2130059 /*deprecated*/ , S_MR = @UserID, S_MDT = getdate()
  where EMPLID = @emplid
    and ID < @PlanID
    and S_S = 1
  

END