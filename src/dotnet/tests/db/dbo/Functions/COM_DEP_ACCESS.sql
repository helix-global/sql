-- KB5383:2025-04-22: Refactoring.
-- KB5328:2025-03-27: Refactoring.
CREATE function [dbo].[COM_DEP_ACCESS](@CR int,@InsDepID int,@Mode int,@UserID int,@Date datetime)
returns int as
/*
  @Mode:
     1 Read;
     2 Write;
     3 Только свой отдел (или дочерние) без прав
     4 View devices
     5 Designer in department
     6 View FAR in department
     7 View Shipment Requests in department
     8 Designer & readonly designer in department
     9 Только свой отдел (или дочерние) без прав + дизайнер параметров в чужом отделе
    10 View sw&tools
    11 Absence proposals
    12 Sw&tools designer
    13 Код 8 (designer & readonly designer in department) + eqipment in department
    14 Eqipment designer in department
    15 Import&export in department
    16 Projects & tasks in department

    KB4976 (vor view Model and ModelTypes parent childs deps)
    17 Parent childs deps  (if in group "Parent Department Model Access - PDMA") use in Designer-Model/Designer-ModelTypes in view "All By Department"

*/
begin
  if isnull(@CR,-456) = isnull(@UserID,-789)
    return 1;

  declare @EmpID int
  declare @EmpDepID int

  select
     @EmpID = [u].[EMPLOYEEID]
    ,@EmpDepID = [e].[DEPID]
  from [dbo].[DEF_USERS] [u] with(nolock)
    left join [dbo].[COM_EMPLOYEE] [e] with(nolock) on [e].[ID]=[u].[EMPLOYEEID]
  where [u].[ID] = @UserID

  /*принадлежит отделу*/
  if (@EmpDepID = @InsDepID)
    return 1
   
  /* KB4976 */
  if (@Mode = 17)
  begin
    if [dbo].[DEF_USERINGROUP7](@UserID,'PDMA') = 1 and
       @InsDepID in (select [ID]
                     from [dbo].[COM_GETCHILD_DEPARTMENTS4]((select top 1 [PARENTDEPARTMENT]
                                                             from [COM_DEPARTMENTS]
                                                             where [ID] = @EmpDepID), 1))
    return 1
  end

   /*
  if (@aMode = 3)
    return 0 
    */

  declare @AccessCodeT table([AC] int)

  --#region 01: Не принадлежит но ему разрешено видеть данные отдела
  if (@Mode = 1)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000040 {View Department Data}
    insert into @AccessCodeT([AC]) values (1000040)
  end else
  --#endregion
  --#region 02: Edit department data
  if (@Mode = 2)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000055 {Edit Department Data}
    insert into @AccessCodeT([AC]) values (1000055)
  end else
  --#endregion
  --#region 04: View Department Devices
  if (@Mode = 4)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000099 {View Department Devices}
    insert into @AccessCodeT([AC]) values (1000099)
  end else
  --#endregion
  --#region 05: Designer In Department
  if (@Mode = 5)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000161 {Designer In Department}
    insert into @AccessCodeT([AC]) values (1000161)
  end else
  --#endregion
  --#region 06: View FAR In Department
  if (@Mode = 6)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000167 {FAR view In Department}
    insert into @AccessCodeT([AC]) values (1000167)
  end else
  --#endregion
  --#region 07: View Shipment Requests In Department
  if (@Mode = 7)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000188 {View Shipment Requests}
    insert into @AccessCodeT([AC]) values (1000188)
  end else
  --#endregion
  --#region 08: Designer & Readonly Designer In Department
  if (@Mode = 8)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000161 {Designer In Department}
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000178 {ReadOnly Designer In Department}
    insert into @AccessCodeT([AC]) values (1000161)
    insert into @AccessCodeT([AC]) values (1000178)
  end else
  --#endregion
  --#region 09: Только свой отдел (или дочерние) без прав + дизайнер параметров в чужом отделе
  if (@Mode = 9)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000261 {Parameters Designer}
    insert into @AccessCodeT([AC]) values (1000261)
  end else
  --#endregion
  --#region 10: View SW & Tools
  if (@Mode = 10)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=2130025 {View SW&Tools}
    insert into @AccessCodeT([AC]) values (2130025)
  end else
  --#endregion
  --#region 11: Absence Proposals In Department
  if (@Mode = 11)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=2710001 {Absence Proposals In Department}
    insert into @AccessCodeT([AC]) values (2710001)
  end else
  --#endregion
  --#region 12: SW&Tools Designer
  if (@Mode = 12)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=2710002 {SW&Tools Designer}
    insert into @AccessCodeT([AC]) values (2710002)
  end else
  --#endregion
  --#region 13: Код 8 (designer & readonly designer in department) + eqipment in department
  if (@Mode = 13)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000161 {Designer In Department}
    -- pdb://doc/?ClassLabel=def_class_methods&OID=1000178 {ReadOnly Designer In Department}
    -- pdb://doc/?ClassLabel=def_class_methods&OID=2130097 {Equipment In Department}
    insert into @AccessCodeT([AC]) values (1000161)
    insert into @AccessCodeT([AC]) values (1000178)
    insert into @AccessCodeT([AC]) values (2130097)
  end else
  --#endregion
  --#region 14: Equipment Designer In Department
  if (@Mode = 14)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=2130104 {Equipment Designer In Department}
    insert into @AccessCodeT([AC]) values (2130104)
  end else
  --#endregion
  --#region 15: Import & Export In Department
  if (@Mode = 15)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=2130106 {Import & Export In Department}
    insert into @AccessCodeT([AC]) values (2130106)
  end else
  --#endregion
  --#region 16: Projects & Tasks In Department
  if (@Mode = 16)
  begin
    -- pdb://doc/?ClassLabel=def_class_methods&OID=2130141 {Projects & Tasks In Department}
    insert into @AccessCodeT([AC]) values (2130141)
  end
  --#endregion
  if not exists(select * from @AccessCodeT)
  begin
    insert into @AccessCodeT([AC]) values (-111541)
  end

  declare @AccessResult int
  declare @CurrentDepID int
  declare @ParentDepID int
  declare @I int
  declare @ARC int

  set @CurrentDepID = @InsDepID
  set @ParentDepID = null
  set @I = 0

  while (1=1)
  begin
    set @ParentDepID = null

    select top 1
       @ARC = [dep].[ARC]
      ,@ParentDepID = [dep].[PARENTDEPARTMENT]
    from [dbo].[COM_DEPARTMENTS] [dep] with(nolock)
    where [dep].[ID] = @CurrentDepID;

    if (@EmpDepID = @ParentDepID) /*пользователь принадлежит родительскому отделу*/
    begin
      return 1
    end

    if exists(select *
              from @AccessCodeT [a]
              where [dbo].[DEF_F_ACCESS](@ARC,null,[a].[AC],@Date,@UserID,0)=1)
    begin
      return 1
    end

    if @ParentDepID is null
      break;

    set @CurrentDepID = @ParentDepID;
    set @I = @I + 1
    if (@I > 100)
      break;
  end

  return 0;
end