CREATE function [dbo].[COM_DEP_ACCESS2](@aDepID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
/* 
  @aMode: 
    1 read; 
    2 write; 
    3 только свой отдел (или дочерние) без прав
    4 view devices 
    5 designer in department
    6 view FAR in department
    7 view Shipment Requests in department
    8 designer & readonly designer in department
    9 только свой отдел (или дочерние) без прав + дизайнер параметров в чужом отделе
    10 view SW&Tools
    11 absence proposals
    12 sw&tools designer
    13 код 8 (designer & readonly designer in department) + eqipment in department
    16 projects & tasks in department
*/
begin

  declare @EmpID int
  declare @DepID int
  
  select @EmpID = A.EMPLOYEEID
        ,@DepID = B.DEPID 
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID 
  where A.ID = @aUser
  
  /*принадлежит отделу*/
  if (@DepID = @aDepID)
    return 1
    
   /* 
  if (@aMode = 3)
    return 0 
    */
    
  declare @accessCode int
  set @accessCode = -111541
  
  declare @accessCode2 int = null
  declare @accessCode3 int = null
  
  if (@aMode = 1) /*не принадлежит но ему разрешено видеть данные отдела*/
     set @accessCode = 1000040
  else if (@aMode = 2) /*edit department data*/
     set @accessCode = 1000055
  else if (@aMode = 4)
     set @accessCode = 1000099
  else if (@aMode = 5)
     set @accessCode = 1000161
  else if (@aMode = 6)
     set @accessCode = 1000167
  else if (@aMode = 7)
     set @accessCode = 1000188 
  else if (@aMode = 8)
  begin
     set @accessCode = 1000161
     set @accessCode2 = 1000178
  end
  else if (@aMode = 9)
     set @accessCode = 1000261 
  else if (@aMode = 10)
     set @accessCode = 2130025   
  else if (@aMode = 11)
     set @accessCode = 2710001
  else if (@aMode = 12)
     set @accessCode = 2710002
  else if (@aMode = 13)
  begin
     set @accessCode = 1000161
     set @accessCode2 = 1000178
     set @accessCode3 = 2130097
  end
  else if (@aMode = 16)
     set @accessCode = 2130141
     
  
  declare @tmp int
  declare @dep int
  declare @parentdep int 
  declare @iii int
  
  set @dep = @aDepID
  set @parentdep = null
  set @iii = 0

  while (1=1)
  begin
    set @parentdep = null
    
    select @tmp = dbo.DEF_F_ACCESS2(A.ARC,null,@accessCode,@aDate,@aUser,0)
          ,@parentdep = A.PARENTDEPARTMENT 
      from COM_DEPARTMENTS A with (nolock) where A.ID = @dep;
      
    if @tmp = 1
      return 1;      
    
    if (@DepID = @parentdep) /*пользователь принадлежит родительскому отделу*/
      return 1
      
    if @accessCode2 is not null
    begin
      select @tmp = dbo.DEF_F_ACCESS(A.ARC,null,@accessCode2,@aDate,@aUser,0)
      from COM_DEPARTMENTS A with (nolock) where A.ID = @dep;
      if @tmp = 1
        return 1;      
    end  
    
    if @accessCode3 is not null
    begin
      select @tmp = dbo.DEF_F_ACCESS(A.ARC,null,@accessCode3,@aDate,@aUser,0)
      from COM_DEPARTMENTS A with (nolock) where A.ID = @dep;
      if @tmp = 1
        return 1;      
    end  
    
      
    if @parentdep is null
       return 0;
      
    set @dep = @parentdep;
    set @iii = @iii + 1
    if (@iii > 100)
      return 0;
  end

  return 0;
end