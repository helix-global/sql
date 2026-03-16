create function dbo.PR_NEW_MCO(@UserID int, @OnDate datetime)
returns @return table(ID int,FLAG int,S_S int,USERINPROGRESS int)
as 
begin  

  insert into @return (ID,S_S,USERINPROGRESS)
  select A.ID,A.S_S,A.USERINPROGRESS
  from PR_OPERATION A with (nolock)
  where A.COMPLETED_DT is null
  
  update @return set FLAG = dbo.PR_IS_MY_CURRENT_OPERATION(ID, S_S, USERINPROGRESS, @UserID ,@OnDate)
  
  return 
end