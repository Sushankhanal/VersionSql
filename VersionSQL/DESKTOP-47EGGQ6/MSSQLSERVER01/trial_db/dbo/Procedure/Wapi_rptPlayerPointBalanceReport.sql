/****** Object:  Procedure [dbo].[Wapi_rptPlayerPointBalanceReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec Wapi_rptPlayerFundBalanceReport 0
CREATE PROCEDURE [dbo].[Wapi_rptPlayerPointBalanceReport]
	-- Add the parameters for the stored procedure here
	@intCardTypeID		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	select ROW_NUMBER() OVER(ORDER BY CO.CardOwner_Name)  AS RowNo,
	CO.CardOwner_Name as PlayerName, C.Card_SerialNo as CardNumber, 
	C.Card_Point as BalancePoint, 
	C.Card_Point_Tier as TierPoint, C.Card_PointAccumulate as LifePoint, 
	C.Card_Point_Hidden as HiddenPoint,
	CT.CardType_Name as CardLevel
	from  tblCard C (NOLOCK)
	inner join tblCardOwner CO (NOLOCK) on C.Card_CardOwner_ID = CO.CardOwner_ID
	inner join tblCardType CT (NOLOCK) on CT.CardType_ID = C.Card_Type
	where CO.CardOwner_Name <> ''
	AND (CASE WHEN @intCardTypeID = -1 THEN 1 ELSE CASE WHEN CT.CardType_ID = @intCardTypeID THEN 1 ELSE 0 END END) > 0

END
