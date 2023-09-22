/****** Object:  Procedure [dbo].[sp_rptPlayerPointMovementReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptPlayerPointMovementReport '2020-06-01 09:00','2020-06-01 09:00',2
CREATE PROCEDURE [dbo].[sp_rptPlayerPointMovementReport]
	-- Add the parameters for the stored procedure here
	@strStartDate	datetime,
	@strEndDate		datetime,
	@intPlayerID	bigint,
	@intTransType	bigint
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

	IF @intTransType = 3
	BEGIN
		BEGIN
			INSERT INTO @tblTransID
			SELECT 14
			UNION 
			SELECT 15
		END
		select a.CardPointTrans_ID, a.CardPointTrans_Code, a.CardPointTrans_CreatedDate, a.CardPointTrans_SerialNo, b.WTransType_Name,
		a.CardPointTrans_Value, c.Machine_Name,
		(CASE WHEN (CHARINDEX('<PTMServiceSessionData>', CardPointTrans_Remarks)) = 0 THEN CardPointTrans_Remarks ELSE '' END)CardPointTrans_Remarks,
		--a.CardPointTrans_Remarks, 
		ISNULL(u.POSUser_Name,'') as POSUser_Name, CardPointTrans_ApprovedDate, @strOwnderName as PlayerName
		from tblCardPointTrans a
		inner join tblWalletTransType b on a.CardPointTrans_Type = b.WTransType_ID
		inner join tblMachine c on a.CardPointTrans_MachineID = c.Machine_ID
		left outer join tblPOSUser U on U.POSUser_Code = a.CardPointTrans_ApprovedBy
		where a.CardPointTrans_SerialNo IN (select Card_SerialNo from tblCard where Card_CardOwner_ID = @intPlayerID)
		AND a.CardPointTrans_CreatedDate between @strStartDate and @strEndDate 
		AND a.CardPointTrans_Type  IN (SELECT TransID from @tblTransID)
		Order by a.CardPointTrans_CreatedDate desc, a.CardPointTrans_SerialNo
	END
	ELSE
	BEGIN
		IF @intTransType = 1
		BEGIN
			INSERT INTO @tblTransID
			SELECT 2
		END

		IF @intTransType = 2
		BEGIN
			INSERT INTO @tblTransID
			SELECT 4
			UNION 
			SELECT 5
		END
			
		select a.CardPointTrans_ID, a.CardPointTrans_Code, a.CardPointTrans_CreatedDate, a.CardPointTrans_SerialNo, b.WTransType_Name,
		a.CardPointTrans_Value, 
		(CASE WHEN (CHARINDEX('<PTMServiceSessionData>', CardPointTrans_Remarks)) = 0 THEN CardPointTrans_Remarks ELSE '' END)CardPointTrans_Remarks,
		--a.CardPointTrans_Remarks, 
		ISNULL(u.POSUser_Name,'') as POSUser_Name, CardPointTrans_ApprovedDate, @strOwnderName as PlayerName
		from tblCardPointTrans a
		inner join tblWalletTransType b on a.CardPointTrans_Type = b.WTransType_ID
		left outer join tblPOSUser U on U.POSUser_Code = a.CardPointTrans_ApprovedBy
		where a.CardPointTrans_SerialNo IN (select Card_SerialNo from tblCard where Card_CardOwner_ID = @intPlayerID)
		AND a.CardPointTrans_CreatedDate between @strStartDate and @strEndDate 
		AND a.CardPointTrans_Type  IN (SELECT TransID from @tblTransID)
		Order by a.CardPointTrans_CreatedDate desc, a.CardPointTrans_SerialNo
	END

END
