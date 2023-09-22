/****** Object:  Procedure [dbo].[Wapi_rptPlayerPointAdjustmentReportv2]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec Wapi_rptPlayerPointAdjustmentReport '2018-01-01','2021-12-31',-1
CREATE PROCEDURE [dbo].[Wapi_rptPlayerPointAdjustmentReportv2]
	-- Add the parameters for the stored procedure here
	@strDateFrom	datetime,
	@strDateTo		datetime,
	@intPointType   smallint, -- 1 FOR NEGATIVE, 0 FOR +, -1 FOR ALL
	@strCardType	nvarchar(500) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @strEndDate = DATEADD(day,1,@strEndDate)
	--set @strEndDate = DATEADD(second,-1,@strEndDate)
	--print @strEndDate

	--Declare @strOwnderName nvarchar(50) = ''
	--select @strOwnderName = CardOwner_Name from tblCardOwner where CardOwner_ID = @intPlayerID

	--1 FOR RPT WTransType_ID = 2
	--2 FOR RPT WTransType_ID = 4,5
	--3 FOR RPT WTransType_ID = 14,15

	--1 FOR NEGATIVE, 0 FOR +, -1 FOR ALL

	--Player name, card no, adjustment point , adjustment by, adjust datetime, point type
	IF @intPointType = 1
	BEGIN
		select d.CardOwner_Name as PlayerName, a.CardPointTrans_SerialNo as CardNumber, a.CardPointTrans_Value as AdjustedPoint,
		ISNULL(CardPointTrans_ApprovedBy,'') as AdjustmentBy, a.CardPointTrans_CreatedDate as AdjustDate, b.WTransType_Name as PointTransType,
		--a.CardPointTrans_ID, a.CardPointTrans_Code, a.CardPointTrans_CreatedDate, 
		--a.CardPointTrans_CreatedBy, b.WTransType_Name,
		--a.CardPointTrans_Value, c.Machine_Name As LocationName, d.CardOwner_IC, e.PlayerLevel_Name,
		(CASE WHEN (CHARINDEX('<PTMServiceSessionData>', CardPointTrans_Remarks)) = 0 THEN CardPointTrans_Remarks ELSE '' END) as PointRemarks
		--a.CardPointTrans_Remarks, 
		--ISNULL(u.POSUser_Name,'') as POSUser_Name, CardPointTrans_ApprovedDate
		from tblCardPointTrans a
		inner join tblWalletTransType b on a.CardPointTrans_Type = b.WTransType_ID
		left outer join tblPOSUser U on U.POSUser_Code = a.CardPointTrans_ApprovedBy
		--INNER JOIN  tblMachine c on a.CardPointTrans_MachineID = c.Machine_ID 
		inner join tblCard CC (NOLOCK) on CC.Card_SerialNo = a.CardPointTrans_SerialNo
		inner join tblCardOwner d on CC.Card_CardOwner_ID = d.CardOwner_ID
		LEFT join tblPlayerLevel e on d.CardOwner_IDType = e.PlayerLevel_ID
		where 
		--a.CardPointTrans_SerialNo IN (select Card_SerialNo from tblCard where Card_CardOwner_ID = @intPlayerID)
		--AND 
		a.CardPointTrans_CreatedDate between @strDateFrom and @strDateTo 
		AND a.CardPointTrans_Type in (4,5)
		AND a.CardPointTrans_Value < 0 
		AND (CASE WHEN @strCardType = '' THEN 1 ELSE CASE WHEN CC.Card_Type IN (select NAME from dbo.fnSplitstringToTable(@strCardType)) THEN 1 ELSE 0 END END) > 0
				Order by a.CardPointTrans_CreatedDate desc, a.CardPointTrans_SerialNo
	END
	ELSE IF @intPointType = 0
	BEGIN
		select d.CardOwner_Name as PlayerName, a.CardPointTrans_SerialNo as CardNumber, a.CardPointTrans_Value as AdjustedPoint,
		ISNULL(CardPointTrans_ApprovedBy,'') as AdjustmentBy, a.CardPointTrans_CreatedDate as AdjustDate, b.WTransType_Name as PointTransType,
		--a.CardPointTrans_ID, a.CardPointTrans_Code, a.CardPointTrans_CreatedDate, 
		--a.CardPointTrans_CreatedBy, b.WTransType_Name,
		--a.CardPointTrans_Value, c.Machine_Name As LocationName, d.CardOwner_IC, e.PlayerLevel_Name,
		(CASE WHEN (CHARINDEX('<PTMServiceSessionData>', CardPointTrans_Remarks)) = 0 THEN CardPointTrans_Remarks ELSE '' END) as PointRemarks
		--a.CardPointTrans_Remarks, 
		--ISNULL(u.POSUser_Name,'') as POSUser_Name, CardPointTrans_ApprovedDate
		from tblCardPointTrans a
		inner join tblWalletTransType b on a.CardPointTrans_Type = b.WTransType_ID
		left outer join tblPOSUser U on U.POSUser_Code = a.CardPointTrans_ApprovedBy
		--INNER JOIN  tblMachine c on a.CardPointTrans_MachineID = c.Machine_ID 
		inner join tblCard CC (NOLOCK) on CC.Card_SerialNo = a.CardPointTrans_SerialNo
		inner join tblCardOwner d on CC.Card_CardOwner_ID = d.CardOwner_ID
		LEFT join tblPlayerLevel e on d.CardOwner_IDType = e.PlayerLevel_ID
		where 
		--a.CardPointTrans_SerialNo IN (select Card_SerialNo from tblCard where Card_CardOwner_ID = @intPlayerID)
		--AND 
		a.CardPointTrans_CreatedDate between @strDateFrom and @strDateTo 
		AND a.CardPointTrans_Type in (4,5)
		AND a.CardPointTrans_Value >= 0 
		AND (CASE WHEN @strCardType = '' THEN 1 ELSE CASE WHEN CC.Card_Type IN (select NAME from dbo.fnSplitstringToTable(@strCardType)) THEN 1 ELSE 0 END END) > 0
				Order by a.CardPointTrans_CreatedDate desc, a.CardPointTrans_SerialNo
	END
	ELSE 
	BEGIN
		select d.CardOwner_Name as PlayerName, a.CardPointTrans_SerialNo as CardNumber, a.CardPointTrans_Value as AdjustedPoint,
		ISNULL(CardPointTrans_ApprovedBy,'') as AdjustmentBy, a.CardPointTrans_CreatedDate as AdjustDate, b.WTransType_Name as PointTransType,
		--a.CardPointTrans_ID, a.CardPointTrans_Code, a.CardPointTrans_CreatedDate, 
		--a.CardPointTrans_CreatedBy, b.WTransType_Name,
		--a.CardPointTrans_Value, c.Machine_Name As LocationName, d.CardOwner_IC, e.PlayerLevel_Name,
		(CASE WHEN (CHARINDEX('<PTMServiceSessionData>', CardPointTrans_Remarks)) = 0 THEN CardPointTrans_Remarks ELSE '' END) as PointRemarks
		--a.CardPointTrans_Remarks, 
		--ISNULL(u.POSUser_Name,'') as POSUser_Name, CardPointTrans_ApprovedDate
		from tblCardPointTrans a
		inner join tblWalletTransType b on a.CardPointTrans_Type = b.WTransType_ID
		left outer join tblPOSUser U on U.POSUser_Code = a.CardPointTrans_ApprovedBy
		--INNER JOIN  tblMachine c on a.CardPointTrans_MachineID = c.Machine_ID 
		inner join tblCard CC (NOLOCK) on CC.Card_SerialNo = a.CardPointTrans_SerialNo
		inner join tblCardOwner d on CC.Card_CardOwner_ID = d.CardOwner_ID
		LEFT join tblPlayerLevel e on d.CardOwner_IDType = e.PlayerLevel_ID
		where 
		--a.CardPointTrans_SerialNo IN (select Card_SerialNo from tblCard where Card_CardOwner_ID = @intPlayerID)
		--AND 
		a.CardPointTrans_CreatedDate between @strDateFrom and @strDateTo 
		AND a.CardPointTrans_Type in (4,5)
		AND (CASE WHEN @strCardType = '' THEN 1 ELSE CASE WHEN CC.Card_Type IN (select NAME from dbo.fnSplitstringToTable(@strCardType)) THEN 1 ELSE 0 END END) > 0
				Order by a.CardPointTrans_CreatedDate desc, a.CardPointTrans_SerialNo
	END

		--(@intPointType = '1' AND a.CardPointTrans_PointValue LIKE '%-')
		--OR (@intPointType != '1' AND a.CardPointTrans_PointValue NOT LIKE '%-')

END
