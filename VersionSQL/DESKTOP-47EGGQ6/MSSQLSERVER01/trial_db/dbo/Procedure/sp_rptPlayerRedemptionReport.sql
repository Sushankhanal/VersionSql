/****** Object:  Procedure [dbo].[sp_rptPlayerRedemptionReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptPlayerPointMovementReport '2020-06-01 09:00','2020-06-01 09:00',2
CREATE PROCEDURE [dbo].[sp_rptPlayerRedemptionReport]
	-- Add the parameters for the stored procedure here
	@strStartDate		datetime,
	@strEndDate		datetime,
	@intPlayerID	bigint,
	@locationName	nvarchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set @strEndDate = DATEADD(day,1,@strEndDate)
	set @strEndDate = DATEADD(second,-1,@strEndDate)
	print @strEndDate

	Declare @strOwnderName nvarchar(50) = ''
	select @strOwnderName = CardOwner_Name from tblCardOwner where CardOwner_ID = 5

	DECLARE @tblTransID TABLE(TransID INT)

	--1 FOR RPT WTransType_ID = 2
	--2 FOR RPT WTransType_ID = 4,5
	--3 FOR RPT WTransType_ID = 14,15

		select a.CardPointTrans_ID, a.CardPointTrans_Code, a.CardPointTrans_CreatedDate, a.CardPointTrans_CreatedBy, b.WTransType_Name,
		a.CardPointTrans_Value, c.Machine_Name As LocationName, d.CardOwner_IC, d.CardOwner_Name, e.PlayerLevel_Name,
		(CASE WHEN (CHARINDEX('<PTMServiceSessionData>', CardPointTrans_Remarks)) = 0 THEN CardPointTrans_Remarks ELSE '' END)CardPointTrans_Remarks,
		--a.CardPointTrans_Remarks, 
		ISNULL(u.POSUser_Name,'') as POSUser_Name, CardPointTrans_ApprovedDate, @strOwnderName as PlayerName
		from tblCardPointTrans a
		inner join tblWalletTransType b on a.CardPointTrans_Type = b.WTransType_ID
		left outer join tblPOSUser U on U.POSUser_Code = a.CardPointTrans_ApprovedBy
		INNER JOIN  tblMachine c on a.CardPointTrans_MachineID = c.Machine_ID 
		Inner join tblCardOwner d on a.CardPointTrans_SerialNo = d.CardOwner_CardSerialNo
		inner join tblPlayerLevel e on d.CardOwner_IDType = e.PlayerLevel_ID
		where a.CardPointTrans_SerialNo IN (select Card_SerialNo from tblCard where Card_CardOwner_ID = @intPlayerID)
		AND a.CardPointTrans_CreatedDate between @strStartDate and @strEndDate 
		AND a.CardPointTrans_Type = 2
		Order by a.CardPointTrans_CreatedDate desc, a.CardPointTrans_SerialNo
END
