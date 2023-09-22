/****** Object:  Procedure [dbo].[sp_tblCard_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

Create PROCEDURE [dbo].[sp_tblCard_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN

	select C.*,
				ISNULL(O.CardOwner_Name,'') as CardOwner_Name,
				ISNULL(O.CardOwner_MobileNumber,'') as CardOwner_MobileNumber,
				ISNULL(O.CardOwner_Gender,0) as CardOwner_Gender
				from tblCard C (NOLOCK)
				left outer join tblCardOwner O on C.Card_SerialNo = O.CardOwner_CardSerialNo
	where C.Card_ID = @intID
END
