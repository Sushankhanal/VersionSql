/****** Object:  Procedure [dbo].[Local_sp_tblCard_Add_Import]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_sp_tblCard_Add_Import]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strOwnerName	nvarchar(50),
	@strOwnerMobile	nvarchar(50),
	@intOwnerGender	smallint,
	@strUsercode	nvarchar(50),
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
	@strCardNumber		nvarchar(50) = '',
	@strPic				nvarchar(max) ='',
	@CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		
		DECLARE @intCount INT
		--SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK 
		--WHERE (Card_SerialNo = @strSerialNo )
		
		SELECT @intCount = ISNULL(COUNT(CardOwner_ID), 0) FROM tblCardOwner NOLOCK 
		WHERE (CardOwner_IC = @strIC )


		--set @intCount = 0
		IF @intCount = 0 
		BEGIN
			
			Declare @strCompanyCode nvarchar(50)
			select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

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
			SELECT @ID = SCOPE_IDENTITY()
			set @CardOwnerId=SCOPE_IDENTITY()

			if @dtDOB <> ''
			BEGIN
				update tblCardOwner set CardOwner_DOB = @dtDOB where CardOwner_ID = @ID
				set @CardOwnerId=@ID
			END

			INSERT INTO tblCard
			(Card_SerialNo, Card_Status, Card_MobileUser, Card_CreatedBy, Card_CreatedDate, Card_Balance, 
			Card_Point, Card_CompanyCode, Card_Sync, Card_Type, Card_Level, Card_CardOwner_ID)
			VALUES (
			@strSerialNo,@intStatus,'',@strUsercode,GETDATE(),0,0,@strCompanyCode,0,@intType,@intType, @ID)
			set @CardId=SCOPE_IDENTITY();

		END
		ELSE
		BEGIN
			Update tblCardOwner set
			CardOwner_Name = @strOwnerName, CardOwner_MobileNumber = @strOwnerMobile, CardOwner_Gender = @intOwnerGender, 
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

			SELECT @ID = Card_ID from tblCard  NOLOCK 
			WHERE (Card_SerialNo = @strSerialNo )

			

		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
