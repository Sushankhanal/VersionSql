/****** Object:  Procedure [dbo].[Local_Wapi_tblCardOwner_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec Wapi_tblCardOwner_Add '','601234567819',0,'','','','',1,0,1,'1983-05-01','',1,'',1,'',1,'','',''
CREATE PROCEDURE [dbo].[Local_Wapi_tblCardOwner_Add]
	-- Add the parameters for the stored procedure here
	@strFirstName		nvarchar(50), 
	@strMobileNumber	nvarchar(50), 
	@intGender			int, 
	@strMembership		nvarchar(50), 
	@strIC				nvarchar(50), 
	@strAddress			nvarchar(500),
	@strFamilyName		nvarchar(50), 
	@intCountry		    int, 
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
    @CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @isAutoGenerateCard nvarchar(50) = 'True'
	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0

		set @strCardPin = ''
		--set @strMobileNumber = '01900112289'

		DECLARE @intCount INT
		DECLARE @ID INT
		SELECT @intCount = ISNULL(COUNT(CardOwner_ID), 0) FROM tblCardOwner NOLOCK 
		WHERE (CardOwner_MobileNumber = @strMobileNumber)
		
		if @intCount > 0
		BEGIN
			if @strCardNumber = ''
			BEGIN
				set @intResultCode = -1
				set @strResultText = 'Mobile number already registered. Please try another.'
				--RAISERROR ('Mobile number already registered. Please try another.',16,1);  
				print @strResultText
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
				RETURN (-1)
			END
			ELSE
			BEGIN
				set @intResultCode = -1
				set @strResultText = 'Mobile number already registered. Please try another.'
				--RAISERROR ('Mobile number already registered. Please try another.',16,1);  
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
				RETURN (-1)
			END
		END

		if @strCardNumber <> ''
		BEGIN
			SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK 
			WHERE (Card_SerialNo = @strCardNumber ) and Card_Status = 0
			if @intCount = 0
			BEGIN
				set @intResultCode = -1
				set @strResultText = 'Card Number not available. Please try another.'
				ROLLBACK TRANSACTION
				SET NOCOUNT OFF
				select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
				RETURN (-1)
			END
		END


		Declare @intID bigint = 0

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
			SET @CardOwnerId = SCOPE_IDENTITY();
			if @dtDOB <> ''
			BEGIN
				update tblCardOwner set CardOwner_DOB = @dtDOB where CardOwner_ID = @intID
			END
			if @strCardNumber <> ''
			BEGIN
				update tblCard set Card_CardOwner_ID = @intID where Card_SerialNo = @strCardNumber and Card_Status = 0
				select @strCardPin = tblCard_pin from tblCard where Card_SerialNo = @strCardNumber
			END
			if @strPic <> ''
			BEGIN
				update tblCardOwner set CardOwner_Pic = @strPic where CardOwner_ID = @intID
			END

			if @isAutoGenerateCard = 'True'
			BEGIN
				Declare @strCompanyCode nvarchar(50) = ''
				SELECT  @strCardNumber = cast((9000000000* Rand() + 1000000000) as bigint )

				While (Select COUNT(c.Card_ID) from tblCard c (NOLOCK) where c.Card_SerialNo =  @strCardNumber) > 0
				BEGIN
					SELECT  @strCardNumber = cast((9000000000* Rand() + 1000000000) as bigint )
				END

				Declare @intCardType int = 0
				select top 1 @strCompanyCode = Company_Code from tblCompany c (NOLOCK) Order by Company_ID

				set @strMobileNumber = ''
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
				SET @CardId = SCOPE_IDENTITY();
			END


			set @intResultCode = @intID
			set @strResultText = 'Success'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
		END
		ELSE
		BEGIN
			set @intResultCode = 0
			set @strResultText = 'Something Wrong'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
		END
		


If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)


END
