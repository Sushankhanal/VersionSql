/****** Object:  Procedure [dbo].[Local_wapi_tblCard_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_wapi_tblCard_Add]
	-- Add the parameters for the stored procedure here
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strUsercode	nvarchar(50),
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
		Declare @strCompanyCode nvarchar(50) = ''

		select top 1 @strCompanyCode = Company_Code from tblCompany c (NOLOCK) Order by Company_ID

		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(Card_ID), 0) FROM tblCard NOLOCK WHERE (Card_SerialNo = @strSerialNo )
		
		--set @intCount = 0
		IF @intCount = 0 
		BEGIN
			
			INSERT INTO tblCard
			(Card_SerialNo, Card_Status, Card_MobileUser, Card_CreatedBy, Card_CreatedDate, Card_Balance, 
			Card_Point, Card_CompanyCode, Card_Sync, Card_Type)
			VALUES (
			@strSerialNo,@intStatus,'',@strUsercode,GETDATE(),0,0,@strCompanyCode,0,@intType)

			SELECT @intID = SCOPE_IDENTITY()
			SET @CardId = SCOPE_IDENTITY();

			set @intResultCode = @intID
			set @strResultText = 'Success'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
		END
		ELSE
		BEGIN
			set @intResultCode = -1
			set @strResultText = 'Serial number already registred, Please try another Serial Number.'
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
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
