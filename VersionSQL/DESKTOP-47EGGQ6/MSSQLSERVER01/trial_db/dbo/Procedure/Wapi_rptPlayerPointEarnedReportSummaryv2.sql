/****** Object:  Procedure [dbo].[Wapi_rptPlayerPointEarnedReportSummaryv2]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec Wapi_rptPlayerPointEarnedReport '2020-06-01 09:00','2022-06-01 09:00'

CREATE PROCEDURE [dbo].[Wapi_rptPlayerPointEarnedReportSummaryv2]
	-- Add the parameters for the stored procedure here
	@strDateFrom	datetime,
	@strDateTo		datetime,
	@strCardType	nvarchar(500) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--1 FOR RPT WTransType_ID = 2
	--2 FOR RPT WTransType_ID = 4,5
	--3 FOR RPT WTransType_ID = 14,15

	if @strCardType = 0 
	BEGIN
	 SET @strCardType = ''
	END

	--Player name, card no, point earned, earned datetime, earned location(machine name, etc)
	--Player name, card no, point earned, earned datetime, earned location(machine name, etc)
		select d.CardOwner_Name as PlayerName, a.CardPointTrans_SerialNo as CardNumber, SUM(a.CardPointTrans_Value) as PointEarned
		from tblCardPointTrans a
		inner join tblCard CC (NOLOCK) on CC.Card_SerialNo = a.CardPointTrans_SerialNo
		inner join tblCardOwner d on CC.Card_CardOwner_ID = d.CardOwner_ID
		LEFT join tblPlayerLevel e on d.CardOwner_IDType = e.PlayerLevel_ID
		where 
		CardPointTrans_PointType = 0 
		AND
		a.CardPointTrans_CreatedDate between @strDateFrom and @strDateTo 

		AND a.CardPointTrans_Type in (12)
		AND (CASE WHEN LTRIM(RTRIM(@strCardType)) = '' THEN 1 ELSE CASE WHEN CC.Card_Type IN (select NAME from dbo.fnSplitstringToTable(@strCardType)) THEN 1 ELSE 0 END END) > 0
		Group by d.CardOwner_Name, a.CardPointTrans_SerialNo
		Order by d.CardOwner_Name, a.CardPointTrans_SerialNo
END
