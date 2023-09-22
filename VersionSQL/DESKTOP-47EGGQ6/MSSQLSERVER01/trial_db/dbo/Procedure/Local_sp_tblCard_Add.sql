/****** Object:  Procedure [dbo].[Local_sp_tblCard_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_sp_tblCard_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strOwnerName	nvarchar(50),
	@strOwnerMobile	nvarchar(50),
	@intOwnerGender	smallint,
	@strUsercode	nvarchar(50),
	@CardId             bigint = NULL OUTPUT

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		
		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK 
		WHERE (Card_SerialNo = @strSerialNo )
		
		--set @intCount = 0
		IF @intCount = 0 
		BEGIN
			
			Declare @strCompanyCode nvarchar(50)
			select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

			INSERT INTO tblCard
			(Card_SerialNo, Card_Status, Card_MobileUser, Card_CreatedBy, Card_CreatedDate, Card_Balance, 
			Card_Point, Card_CompanyCode, Card_Sync, Card_Type, Card_Level)
			VALUES (
			@strSerialNo,@intStatus,'',@strUsercode,GETDATE(),0,0,@strCompanyCode,0,@intType, @intType)

			SELECT @ID = SCOPE_IDENTITY()
			set @CardId=SCOPE_IDENTITY();

			--INSERT INTO tblCardOwner
			--(CardOwner_CardSerialNo, CardOwner_Name, CardOwner_MobileNumber, CardOwner_Gender)
			--VALUES (@strSerialNo,@strOwnerName,@strOwnerMobile,@intOwnerGender)

		END
		ELSE
		BEGIN
			RAISERROR ('Error: Serial number already registred, Please try another Serial Number.',16,1);  
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-1)
		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
