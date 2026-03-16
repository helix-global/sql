CREATE function [dbo].[SM_CASES_BY_SLA] (@DepID int, @mtID int, @custID int, @modelID int)
returns @res table (ID int )
as 
begin

    insert into @res (ID)
        select A.ID
            from SM_SERVICECASE A with (nolock)
                left join SM_SERVICECASE_ITEMS I with (nolock) on A.ID=I.VNESHID
                left join PR_DEVICE D with (nolock) on I.DEVICEID=D.ID
                left join PR_PRORDER O with (nolock) on A.SERVORDID=O.ID
                left join PR_PRORDER_SERVICE T with (nolock) on O.ID=T.ORDERID
                left join PR_MODELS M  with (nolock) on D.MODELID=M.ID
            where A.SDEPID=@DepID
                and (@mtID is null or @mtID = M.TYPEID)
                and (@custID is null or @custID = O.CUSTOMERID)
                and (@modelID is null or @modelID = D.MODELID)
    
  return

end