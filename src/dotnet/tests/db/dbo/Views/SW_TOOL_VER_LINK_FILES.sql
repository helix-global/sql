
CREATE view [dbo].[SW_TOOL_VER_LINK_FILES]
as

    select F.*, L.VNESHID
        from SW_TOOL_VER_FILES F
            join (select distinct S.VERID, S.VNESHID from SW_TOOL_VERSION_LINKS S) L on F.VERID=L.VERID