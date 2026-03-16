CREATE function [dbo].[PR_OPER_ISACTIVE_4REVISION](@aRevisionID int,@aOperID int,@aMode int)
returns int as 
begin
  
  if @aOperID is null return null
   
  declare @condType int
  declare @Param1 int
  declare @action int
  declare @Param2 int
  
  declare @param1Value sql_variant  
  declare @param2Value sql_variant
 
  declare @param2Const sql_variant

  declare @param1ValueStr nvarchar(max)
  declare @param2ValueStr nvarchar(max)
   
  declare @bomItem int
  declare @bomItem2 int


  select
   @condType = A.CONDITION
  ,@Param1 = A.C_PARAMID
  ,@Param2 = A.C_PARAMID2
  ,@action = A.C_ACT
  ,@param2Const = A.C_PARAM2CONST
  ,@bomItem = A.C_BOMID
  ,@bomItem2 = A.C_BOMID2
  from PR_MAP_OPER A with (nolock)
  where A.ID = @aOperID  
  
  if isnull(@condType,0) = 0
    return 1  

  if (@condType = 1) /* Parameter */
  begin
     declare @p1datetype int
     declare @p2datetype int
          
     select @p1datetype = A.DATATYPE from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @Param1

     if @p1datetype = 3 /*float*/
        set @param1Value = dbo.PR_REVISION_PARAM_FLOAT(@aRevisionID,@Param1)
     else if @p1datetype = 4 /*int*/
        set @param1Value = dbo.PR_REVISION_PARAM_INT(@aRevisionID,@Param1)
     else  
        set @param1Value = dbo.PR_REVISION_PARAM(@aRevisionID,@Param1)
     
     if @Param2 is null
     begin
       /*приведение к типу первого параметра, иначе некоторые сравнения не работают т.к. в @param2Const - строка*/
       
       if @p1datetype = 3 /*float*/
         set @param2Value = dbo.DEF_VARIANT2FLOAT(@param2Const)
       else if @p1datetype = 4 /*int*/
         set @param2Value = dbo.DEF_VARIANT2INT(@param2Const)
       else  
         set @param2Value = @param2Const
         
     end  
     else
     begin
       select @p2datetype = A.DATATYPE from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @Param2

       if @p2datetype = 3 /*float*/
	  	 set @param2Value = dbo.PR_REVISION_PARAM_FLOAT(@aRevisionID,@Param2)
	   else if @p2datetype = 4 /*int*/
	     set @param2Value = dbo.PR_REVISION_PARAM_INT(@aRevisionID,@Param2)
	   else  
	     set @param2Value = dbo.PR_REVISION_PARAM(@aRevisionID,@Param2)
       
     end  

     set @param1ValueStr = CAST(@param1Value as nvarchar(max))
     set @param2ValueStr = CAST(@param2Value as nvarchar(max))
          
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
13	P1 contains all items of P2
14	P1 contains some items of P2
15  P1 contains no items of P2
16  P1 and P2 are not empty
17  P1 or P2 is not empty
18	NOT(P1) OR P2    /*KB1387*/
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
      else if (@action = 13)        
      begin
         if dbo.COM_STRING_CONTAINS(@param1ValueStr,@param2ValueStr,1) = 1 
           return 1
      end
      else if (@action = 14)        
      begin
         if dbo.COM_STRING_CONTAINS(@param1ValueStr,@param2ValueStr,2) = 1 
           return 1
      end
      else if (@action = 15)        
      begin
         if dbo.COM_STRING_CONTAINS(@param1ValueStr,@param2ValueStr,2) = 0 
           return 1
      end
	  else if (@action = 16)
	  begin
		if(@param1Value is not null and @param2Value is not null)
		  return 1
	  end
	  else if(@action = 17)
	  begin
		if(@param1Value is not null or @param2Value is not null)
		  return 1
	  end
      else if (@action = 18)        
      begin
         if (dbo.DEF_VARIANT2BOOL(@param1Value) <> 1) or (dbo.DEF_VARIANT2BOOL(@param2Value) = 1)
           return 1
      end
	  
	  return 0
     
  end

  
  return null
end