CREATE function dbo.LN_CHOICE(@aOrderID int,@aDayOfWeek int)
returns nvarchar(250) as 
begin
  declare @res nvarchar(250)
 
  SELECT
     @res = STUFF(
                    (SELECT 
                        N'
' +(case isnull(A2.QUANTITY,1) when 1 then B2.VARIANTNAME else B2.VARIANTNAME + N' (' +  cast(A2.QUANTITY as nvarchar(max)) + N' pcs)' end)
                        from LN_ORDER_POSITIONS A2 with (nolock)
                        left join LN_WEEK_VARIANT B2 with (nolock) on B2.ID = A2.VARIANTID 
                        where A2.VNESHID = @aOrderID
                          and B2.DAY = @aDayOfWeek
                        FOR XML PATH(N''), TYPE
                   ).value(N'.','nvarchar(max)')
                   ,1,2, N''
              )

  return @res
end