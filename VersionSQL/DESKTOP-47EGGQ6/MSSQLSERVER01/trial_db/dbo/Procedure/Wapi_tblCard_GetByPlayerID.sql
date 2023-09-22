/****** Object:  Procedure [dbo].[Wapi_tblCard_GetByPlayerID]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetBeverageCategory '','comp02'

CREATE PROCEDURE [dbo].[Wapi_tblCard_GetByPlayerID] (
	@strUserCode		nvarchar(50),
	@intPlayerID		bigint
) AS
BEGIN
	select C.Card_ID, C.Card_SerialNo, C.Card_Point, C.Card_PointAccumulate, C.Card_Point_Tier, C.Card_Point_Hidden
	from tblCard C (NOLOCK)
	where C.Card_CardOwner_ID = @intPlayerID
END
