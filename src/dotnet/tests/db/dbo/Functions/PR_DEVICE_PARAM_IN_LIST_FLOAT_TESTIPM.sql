CREATE function [dbo].[PR_DEVICE_PARAM_IN_LIST_FLOAT_TESTIPM](@DeviceID int, @ParamID int)
returns float as 
begin  
  return  (select case when isnumeric(RES) = 1 then cast(RES as float) else null end
          from 
          (SELECT TOP 1
                         CASE WHEN dp.Prm IS NULL THEN NULL    
                                  ELSE REPLACE(CAST(dp.Prm as varchar(200)),',','.') 
                         END as RES
          FROM PR_LIST_PARAMS_CACHE A with (nolock)
          OUTER APPLY (SELECT Prm = CASE WHEN A.PARAMID IS NULL THEN dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID) ELSE A.PVALUE END) dp
          where A.DEVICEID = @DeviceID and A.PARAMID = @ParamID 
         ) M
         )
end