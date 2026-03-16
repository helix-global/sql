
CREATE FUNCTION [dbo].[SL_MTOPTIONS2CRM]
(
	@mode int /* 1 - approved, 2 -  deprecated */
)
RETURNS @T TABLE 
(
	ID int
	, TS binary(8)
)
AS
BEGIN
	
	if @mode=1
		insert into @T (ID, TS)
		select O.ID, O.TS
			from PR_MODELTYPE_OPTIONS O
				join PR_MODELTYPE_OPTION_GR G on O.OPTGROUP=G.ID
			where O.PRTYPE in(1,2)
				and O.S_S=4180002
				and (dbo.COM_TOP_PARENT_DEPCODE(O.DEPID)='IPGL'
						or
					(O.DEPID=290/*IPGP Beam Delivery*/ /*and right(O.CODE,2)='GU'*/))
				and G.TYPEID in(select MTID from PR_MT4CONFIG)
				and O.CODE not in(select CODE from SL_OPTIONS_DOUBLES)

	if @mode=2
		insert into @T (ID, TS)
		select O.ID, O.TS
			from PR_MODELTYPE_OPTIONS O
			where O.CODE in(select CODE from SL_OPTIONS_DEPR)
	
	RETURN 
END