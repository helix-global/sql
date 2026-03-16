
CREATE FUNCTION [dbo].[COM_EMPLOYEE_VACATIONS_BY_DATE_KB4263]
(
    @employeeId int, @DBEG date, @DEND date, @LangCode varchar(2)
)
RETURNS nvarchar(MAX)
AS
BEGIN

/* for KB4263 - list all "VACATIONS" for period in DAYS as ONE STRING
   Create: 07.09.2023 Efimov 
   Edit:
*/



	declare @ret nvarchar(MAX);


	select 
		 @ret = dbo.GROUP_CONCAT_D( 
			
			VT.VACATIONTYPE_NAME + ': ' + 
			
			case when floor(VT.DAYS_TOTAL) = 0 then '' else convert(varchar(10),FLOOR(VT.DAYS_TOTAL)) + ' '  /* + ' ' */ end +  -- integer part
			
			case when VT.DAYS_TOTAL - FLOOR(VT.DAYS_TOTAL) <> 0 then nchar(0189) + ' ' else '' end  + --half a day   
			 
			

			CASE @LangCode
				WHEN 'RU' THEN	
					case 
						when FLOOR(VT.DAYS_TOTAL) = 1 then 'день'
						else
							case when  FLOOR(VT.DAYS_TOTAL) >= 5 and (VT.DAYS_TOTAL - FLOOR(VT.DAYS_TOTAL) = 0) then 'дней' else 'дня' end
					end	
				WHEN 'DE' THEN	'T'
				ELSE			'D'
			END
			
			-- + '(' + convert(varchar(10),VT.DAYS_TOTAL)+')' 

			,', ') -- + '½'
	from 
		(select 
			SUM(VV.VACATION_DURATION_TOTAL) DAYS_TOTAL, 
			VV.VACATIONTYPE_NAME  VACATIONTYPE_NAME
		from 
			[dbo].[COM_EMPLOYEE_VACATIONS_BY_DATE](@employeeId, @DBEG, @DEND, @LangCode) VV 
		group by 
			VV.VACATIONTYPE_NAME
			) VT

	return isnull(@ret,'')
END