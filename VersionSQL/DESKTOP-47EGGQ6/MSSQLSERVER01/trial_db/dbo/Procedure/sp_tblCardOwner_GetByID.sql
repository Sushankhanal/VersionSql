/****** Object:  Procedure [dbo].[sp_tblCardOwner_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblCardOwner_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN

	select *,
	ISNULL(PL.PlayerLevel_Name,'') as PlayerLevel_Name
	from tblCardOwner CO (NOLOCK)
	inner join tblPlayerLevel PL on PL.PlayerLevel_ID = CO.CardOwner_Level
	where CardOwner_ID = @intID

	select C.*, CT.CardType_Name,
				(CASE Card_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Card_StatusText from tblCard C (NOLOCK)
	inner join tblCardType CT on C.Card_Type = CT.CardType_ID  where C.Card_CardOwner_ID = @intID

END
