/****** Object:  Procedure [dbo].[Wapi_rptPlayerFundBalanceReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptDailySales '2019-02-01','2019-02-28',0
CREATE PROCEDURE [dbo].[Wapi_rptPlayerFundBalanceReport]
	-- Add the parameters for the stored procedure here
	@intCardTypeID		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	select ROW_NUMBER() OVER(ORDER BY CO.CardOwner_Name)  AS RowNo,
	CO.CardOwner_Name as PlayerName, C.Card_SerialNo as CardNumber, 
	C.Card_Balance as BalanceCredit, 
	C.Card_Balance_Cashable_No as RestrictedPromo, C.Card_Balance_Cashable as NonRestrictedPromo, CT.CardType_Name as CardLevel
	from  tblCard C (NOLOCK)
	inner join tblCardOwner CO (NOLOCK) on C.Card_CardOwner_ID = CO.CardOwner_ID
	inner join tblCardType CT (NOLOCK) on CT.CardType_ID = C.Card_Type
	where CO.CardOwner_Name <> ''
	AND (CASE WHEN @intCardTypeID = -1 THEN 1 ELSE CASE WHEN CT.CardType_ID = @intCardTypeID THEN 1 ELSE 0 END END) > 0

END
