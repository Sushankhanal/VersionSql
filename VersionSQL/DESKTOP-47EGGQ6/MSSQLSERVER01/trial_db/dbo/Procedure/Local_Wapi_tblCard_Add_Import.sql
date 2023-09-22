/****** Object:  Procedure [dbo].[Local_Wapi_tblCard_Add_Import]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_Wapi_tblCard_Add_Import]
	-- Add the parameters for the stored procedure here
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strOwnerName	nvarchar(50),
	@strOwnerMobile	nvarchar(50),
	@strMembership	nvarchar(100),
	@strIC		nvarchar(50),
	@strAddress		nvarchar(max),
	@strFamilyName		nvarchar(50), 
	@intCountry		int, 
	@intGender			int, 
	@intLevel			int, 
	@dtDOB				nvarchar(50), 
	@strEmail			nvarchar(50), 
	@intIDType			int, 
	@strRemarks			nvarchar(500), 
	@intBarred			int, 
	@strBarredReason	nvarchar(255),
	@strCreatedBy		int,
	@strPic				nvarchar(max) ='',
	 @CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @strResultText nvarchar(255) = ''
		Declare @intResultCode int = 0
		Declare @intID bigint = 0
		
		DECLARE @intCount INT
		--SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK 
		--WHERE (Card_SerialNo = @strSerialNo )
		
		SELECT @intCount = ISNULL(COUNT(CardOwner_ID), 0) FROM tblCardOwner NOLOCK 
		WHERE (CardOwner_IC = @strIC )


		--set @intCount = 0
		IF @intCount = 0 
		BEGIN
			
			Declare @strCompanyCode nvarchar(50)=''
			select top 1 @strCompanyCode = Company_Code from tblCompany c (NOLOCK) Order by Company_ID

			--select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

			INSERT INTO tblCardOwner
			(CardOwner_Name, CardOwner_MobileNumber, CardOwner_Gender, CardOwner_Membership, CardOwner_IC, CardOwner_Address, 
			CardOwner_CreatedBy, CardOwner_CreatedDate, 
			CardOwner_FamilyName, CardOwner_Country_ID, CardOwner_Status, CardOwner_Level, 
			CardOwner_Email, CardOwner_IDType, CardOwner_Remarks, CardOwner_Barred, 
			CardOwner_BarredReason, CardOwner_CardSerialNo, CardOwner_Pic)
			VALUES (
			@strOwnerName,@strOwnerMobile,@intGender,@strMembership,@strIC,@strAddress,
			@strCreatedBy,GETDATE(),
			@strFamilyName,@intCountry,@intStatus,@intLevel,
			@strEmail,@intIDType,@strRemarks,@intBarred,@strBarredReason,'',@strPic)

			--INSERT INTO tblCardOwner
			--(CardOwner_CardSerialNo, CardOwner_Name, CardOwner_MobileNumber, CardOwner_Gender, CardOwner_Membership, CardOwner_IC, CardOwner_Address,CardOwner_CreatedBy, CardOwner_CreatedDate)
			--VALUES (@strSerialNo,@strOwnerName,@strOwnerMobile,@intOwnerGender,@strMembership,@strIC,@strAddress, -1, GETDATE() )
			SELECT @intID = SCOPE_IDENTITY()
			set @CardOwnerId=SCOPE_IDENTITY();
			if @dtDOB <> ''
			BEGIN
				update tblCardOwner set CardOwner_DOB = @dtDOB where CardOwner_ID = @intID
			END

			INSERT INTO tblCard
			(Card_SerialNo, Card_Status, Card_MobileUser, Card_CreatedBy, Card_CreatedDate, Card_Balance, 
			Card_Point, Card_CompanyCode, Card_Sync, Card_Type, Card_CardOwner_ID)
			VALUES (
			@strSerialNo,@intStatus,'',@strCreatedBy,GETDATE(),0,0,@strCompanyCode,0,@intType, @intID)

			set @intResultCode = @intID
			set @strResultText = 'Success'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
			set @CardId=SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			Update tblCardOwner set
			CardOwner_Name = @strOwnerName, CardOwner_MobileNumber = @strOwnerMobile, CardOwner_Gender = @intGender, 
			CardOwner_Membership = @strMembership, CardOwner_IC = @strIC, CardOwner_Address = @strAddress,
			CardOwner_FamilyName = @strFamilyName, CardOwner_Country_ID = @intCountry, CardOwner_Level = @intLevel, 
			CardOwner_Email = @strEmail, CardOwner_IDType = @intIDType
			where CardOwner_IC = @strIC 
			set @CardOwnerId=@strIC
			if @dtDOB <> ''
			BEGIN
				update tblCardOwner set CardOwner_DOB = @dtDOB where CardOwner_IC = @strIC 
				set @CardOwnerId=@strIC
			END

			--SELECT @ID = Card_ID from tblCard  NOLOCK 
			--WHERE (Card_SerialNo = @strSerialNo )

			SELECT @intID = CardOwner_ID FROM tblCardOwner NOLOCK WHERE (CardOwner_IC = @strIC )

			set @intResultCode = @intID
			set @strResultText = 'Success'
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
