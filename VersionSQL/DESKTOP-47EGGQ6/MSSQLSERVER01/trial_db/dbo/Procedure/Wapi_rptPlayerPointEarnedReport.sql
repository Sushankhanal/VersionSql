/****** Object:  Procedure [dbo].[Wapi_rptPlayerPointEarnedReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec Wapi_rptPlayerPointEarnedReport '2020-06-01 09:00','2020-06-01 09:00'

CREATE PROCEDURE [dbo].[Wapi_rptPlayerPointEarnedReport]
	-- Add the parameters for the stored procedure here
	@strDateFrom	datetime,
	@strDateTo		datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--1 FOR RPT WTransType_ID = 2
	--2 FOR RPT WTransType_ID = 4,5
	--3 FOR RPT WTransType_ID = 14,15

	--Player name, card no, point earned, earned datetime, earned location(machine name, etc)
	--Player name, card no, point earned, earned datetime, earned location(machine name, etc)
		select d.CardOwner_Name as PlayerName, a.CardPointTrans_SerialNo as CardNumber, a.CardPointTrans_Value as PointEarned,
		a.CardPointTrans_CreatedDate as EarnedDateTime, 
		ISNULL(c.Machine_Name,'') As EarnLocationName,
		(CASE WHEN (CHARINDEX('<PTMServiceSessionData>', CardPointTrans_Remarks)) = 0 THEN CardPointTrans_Remarks ELSE '' END) as PointRemarks
		from tblCardPointTrans a
		inner join tblWalletTransType b on a.CardPointTrans_Type = b.WTransType_ID
		left outer join tblPOSUser U on U.POSUser_Code = a.CardPointTrans_ApprovedBy
		left outer join  tblMachine c on a.CardPointTrans_MachineID = c.Machine_ID 
		inner join tblCard CC (NOLOCK) on CC.Card_SerialNo = a.CardPointTrans_SerialNo
		inner join tblCardOwner d on CC.Card_CardOwner_ID = d.CardOwner_ID
		inner join tblPlayerLevel e on d.CardOwner_Level = e.PlayerLevel_ID
		where 
		--a.CardPointTrans_SerialNo IN (select Card_SerialNo from tblCard where Card_CardOwner_ID = @intPlayerID)
		--AND 
		a.CardPointTrans_CreatedDate between @strDateFrom and @strDateTo 
		AND a.CardPointTrans_Type in (12)
		AND a.CardPointTrans_PointType = 0
		Order by a.CardPointTrans_CreatedDate desc, a.CardPointTrans_SerialNo
END
