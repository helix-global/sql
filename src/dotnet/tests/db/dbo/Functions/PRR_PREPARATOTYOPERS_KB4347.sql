create function [dbo].[PRR_PREPARATOTYOPERS_KB4347](@DepID int, @dbeg datetime, @dend datetime)
returns decimal(18,2)
as
begin

  declare @res decimal(18,2)
  
  select @res = sum(coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0))
       from PR_OPERATION A with (nolock)  
  left join PR_OPERATION_TIME TT with (nolock) on TT.OPERID = A.ID 
  left join COM_EMPLOYEE E with (nolock) on E.ID = TT.EMPID  
      WHERE A.ORDERID is null  
        and A.EQID is null  
        and E.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,1))  
        and A.S_S in (1000013,1000019)  
        and A.COMPLETED_DT > @dbeg
        and A.COMPLETED_DT < @dend
        and TT.ID is not null
        OPTION (FORCE ORDER) 
  
  
  return isnull(@res,0) / 60 
  
end;