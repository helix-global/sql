


CREATE view [dbo].[SL_OPTIONS_DEPR]
AS
	select CODE from (
		select UPPER(O.CODE) as CODE
			from PR_MODELTYPE_OPTIONS O
				join PR_MODELTYPE_OPTION_GR G on O.OPTGROUP=G.ID
			where O.S_S in(1000148) and O.PRTYPE in(1,2)
				and exists(select ID from PR_MT4CONFIG P where P.MTID=G.TYPEID)
				and (dbo.COM_TOP_PARENT_DEPCODE(O.DEPID) = 'IPGL' or	
						(O.DEPID=290 /*and right(O.CODE,2)='GU'*/))
		except
		select UPPER(O.CODE) as CODE
			from PR_MODELTYPE_OPTIONS O
				join PR_MODELTYPE_OPTION_GR G on O.OPTGROUP=G.ID
			where O.S_S in(4180002) and O.PRTYPE in(1,2)
				and exists(select ID from PR_MT4CONFIG P where P.MTID=G.TYPEID)
				and (dbo.COM_TOP_PARENT_DEPCODE(O.DEPID) = 'IPGL' or	
						(O.DEPID=290 /*and right(O.CODE,2)='GU'*/))
					) T
	--order by CODE