CREATE FUNCTION [dbo].[PR_FP_KB3937_STATE_ID](@aDeviceID int, @aSettID int, @mode int)
RETURNS int
AS
BEGIN
   /*KB3937 возвращает статус по настройкам */
   /* @mode = 22  - возвращает статус всегда, независимо от признака видимости. 
      для правого списка - 22
      для левого списка (где нужно выводить только помеченные "видмостью") -  не 22 
   */
    declare @ret int
    declare @visibl int
    

    select top 1 @ret = A.ID, @visibl = isnull(A.VISIBLEINLIST,0)
    from PR_FP_PLANNING_SETTINGS_ST A with(nolock)
    left join PR_FP_PLANNING_SETTINGS B with(nolock) on B.ID = A.VNESHID
    where B.ID = @aSettID
      /*and A.VISIBLEINLIST = 1*/
      and exists (select J.ID 
                    from PR_OPERATION J with(nolock) 
                    where J.DEVICEID = @aDeviceID 
                    and J.OPERTYPEID = A.OPERID 
                    and ((A.OPERSTATE = 2 and J.S_S in (1000013,1000019)/*cmpl.,cmpl.err*/) or (A.OPERSTATE = 1 and J.S_S in (1000031/*in progress*/)))
                    )
      order by A.POSORDER desc             
 
 
    if @ret is not null and @visibl = 0 and isnull(@mode,0) <> 22
      set @ret = null
    

    return @ret

END