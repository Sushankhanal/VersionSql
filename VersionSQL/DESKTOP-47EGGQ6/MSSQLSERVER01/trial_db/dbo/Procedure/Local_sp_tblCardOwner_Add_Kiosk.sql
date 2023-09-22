/****** Object:  Procedure [dbo].[Local_sp_tblCardOwner_Add_Kiosk]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_sp_tblCardOwner_Add_Kiosk]
	-- Add the parameters for the stored procedure here
	@intID				bigint OUT,
	@strFirstName		nvarchar(50), 
	@strMobileNumber	nvarchar(50), 
	@intGender			int, 
	@strMembership		nvarchar(50), 
	@strIC				nvarchar(50), 
	@strAddress			nvarchar(500),
	@strFamilyName		nvarchar(50), 
	@intCountry		int, 
	@intStatus			int, 
	@intLevel			int, 
	@dtDOB				nvarchar(50), 
	@strEmail			nvarchar(50), 
	@intIDType			int, 
	@strRemarks			nvarchar(500), 
	@intBarred			int, 
	@strBarredReason	nvarchar(255),
	@strCreatedBy		int,
	@strCardNumber		nvarchar(50) = '',
	@strCardPin			nvarchar(50)  = '' OUT,
	@strPic				nvarchar(max) ='',
	@strCompanyCode		nvarchar(50)  = '',
	@intCardType		int = 0,
	@strCardNumberNew	nvarchar(50) = '' OUT,
	@CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		set @strCardPin = ''
		--set @strMobileNumber = '01900112289'
		set @strCardNumberNew = ''

		DECLARE @intCount INT
		DECLARE @ID INT
		SELECT @intCount = ISNULL(COUNT(CardOwner_ID), 0) FROM tblCardOwner NOLOCK 
		WHERE (CardOwner_MobileNumber = @strMobileNumber )

		if @intCount > 0
		BEGIN
			if @strCardNumber = ''
			BEGIN
				RAISERROR ('Mobile number already registered. Please try another.',16,1);  
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				RETURN (-1)
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				RETURN (-1)
			END
		END

		if @strCardNumber <> ''
		BEGIN
			SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK WHERE (Card_SerialNo = @strCardNumber ) and Card_Status = 0
			if @intCount = 0
			BEGIN
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				RETURN (-2)
			END
		END


		IF @intCount = 0 
		BEGIN
			INSERT INTO tblCardOwner
			(CardOwner_Name, CardOwner_MobileNumber, CardOwner_Gender, CardOwner_Membership, CardOwner_IC, CardOwner_Address, 
			CardOwner_CreatedBy, CardOwner_CreatedDate, 
			CardOwner_FamilyName, CardOwner_Country_ID, CardOwner_Status, CardOwner_Level, 
			CardOwner_Email, CardOwner_IDType, CardOwner_Remarks, CardOwner_Barred, 
			CardOwner_BarredReason, CardOwner_CardSerialNo)
			VALUES (
			@strFirstName,@strMobileNumber,@intGender,@strMembership,@strIC,@strAddress,
			@strCreatedBy,GETDATE(),
			@strFamilyName,@intCountry,@intStatus,@intLevel,
			@strEmail,@intIDType,@strRemarks,@intBarred,@strBarredReason,'')
			
			SELECT @intID = SCOPE_IDENTITY()
			set @CardOwnerId=SCOPE_IDENTITY()

			if @dtDOB <> ''
			BEGIN
				update tblCardOwner set CardOwner_DOB = @dtDOB where CardOwner_ID = @intID
				set @CardOwnerId=@intID
			END
			if @strCardNumber <> ''
			BEGIN
				update tblCard set Card_CardOwner_ID = @intID where Card_SerialNo = @strCardNumber and Card_Status = 0
				select @strCardPin = tblCard_pin from tblCard where Card_SerialNo = @strCardNumber
				set @CardId=@strCardNumber

			END
			else if @strCardNumber = ''
			BEGIN
				Declare @intCardMaxLenght bigint = 0
				select @intCardMaxLenght = s.SysParam_Desc from tblSysParms s (NOLOCK) where s.SysParam_Scope = 'Card' and s.SysParam_LogicalName = 'Card Number Length'
				if @intCardMaxLenght = 0
				BEGIN
					set @intCardMaxLenght = 16
				END
				Declare @intStartRunning nvarchar(50)
				set @intStartRunning = '9' + REPLICATE('0', @intCardMaxLenght-1) 
				--print @intStartRunning

				
				Declare @strRandomNumber nvarchar(50) = ''
				--SELECT @strRandomNumber = cast((9000000000000000* Rand() + 100000) as bigint )
				SELECT @strRandomNumber = cast((@intStartRunning* Rand() + 100000) as bigint )
				--set @strRandomNumber = '0605558317467205'
				WHILE (Select count(C.Card_ID) from tblCard C (NOLOCK) where C.Card_SerialNo = @strRandomNumber) <> 0
				BEGIN
					--PRINT @strRandomNumber
					--SELECT @strRandomNumber = cast((9000000000000000* Rand() + 100000) as bigint )
					SELECT @strRandomNumber = cast((@intStartRunning* Rand() + 100000) as bigint )
				END

				set @strCardNumber = @strRandomNumber

				INSERT INTO tblCard
				(Card_SerialNo, Card_Status, Card_MobileUser, Card_Balance, Card_CreatedBy, Card_CreatedDate, 
				Card_Point, Card_CompanyCode, Card_CardOwner_ID, Card_Sync, Card_Type, 
				Card_Balance_Cashable_No, Card_Balance_Cashable, Card_PointAccumulate, 
				Card_isPinReset, Card_Point_Tier, Card_Point_Hidden, Card_img)
				VALUES (
				@strCardNumber,0,@strMobileNumber,0,@strCreatedBy,GETDATE(),
				0,@strCompanyCode,@intID,0,@intCardType,
				0,0,0,
				0,0,0,'')
				set @CardId=SCOPE_IDENTITY();
			END

			if @strPic <> ''
			BEGIN
				update tblCardOwner set CardOwner_Pic = @strPic where CardOwner_ID = @intID
				set @CardOwnerId=@intID
			END
		END
		
		set @strCardNumberNew = @strCardNumber

If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
