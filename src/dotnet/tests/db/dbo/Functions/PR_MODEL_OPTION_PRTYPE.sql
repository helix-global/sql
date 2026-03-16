CREATE FUNCTION [dbo].[PR_MODEL_OPTION_PRTYPE]
(
    @MODELID int, @OPTIONID int
)
RETURNS int
AS
BEGIN
    
    declare @prType int

    select @prType=O.PRTYPE
        from PR_MODEL_OPTIONS O
        where O.OPTIONID=@OPTIONID and O.MODELID=@MODELID and isnull(O.PRTYPE_OVERRIDE,0)=1

    if @prType is null
        select @prType=T.PRTYPE
            from PR_MODELTYPE_OPTIONS T
                join PR_MODELTYPE_OPTION_GR G on T.OPTGROUP=G.ID
                join PR_MODELS M on G.TYPEID=M.TYPEID
            where M.ID=@MODELID and T.ID=@OPTIONID
        
    return @prType 

END