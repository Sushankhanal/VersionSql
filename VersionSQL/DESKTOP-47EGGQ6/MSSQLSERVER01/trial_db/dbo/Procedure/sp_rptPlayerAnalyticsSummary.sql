/****** Object:  Procedure [dbo].[sp_rptPlayerAnalyticsSummary]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptDailySales '2019-02-01','2019-02-28',0
CREATE PROCEDURE [dbo].[sp_rptPlayerAnalyticsSummary]
	-- Add the parameters for the stored procedure here
	@strStartDate		datetime,
	@strEndDate		datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @strEndDate = DATEADD(day,1,@strEndDate)
	--set @strEndDate = DATEADD(second,-1,@strEndDate)

    select CO.CardOwner_ID, CO.CardOwner_Name, 
	SUM(CardPointTrans_MoneyIn) as CardPointTrans_MoneyIn, SUM(CardPointTrans_MoneyOut) as CardPointTrans_MoneyOut, 
	SUM(CardPointTrans_Turnover) as CardPointTrans_Turnover, SUM(CardPointTrans_Won) as CardPointTrans_Won, SUM(CardPointTrans_GamePlayed) as CardPointTrans_GamePlayed, 
	SUM(CardPointTrans_PointEarned) as CardPointTrans_PointEarned,
	@strStartDate as DateFrom, @strStartDate as DateTo  from 
	tblCardPointTrans CT
	--tblCard_Trans CT
	inner join tblCard C on CT.CardPointTrans_SerialNo = C.Card_SerialNo
	inner join tblCardOwner CO on C.Card_CardOwner_ID = CO.CardOwner_ID
	where CardPointTrans_CreatedDate between @strStartDate and @strEndDate
	Group by CO.CardOwner_ID, CO.CardOwner_Name
END
