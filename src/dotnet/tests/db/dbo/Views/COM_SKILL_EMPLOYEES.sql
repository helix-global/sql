



CREATE view [dbo].[COM_SKILL_EMPLOYEES] 
AS

    select ES.ID, ES.GID as GID, ES.S_CDT, ES.S_CR, ES.S_MDT, ES.S_MR, ES.S_S, E.ID as EMPLOYEEID, S.ID as SKILLID, ES.S_CDT as SKILL_DATE, D.EXPIRATION_DATE,
        case WHEN D.EXPIRATION_DATE<=getdate() then 1 else NULL end as EXPIRED, ES.CAN_TRAIN
    from dbo.COM_EMPLOYEE E with (nolock)
        join dbo.COM_EMPLOYEE_SKILL ES with (nolock) on E.ID=ES.EMPLOYEEID
        join dbo.COM_SKILLS S with (nolock) on ES.SKILLID=S.ID
        join dbo.COM_EMPLOYEE_SKILL_EXPIRATION_DATES D with (nolock) on ES.EMPLOYEEID=D.EMPLOYEEID and ES.SKILLID=D.SKILLID