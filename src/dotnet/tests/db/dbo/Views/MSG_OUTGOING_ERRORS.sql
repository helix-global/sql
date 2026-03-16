create view MSG_OUTGOING_ERRORS as 
select * from MSG_OUTGOING A with (nolock) where A.S_S = 1000125