CREATE function [dbo].[PR_LAST_CUSTOMER](@deviceId int)
returns int
as
begin

      declare @res int
      select @res = A.ID
      from
      (
            select top 1 (FR.FROMCUSTOMERID) as ID
            from dbo.PR_PRORDER_SERVICE O with (nolock) 
            left join FC_REPORT FR with (nolock) on FR.ID = O.FRID
            where O.DEVICEID = @deviceId
            order by FR.ID desc
      ) A
      return @res
end;