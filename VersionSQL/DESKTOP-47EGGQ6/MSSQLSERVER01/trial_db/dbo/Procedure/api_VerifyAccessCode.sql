/****** Object:  Procedure [dbo].[api_VerifyAccessCode]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- 
-- exec api_UpdateOrderMaster 'Tablet01','comp02','1111','TB26','C1SO00000022',3
CREATE PROCEDURE [dbo].[api_VerifyAccessCode]
	-- Add the parameters for the stored procedure here
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strTableCode	nvarchar(50),
	@strAccessCode	nvarchar(50),
	@intActionType	int
	-- 1: Change Table
	-- 2: Back to Main Page
	-- 3: Change Setting
	-- 4: Change Order Master (Pax and Switch table)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	Declare @strErrorText nvarchar(255) = ''
	Declare @intErrorCode int = 0

	Declare @intBranchID int = 0
	select top 1 @intBranchID = Branch_ID from tblBranch where Branch_CompanyCode = @strCompanyCode
	

	if @strAccessCode <> ''
	BEGIN
		if (select ISNULL(COUNT(POSUser_ID),0) from tblPOSUser where POSUser_CompanyCode = @strCompanyCode
		AND POSUser_Code = @strAccessCode AND POSUser_Password = @strAccessCode) = 0
		BEGIN
			set @intErrorCode = -1
			set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
			' - Invalid Access Code.'
			RAISERROR (@strErrorText,16,1);  
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			Select @intErrorCode as ResultCode, @strErrorText as ResultText
			RETURN (@intErrorCode)
		END
		ELSE
		BEGIN
			INSERT INTO tblOrderAccess
			(OrderAccess_UserCode, OrderAccess_Type, OrderAccess_CreateDate)
			VALUES (
			@strAccessCode,@intActionType,GETDATE())

			set @intErrorCode = 0
			set @strErrorText = 'Success'
			Select @intErrorCode as ResultCode, @strErrorText as ResultText
		END

	END

	
	



	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
