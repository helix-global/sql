CREATE function [dbo].[PR_FLOW_ALLOWED_old](@aID int,@aDeviceID int)
returns int as 
begin
   
  declare @condType int
  declare @Param1 int
  declare @action int
  declare @Param2 int
  
  declare @param1Value sql_variant  
  declare @param2Value sql_variant
  
  declare @param2Const sql_variant
  
   
  declare @OptGr int
  
  select 
   @condType = A.CONDITION
  ,@Param1 = A.C_PARAMID
  ,@Param2 = A.C_PARAMID2
  ,@action = A.C_ACT
  ,@OptGr = A.C_OPTGR
  ,@param2Const = A.C_PARAM2CONST
  from PR_MAP_FLOW A with (nolock)
  where A.ID = @aID
   
  if (@condType = 1) /* Parameter */
  begin
     select @param1Value = dbo.PR_DEVICE_PARAM(@aDeviceID,@Param1)
     if @Param2 is null
       set @param2Value = @param2Const
     else
       select @param2Value = dbo.PR_DEVICE_PARAM(@aDeviceID,@Param2)
          
/*
1	P1 Not Empty
2	P1 = True
3	P1 != True
4	P1 = P2
5	P1 != P2
6	P1 > P2
7	P1 >= P2
8	P1 < P2
9	P1 <= P2
10	P1 AND P2
11	P1 OR P2
12	NOT(P1) AND P2
*/     
      if (@action = 1 and @param1Value is not null)
        return 1
      else if (@action = 2) 
      begin
        if dbo.DEF_VARIANT2BOOL(@param1Value) = 1
          return 1
        return 0          
      end
      else if (@action = 3) 
      begin
        if dbo.DEF_VARIANT2BOOL(@param1Value) = 1
          return 0
        return 1  
      end
      else if (@action = 4 and @param1Value = @param2Value)
        return 1
      else if (@action = 5 and @param1Value <> @param2Value)
        return 1
      else if (@action = 6 and @param1Value > @param2Value)
        return 1
      else if (@action = 7 and @param1Value >= @param2Value)
        return 1
      else if (@action = 8 and @param1Value < @param2Value)
        return 1
      else if (@action = 9 and @param1Value <= @param2Value)
        return 1
      else if (@action = 10)        
      begin
         if (dbo.DEF_VARIANT2BOOL(@param1Value) = 1) and (dbo.DEF_VARIANT2BOOL(@param2Value) = 1)
           return 1
      end
      else if (@action = 11)        
      begin
         if (dbo.DEF_VARIANT2BOOL(@param1Value) = 1) or (dbo.DEF_VARIANT2BOOL(@param2Value) = 1)
           return 1
      end
      else if (@action = 12)        
      begin
         if (dbo.DEF_VARIANT2BOOL(@param1Value) <> 1) and (dbo.DEF_VARIANT2BOOL(@param2Value) = 1)
           return 1
      end
  end
  else if (@condType = 2) /* OptionGroup */
  begin
    
    if exists (select A.ID from PR_DEVICE_OPT A with (nolock) 
               left join PR_MODELTYPE_OPTIONS B with (nolock) on B.ID = A.OPTID
                where A.DEVICEID = @aDeviceID
                  and B.OPTGROUP = @OptGr )
        return 1            
                
    return 0
  end

  return 0
end