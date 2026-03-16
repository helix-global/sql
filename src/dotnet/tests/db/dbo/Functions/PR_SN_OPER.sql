CREATE function [dbo].[PR_SN_OPER](@aMask nvarchar(50),@OperID int)
returns nvarchar(50) as 
begin
  if @aMask = '-'
    return '-'
  
  declare @res nvarchar(50)
  set @res = @aMask

     declare @persN nvarchar(20)
     declare @EmplNumber nvarchar(20)
  
  
  if charindex('UUUUUU',@aMask) > 0
  begin
  
     select top 1 @persN = isnull(ltrim(rtrim(A.PERSONALNO)),'000000') from COM_EMPLOYEE A with (nolock) 
      where A.ID = (select B.EMPLOYEEID from DEF_USERS B with (nolock) where B.ID = 
                    (select O.S_MR from PR_OPERATION O with (nolock) where O.ID = @OperID)
                    )
      
     set @EmplNumber = @persN
 
     if LEN(@EmplNumber) = 1
       set @EmplNumber = '00000'+@EmplNumber
     else if LEN(@EmplNumber) = 2
       set @EmplNumber = '0000'+@EmplNumber
     else if LEN(@EmplNumber) = 3
       set @EmplNumber = '000'+@EmplNumber
     else if LEN(@EmplNumber) = 4
       set @EmplNumber = '00'+@EmplNumber
     else if LEN(@EmplNumber) = 5
       set @EmplNumber = '0'+@EmplNumber
     else if LEN(@EmplNumber) > 6
       set @EmplNumber = '000000'
       
     set @res = REPLACE(@res,'UUUUUU',@EmplNumber);  

  end
  else if charindex('UUUU',@aMask) > 0
  begin
  
     select top 1 @persN = isnull(ltrim(rtrim(A.PERSONALNO)),'0000') from COM_EMPLOYEE A with (nolock) 
      where A.ID = (select B.EMPLOYEEID from DEF_USERS B with (nolock) where B.ID = 
                    (select O.S_MR from PR_OPERATION O with (nolock) where O.ID = @OperID)
                    )
      
     set @EmplNumber = @persN
 
     if LEN(@EmplNumber) = 1
       set @EmplNumber = '000'+@EmplNumber
     else if LEN(@EmplNumber) = 2
       set @EmplNumber = '00'+@EmplNumber
     else if LEN(@EmplNumber) = 3
       set @EmplNumber = '0'+@EmplNumber
     else if LEN(@EmplNumber) > 4
       set @EmplNumber = '0000'
       
     set @res = REPLACE(@res,'UUUU',@EmplNumber);
  

  end
  
  set @res = REPLACE(@res,'\','');
    
  return @res
end