/****** Object:  Procedure [dbo].[sp_tblCardType_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

Create PROCEDURE [dbo].[sp_tblCardType_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN

	select C.* from tblCardType C (NOLOCK)
	where C.CardType_ID = @intID
END
