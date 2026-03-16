CREATE function [dbo].[PR_FLOW_OR_OPER_ALLOWED_TXT](@aFlowID int,@aOperID int)
returns nvarchar(300) as 
begin
   
  if @aFlowID is null and @aOperID is null return null
   
  declare @condType int
  declare @Param1 int
  declare @action int
  declare @Param2 int
  
  declare @param1Name nvarchar(250)
  declare @param2Name nvarchar(250)
  declare @param2Const sql_variant
   
  declare @OptGr int
  declare @bomItem int
  declare @bomItem2 int
  declare @OptID int
  
  if @aFlowID is not null
  begin
	  select 
	   @condType = isnull(A.CONDITION,0)
	  ,@Param1 = A.C_PARAMID
	  ,@Param2 = A.C_PARAMID2
	  ,@action = A.C_ACT
	  ,@OptGr = A.C_OPTGR
	  ,@param2Const = A.C_PARAM2CONST
	  ,@bomItem = A.C_BOMID	  
	  ,@bomItem2 = A.C_BOMID2
	  ,@OptID = A.C_OPTID	  
	  from PR_MAP_FLOW A with (nolock)
	  where A.ID = @aFlowID
  end
  else
  begin
	  select 
	   @condType = isnull(A.CONDITION,0)
	  ,@Param1 = A.C_PARAMID
	  ,@Param2 = A.C_PARAMID2
	  ,@action = A.C_ACT
	  ,@OptGr = A.C_OPTGR
	  ,@param2Const = A.C_PARAM2CONST
	  ,@bomItem = A.C_BOMID	 
	  ,@bomItem2 = A.C_BOMID2 
	  ,@OptID = A.C_OPTID
	  from PR_MAP_OPER A with (nolock)
	  where A.ID = @aOperID
  end
   
  if  @condType = 0
    return null
   
  if (@condType = 1) /* Parameter */
  begin
          
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
     select @param1Name = A.NAME from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @Param1
     if @Param2 is null
        set @param2Name = CAST(@param2Const as nvarchar)
     else
       select @param2Name = A.NAME from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @Param2


     return 'By parameter: '+
     case @action 
     when 1 then @param1Name+' Not Empty'
     when 2 then @param1Name+' = True'
     when 3 then @param1Name+' != True'
     when 4 then @param1Name+' = '+@param2Name
     when 5 then @param1Name+' != '+@param2Name
     when 6 then @param1Name+' > '+@param2Name
     when 7 then @param1Name+' >= '+@param2Name     
     when 8 then @param1Name+' < '+@param2Name     
     when 9 then @param1Name+' <= '+@param2Name     
     when 10 then @param1Name+' AND '+@param2Name     
     when 11 then @param1Name+' OR '+@param2Name     
     when 12 then 'NOT('+@param1Name+') AND '+@param2Name    
     when 13 then @param1Name+' contains all items of '+@param2Name    
     when 14 then @param1Name+' contains some items of '+@param2Name    
     when 15 then @param1Name+' contains no items of '+@param2Name   
	 when 16 then @param1Name+' and '+@param2Name + ' are not null'
	 when 17 then @param1Name+' or '+@param2Name + ' is not null'
	 when 18 then 'NOT('+@param1Name+') OR '+@param2Name    
     else '' 
     end
     
  end
  else if (@condType = 2) /* OptionGroup Existence*/
  begin
    
    declare @optGrName nvarchar(250)
    select @optGrName = A.NAME from PR_MODELTYPE_OPTION_GR A with (nolock) where A.ID = @OptGr 
                
    return 'By Options Group Existence: '+@optGrName
  end
  else if (@condType = 6) /* OptionGroup Absence*/
  begin
    
    declare @optGrName2 nvarchar(250)
    select @optGrName2 = A.NAME from PR_MODELTYPE_OPTION_GR A with (nolock) where A.ID = @OptGr 
                
    return 'By Options Group Absence: '+@optGrName2
  end
  else if (@condType = 3) /* BOM Item Existence */
  begin
    
    declare @bomItemName nvarchar(350)
    select @bomItemName = A.NAME from PR_MODELTYPE_BOM A with (nolock) where A.ID = @bomItem 
    
    if @bomItem2 is not null
    begin
       select @bomItemName = isnull(@bomItemName,'') + ', '+ A.NAME from PR_MODELTYPE_BOM A with (nolock) where A.ID = @bomItem2 
    end 
                
    return 'By BOM Item Existence: '+@bomItemName
  end
  else if (@condType = 4) /* BOM Item Absence */
  begin
    
    declare @bomItemName2 nvarchar(250)
    select @bomItemName2 = A.NAME from PR_MODELTYPE_BOM A with (nolock) where A.ID = @bomItem 
                
    return 'By BOM Item Absence: '+@bomItemName
  end
  else if (@condType = 5) /* By Option Group or BOM Item Existence */
  begin
    
    return 'By Option Group or BOM Item Existence'
    
  end  
  else if (@condType = 7) /* By FAR Existence in state 'created' */
  begin
    
     return 'By FAR Existence in state "Created"'
  
  end 
  else if (@condType = 8) /* Option Existence*/
  begin
    
    declare @optName nvarchar(250)
    select @optName = A.NAME from PR_MODELTYPE_OPTIONS A with (nolock) where A.ID = @OptID
                
    return 'By Option Existence: '+@optName
  end
  else if (@condType = 9) /* Option Absence*/
  begin
    
    declare @optName22 nvarchar(250)
    select @optName22 = A.NAME from PR_MODELTYPE_OPTIONS A with (nolock) where A.ID = @OptID
                
    return 'By Option Absence: '+@optName22
  end
   

  return null
end