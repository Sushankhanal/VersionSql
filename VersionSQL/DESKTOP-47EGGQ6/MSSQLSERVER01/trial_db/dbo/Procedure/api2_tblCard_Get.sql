/****** Object:  Procedure [dbo].[api2_tblCard_Get]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[api2_tblCard_Get]
	-- Add the parameters for the stored procedure here
	@strCardNumber	nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Card_ID as CardID, Card_SerialNo as CardNumber, Card_Balance as CardBalance, Card_Point as CardPoint,
	Card_Balance_Cashable_No as CardBalanceNoCashable, Card_Balance_Cashable as CardBalanceCashable, 
	Card_PointAccumulate as CardPointAccumulate,
	Card_Point_Tier as CardPointTier, Card_Point_Hidden as CardPointHidden      
	from tblCard a (NOLOCK) where a.Card_SerialNo = @strCardNumber
END
