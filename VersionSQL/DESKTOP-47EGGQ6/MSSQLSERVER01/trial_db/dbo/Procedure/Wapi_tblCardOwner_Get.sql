/****** Object:  Procedure [dbo].[Wapi_tblCardOwner_Get]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetBeverageCategory '','comp02'

CREATE PROCEDURE [dbo].[Wapi_tblCardOwner_Get] (
	@strUserCode	nvarchar(50)
) AS
BEGIN
	select C.CardOwner_ID, C.CardOwner_Name, C.CardOwner_MobileNumber,
	(C.CardOwner_Name + ' - ' + C.CardOwner_MobileNumber) as CardOwner_NameMobile from tblCardOwner C (NOLOCK)
END
