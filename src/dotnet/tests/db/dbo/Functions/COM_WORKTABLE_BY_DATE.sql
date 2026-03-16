create FUNCTION [dbo].[COM_WORKTABLE_BY_DATE] (@date datetime, @empId int)
RETURNS int
AS
BEGIN
    
    declare @ret int
    declare @id int

    select top 1 @ret = H.PERSONALWT, @id = H.ID
      from COM_PERSONALWORKTIME_HISTORY H with (nolock)
     where H.EMPLOYEEID=@empId
       and H.DBEG<=@date
     order by H.DBEG desc

    /*KB1592 если нет персонального графика взять дефолтный с подразделения с учетом истории смен подразделения */
    if @id is null
    begin
    
       declare @depid int = dbo.COM_EMPLOYEE_DEP_BY_DATE(@empId,@date)
       
       select top 1 @ret = B.ID 
       from COM_WORKTIME B with (nolock) 
       where B.DEPID = @depid 
         and B.WTDEFAULT = 1
       
    
    end  

    return @ret

END