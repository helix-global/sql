CREATE function [dbo].[COM_VACATION_OVERRIDE](@aID int, @aEmplID int, @aMode int)
returns int as 
begin

  /* 
    возвращает 1 если весь период отсутсвия по заявке перекрыт периодом отсутствия из другой заявки 
    @aMode 1 - другая заявка д.б. утверждена (действующая)
           0 - не важно какая другая заявка


	ОТКАТ KB5180 - не проверяем если проверяемыое отсутсвие Больничный и находим Отпуск,
	такое помечено процедурой COM_VACATION_DAY_OVERRIDE
  */
  
  declare @res int
  
  declare @dbeg datetime
  declare @dend datetime
   
  set @dbeg = dbo.COM_VACATION_DBEG4(@aID)
  set @dend = dbo.COM_VACATION_DEND4(@aID)

  /* KB5180 */
  -- ьтп проверяемого отсутсвия
  declare @vacType int = (select top 1 VACATIONTYPE  from COM_VACATION where ID = @aID)
   
  if (@aMode = 1)
  begin 
	if exists (select A.ID 
	             from COM_VACATION A with (nolock) 
	             where A.EMPLID = @aEmplID
	               and A.S_S in (1000141,2130051)
	               and dbo.COM_VACATION_DBEG4(A.ID) < @dbeg
	               and dbo.COM_VACATION_DEND4(A.ID) > @dend
					and isnull(A.DEND,A.DBEG) > @dbeg - 10 --MG_08.11.22
					and A.DBEG < @dend + 10 --MG_21.09.23
	               and A.ID <> @aID
				   -- не применяем если это sickleave /* KB5180 */
				   --and A.VACATIONTYPE <> 10 -- vacation
				   --and @vacType in(20,200) -- cickleave

	           )
	           return 1
	if exists (select A.ID 
	             from COM_VACATION A with (nolock) 
	             where A.EMPLID = @aEmplID
	               and A.S_S in (1000141,2130051)
	               and dbo.COM_VACATION_DBEG4(A.ID) = @dbeg
	               and dbo.COM_VACATION_DEND4(A.ID) = @dend
					and isnull(A.DEND,A.DBEG) > @dbeg - 10 -- MG_21.09.23
					and A.DBEG < @dend + 10 --MG_21.09.23	               
	               and A.ID > @aID
				    -- не применяем если это sickleave /* KB5180 */
				   --and A.VACATIONTYPE <> 10 -- vacation
				   --and @vacType in (20,200) -- cickleave
	           )
	           return 1
  end
  else
  begin
	if exists (select A.ID 
	             from COM_VACATION A with (nolock) 
	             where A.EMPLID = @aEmplID
	               and dbo.COM_VACATION_DBEG4(A.ID) < @dbeg
	               and dbo.COM_VACATION_DEND4(A.ID) > @dend
	               and A.ID <> @aID
	           )
	           return 1
	if exists (select A.ID 
	             from COM_VACATION A with (nolock) 
	             where A.EMPLID = @aEmplID
	               and dbo.COM_VACATION_DBEG4(A.ID) = @dbeg
	               and dbo.COM_VACATION_DEND4(A.ID) = @dend
	               and A.ID > @aID
	           )
	           return 1

  end	
   
  return 0
  
end