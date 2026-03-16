


CREATE function [dbo].[FC_FAILUREACODE_FROM_FAILEDXML](@FAILEDXML varchar(max))
returns int
as
begin
	declare @res int

	declare @xml as xml
	set @xml = cast (@FAILEDXML as xml)

	select 
		@res = xmlData.A.value('@ACode', 'VARCHAR(100)')
	from 
		@xml.nodes('Failure/Analysis/AnalysisCodes/Code') xmlData(A);

	return @res
end