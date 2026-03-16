

CREATE function [dbo].[PR_PRORDER_MDLS_NAV_IN_LST_KB4791](@PR_PRORDER_ID int)
returns int
begin 

/* KB4791 USA MEDICAL - Check if PR_PRORDER have a models with NAV CODE specified in lsit */
/* CREATED 27.05.2024	by EFIMOV MV */

	/* if current instance of PDB is NOT MEDICAL then ALWAYS return 0 */
	if dbo.DEF_SYS_CONST_INT('is_medical',0) <> 1 return 0

	/* for MEDICAL PDBs calculete is this order contains the model NAV codes we are looking for */
	if (select Count(A.ID )
		from PR_PRORDER A with (nolock) 
			left join PR_PRORDER_T T with (nolock) on T.PRORDERID = A.ID
			left join PR_MODELS M with (nolock) on M.ID = T.MODELID	
		where 
			A.ID = @PR_PRORDER_ID and isnull(M.CODE,'') in ( 
												/* MODEL NAV CODE TO CHECK from KB4791 */
												 'MD2300FG000566XU',
												 'MD2300FG000567XU',
												 'MD2300FG000568XU',
												 'MD2300FG000569XU',
												 'MD2300FG000570XU',
												 'MD2300FG000571XU',
												 'MD2300FG000572XU',
												 'MD2300FG000573XU',
												 'MD2300FG000574XU',
												 'MD2300FG000575XU',
												 'MD2300FG000576XU',
												 'MD2300FG000577XU'
												 -- 'YLPXMA050CWXC00G' -- DEVELOPERS TEST VALUE
												 )) > 0
	begin
		return 1
	end
	
	/* order dont have searched MODEL NAV CODES */
	return 0

end