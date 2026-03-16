CREATE FUNCTION [dbo].[VR_GET_RECEPTION_BUILDINGS]
(
	@RequestID int
)
RETURNS nvarchar(100)
AS
BEGIN
  
	/* KB 4905 */

	declare @res table (address nvarchar(max))
	declare @Addresses table (address nvarchar(max)) 

	insert into @Addresses(address)
		select ITEM from dbo.COM_STR2TABLE_STR((select top 1 VISITOR_ADDRESSES from VR_REQUEST where ID = @RequestID))

	/* KB5309 new address*/
	if((select top 1 address from @Addresses where address like '%K1%') is not null)
		insert into @res (address) values ('K1')

	if((select top 1 address from @Addresses where address like '%D9%') is not null)
		insert into @res (address) values ('D9')

	if((select top 1 address from @Addresses where address like '%D12%') is not null)
		insert into @res (address) values ('D12')

	if((select top 1 address from @Addresses where 
			address not like '%D9%' 
			and address not like '%D12%'
			and address not like '%K1%'  -- KB5309
			) is not null)
		insert into @res (address) values ('CB28')


	return (select dbo.GROUP_CONCAT(address) from @res)

END