CREATE function [dbo].[PR_FLOW_OR_OPER_ALLOWED](@FlowID int,@MapOperID int,@DeviceID int)
returns int as
begin
  if @FlowID is null and @MapOperID is null return null

  declare @CondType int
  declare @Param1 int
  declare @Action int
  declare @Param2 int

  declare @Param1Value sql_variant
  declare @Param2Value sql_variant

  declare @Param2Const sql_variant

  declare @Param1ValueStr nvarchar(max)
  declare @Param2ValueStr nvarchar(max)

  declare @OptGr int
  declare @OptGroups table (OptGroupID int)  /* KB3613 Список Option Groups */ 
  declare @BomItem int
  declare @BomItem2 int
  declare @OptID int

  if @FlowID is not null
  begin
    select
       @CondType = [A].[CONDITION]
      ,@Param1 = [A].[C_PARAMID]
      ,@Param2 = [A].[C_PARAMID2]
      ,@Action = [A].[C_ACT]
      ,@OptGr = [A].[C_OPTGR]
      ,@Param2Const = [A].[C_PARAM2CONST]
      ,@BomItem = [A].[C_BOMID]
      ,@BomItem2 = [A].[C_BOMID2]
      ,@OptID = [A].[C_OPTID]
    from [dbo].[PR_MAP_FLOW] A with(nolock)
    where [A].[ID] = @FlowID
  end
  else
  begin
    select
       @CondType = [A].[CONDITION]
      ,@Param1 = [A].[C_PARAMID]
      ,@Param2 = [A].[C_PARAMID2]
      ,@Action = [A].[C_ACT]
      ,@OptGr = [A].[C_OPTGR]
      ,@Param2Const = [A].[C_PARAM2CONST]
      ,@BomItem = [A].[C_BOMID]
      ,@BomItem2 = [A].[C_BOMID2]
      ,@OptID = [A].[C_OPTID]
    from [dbo].[PR_MAP_OPER] [A] with(nolock)
    where [A].[ID] = @MapOperID

    /* KB3613 Список Option Groups */ 
    --добавляем из списка Option Groups если есть
    --все группы по данной операции кроме указанной в поле одной группы [@OptGr] (ее добавим в список позднее)
    insert into @OptGroups
      select
        [OPT_MDL_GRP_ID]
      from [dbo].[PR_MAP_OPER_OPT_GROUPS]
      where [MAPOPERID] = @MapOperID
        and [OPT_MDL_GRP_ID] <> isnull(@OptGr,0)
  end

  /* KB3613 Список Option Groups */ 
  -- довставляем из простой Option Group (один изи определенных выше) если есть в список
  -- так как далее будем использовать не простое сравнение а вхождение в список
  if @OptGr is not null
  begin
    insert into @OptGroups select @OptGr
  end

  if isnull(@CondType,0) = 0
    return 1

  if (@CondType = 1) /* Parameter */
  begin
    declare @p1datetype int
    declare @p2datetype int

    select @p1datetype = [A].[DATATYPE] from [dbo].[PR_MODELTYPE_PARAMS] [A] with(nolock) where [A].[ID] = @Param1

    if @p1datetype = 3 /*float*/
      set @Param1Value = [dbo].[PR_DEVICE_PARAM_FLOAT](@DeviceID,@Param1)
    else if @p1datetype = 4 /*int*/
      set @Param1Value = [dbo].[PR_DEVICE_PARAM_INT](@DeviceID,@Param1)
    else
      set @Param1Value = [dbo].[PR_DEVICE_PARAM](@DeviceID,@Param1)

    if @Param2 is null
    begin
      /*приведение к типу первого параметра, иначе некоторые сравнения не работают т.к. в @Param2Const - строка*/
      if @p1datetype = 3 /*float*/
        set @Param2Value = [dbo].[DEF_VARIANT2FLOAT](@Param2Const)
      else if @p1datetype = 4 /*int*/
        set @Param2Value = [dbo].[DEF_VARIANT2INT](@Param2Const)
      else
        set @Param2Value = @Param2Const
    end else
    begin
      select @p2datetype = [A].[DATATYPE] from [dbo].[PR_MODELTYPE_PARAMS] [A] with(nolock) where [A].[ID] = @Param2

      if @p2datetype = 3 /*float*/
        set @Param2Value = [dbo].[PR_DEVICE_PARAM_FLOAT](@DeviceID,@Param2)
      else if @p2datetype = 4 /*int*/
        set @Param2Value = [dbo].[PR_DEVICE_PARAM_INT](@DeviceID,@Param2)
      else
        set @Param2Value = [dbo].[PR_DEVICE_PARAM](@DeviceID,@Param2)
    end

    set @Param1ValueStr = cast(@Param1Value as nvarchar(max))
    set @Param2ValueStr = cast(@Param2Value as nvarchar(max))

    /*
    1  P1 Not Empty
    2  P1 = True
    3  P1 != True
    4  P1 = P2
    5  P1 != P2
    6  P1 > P2
    7  P1 >= P2
    8  P1 < P2
    9  P1 <= P2
    10  P1 AND P2
    11  P1 OR P2
    12  NOT(P1) AND P2
    13  P1 contains all items of P2
    14  P1 contains some items of P2
    15  P1 contains no items of P2
    16  P1 and P2 are not empty
    17  P1 or P2 is not empty
    18  NOT(P1) OR P2    /*KB1387*/
    */
    if (@Action = 1 and @Param1Value is not null)
      return 1
    else if (@Action = 2)
    begin
      if [dbo].[DEF_VARIANT2BOOL](@Param1Value) = 1
        return 1
      return 0
    end
    else if (@Action = 3) 
    begin
      if [dbo].[DEF_VARIANT2BOOL](@Param1Value) = 1
        return 0
      return 1
    end
    else if (@Action = 4 and @Param1Value = @Param2Value)
      return 1
    else if (@Action = 5 and @Param1Value <> @Param2Value)
      return 1
    else if (@Action = 6 and @Param1Value > @Param2Value)
      return 1
    else if (@Action = 7 and @Param1Value >= @Param2Value)
      return 1
    else if (@Action = 8 and @Param1Value < @Param2Value)
      return 1
    else if (@Action = 9 and @Param1Value <= @Param2Value)
      return 1
    else if (@Action = 10)
    begin
      if ([dbo].[DEF_VARIANT2BOOL](@Param1Value) = 1) and ([dbo].[DEF_VARIANT2BOOL](@Param2Value) = 1)
        return 1
    end
    else if (@Action = 11)
    begin
      if ([dbo].[DEF_VARIANT2BOOL](@Param1Value) = 1) or ([dbo].[DEF_VARIANT2BOOL](@Param2Value) = 1)
        return 1
    end
    else if (@Action = 12)
    begin
      if ([dbo].[DEF_VARIANT2BOOL](@Param1Value) <> 1) and ([dbo].[DEF_VARIANT2BOOL](@Param2Value) = 1)
        return 1
    end
    else if (@Action = 13)
    begin
      if [dbo].[COM_STRING_CONTAINS](@Param1ValueStr,@Param2ValueStr,1) = 1
        return 1
    end
    else if (@Action = 14)
    begin
      if [dbo].[COM_STRING_CONTAINS](@Param1ValueStr,@Param2ValueStr,2) = 1
        return 1
    end
    else if (@Action = 15)
    begin
      if [dbo].[COM_STRING_CONTAINS](@Param1ValueStr,@Param2ValueStr,2) = 0
        return 1
    end
    else if (@Action = 16)
    begin
      if(@Param1Value is not null and @Param2Value is not null)
        return 1
    end
    else if(@Action = 17)
    begin
    if(@Param1Value is not null or @Param2Value is not null)
      return 1
    end
    else if (@Action = 18)
    begin
      if ([dbo].[DEF_VARIANT2BOOL](@Param1Value) <> 1) or ([dbo].[DEF_VARIANT2BOOL](@Param2Value) = 1)
        return 1
    end
  end
  else if (@CondType = 2) /* OptionGroup Existence*/
  begin
    if exists (select [A].[ID]
               from [dbo].[PR_DEVICE_OPT] [A] with(nolock)
                 left join [dbo].[PR_MODELTYPE_OPTIONS] [B] with(nolock) on [B].[ID] = [A].[OPTID]
               where [A].[DEVICEID] = @DeviceID
               --and [B].[OPTGROUP] = @OptGr)
                 and [B].[OPTGROUP] in (select [OptGroupID] from @OptGroups)) --KB3613
      return 1
    return 0
  end
  else if (@CondType = 6) /* OptionGroup Absence*/
  begin
    if exists (select [A].[ID]
               from [dbo].[PR_DEVICE_OPT] [A] with(nolock)
                 left join [dbo].[PR_MODELTYPE_OPTIONS] [B] with(nolock) on [B].[ID] = [A].[OPTID]
               where [A].[DEVICEID] = @DeviceID
               --and [B].[OPTGROUP] = @OptGr)
                 and [B].[OPTGROUP] in (select [OptGroupID] from @OptGroups)) --KB3613
        return 0
    return 1
  end
  else if (@CondType = 3) /* BOM Item Existence */
  begin
    if @BomItem is not null
      if exists (select *
                 from [dbo].[PR_DEVICE_BOM_MODELS](@DeviceID) [A]
                 where [A].[BOMID] = @BomItem
                   and [A].[BOMIDMODELSCOUNT] > 0)
        return 1

    if @BomItem2 is not null
      if exists (select *
                 from [dbo].[PR_DEVICE_BOM_MODELS](@DeviceID) [A]
                 where [A].[BOMID] = @BomItem2
                   and [A].[BOMIDMODELSCOUNT] > 0)
        return 1

    return 0
  end
  else if (@CondType = 4) /* BOM Item Absence */
  begin
    if exists (select *
               from [dbo].[PR_DEVICE_BOM_MODELS](@DeviceID) [A]
               where [A].[BOMID] = @BomItem
                 and [A].[BOMIDMODELSCOUNT] > 0)
      return 0

    return 1
  end
  else if (@CondType = 5) /* By Option Group or BOM Item Existence */
  begin
    if exists (select [A].[ID]
               from [dbo].[PR_DEVICE_OPT] [A] with(nolock)
                 left join [dbo].[PR_MODELTYPE_OPTIONS] [B] with(nolock) on [B].[ID] = [A].[OPTID]
               where [A].[DEVICEID] = @DeviceID
               --and [B].[OPTGROUP] = @OptGr)
                 and [B].[OPTGROUP] in (select [OptGroupID] from @OptGroups)) --KB3613
        return 1

    if @BomItem is not null
      if exists (select *
                 from [dbo].[PR_DEVICE_BOM_MODELS](@DeviceID) [A]
                 where [A].[BOMID] = @BomItem
                   and [A].[BOMIDMODELSCOUNT] > 0)
        return 1

    if @BomItem2 is not null
      if exists (select *
                 from [dbo].[PR_DEVICE_BOM_MODELS](@DeviceID) [A]
                 where [A].[BOMID] = @BomItem2
                   and [A].[BOMIDMODELSCOUNT] > 0)
        return 1

    return 0
  end
  else if (@CondType = 7) /* By FAR Existence in state 'created' */
  begin
    if exists (select [ID]
               from [dbo].[FC_REPORT] [A] with(nolock)
               where [A].[DEVICEID] = @DeviceID
                 and [A].[S_S] = 1)
       return 1

    return 0
  end
  else if (@CondType = 8) /* Option Existence*/
  begin
    if exists (select [A].[ID]
               from [dbo].[PR_DEVICE_OPT] [A] with(nolock)
               where [A].[DEVICEID] = @DeviceID
                 and [A].[OPTID] = @OptID)
        return 1

    return 0
  end
  else if (@CondType = 9) /* Option Absence*/
  begin
    if not exists (select [A].[ID]
                   from [dbo].[PR_DEVICE_OPT] [A] with(nolock)
                   where [A].[DEVICEID] = @DeviceID
                     and [A].[OPTID] = @OptID)
        return 1
    return 0
  end
  return 0
end