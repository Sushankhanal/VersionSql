/****** Object:  Procedure [dbo].[Wapi_tblCounter_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblCounter_Add]
	-- Add the parameters for the stored procedure here
	@strCode	nvarchar(50),
	@strName	nvarchar(50),
	@intStatus	smallint,
	@intType	smallint,
	@strUsercode	nvarchar(50),
	@intMachineID	bigint =0,
	@strMachineName	nvarchar(50) =''
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Declare @ID	bigint = 0
		Declare @strResultText nvarchar(255) = ''
		Declare @intResultCode int = 0

		DECLARE @intCount INT = 0
		SELECT @intCount = ISNULL(COUNT(Counter_ID), 0) FROM tblCounter NOLOCK WHERE (Counter_Code = @strCode )
		
		Declare @strBranchCode nvarchar(50) = ''
		Declare @strCompanyCode nvarchar(50) = ''
		select top 1 @strCompanyCode = Company_Code from tblCompany c (NOLOCK) Order by Company_ID

		IF @intCount = 0 
		BEGIN
			INSERT INTO tblCounter
			(Counter_Code, Counter_BranchCode, Counter_Name, Counter_Cashless, Counter_Status, 
			Counter_CompanyCode, Counter_ReceiptPrinterName, Counter_KitchenPrinterName, Counter_Machine_ID, Counter_Machine_Name)
			VALUES (
			@strCode,@strBranchCode,@strName, @intType, @intStatus,@strCompanyCode,'','', @intMachineID, @strMachineName)
			SELECT @ID = SCOPE_IDENTITY()

			set @intResultCode = @ID
			set @strResultText = 'Success'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

		END
		ELSE
		BEGIN
			set @ID = -1
			set @strResultText = 'Counter code already used, Please try another code.'
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
