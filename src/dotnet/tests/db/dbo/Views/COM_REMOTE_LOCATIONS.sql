CREATE view COM_REMOTE_LOCATIONS as
select A.ID,A.GID,A.S_CR,A.S_CDT,A.S_MR,A.S_MDT,A.CODE,A.NAME from COM_REMOTE A where A.CODE <> dbo.DEF_SYS_CONST_STR('com_remotelocation_code',null)