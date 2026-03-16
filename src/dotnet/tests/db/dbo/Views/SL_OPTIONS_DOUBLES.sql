



CREATE view [dbo].[SL_OPTIONS_DOUBLES]
AS
select UPPER(O.CODE) as CODE,  COUNT(O.ID) as COUNT_ID, newid() as GID, 1 as S_CR, getdate() as S_CDT, null as S_MR, null as S_MDT
        from PR_MODELTYPE_OPTIONS O
            join PR_MODELTYPE_OPTION_GR G on O.OPTGROUP=G.ID
where O.S_S in(4180002/*,1000148*/) and O.PRTYPE in(1,2)
    and exists(select ID from PR_MT4CONFIG P where P.MTID=G.TYPEID)
group by UPPER(O.CODE)
having COUNT(O.ID)>1
GO
GRANT SELECT
    ON OBJECT::[dbo].[SL_OPTIONS_DOUBLES] TO [IPG-DOMAIN\IPGL_Integr_MSCRM]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[SL_OPTIONS_DOUBLES] TO [EMEA\DEPCS]
    AS [dbo];

