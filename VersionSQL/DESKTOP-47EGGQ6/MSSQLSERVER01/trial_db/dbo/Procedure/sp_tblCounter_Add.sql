/****** Object:  Procedure [dbo].[sp_tblCounter_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCounter_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strCode	nvarchar(50),
	@strName	nvarchar(50),
	@intStatus	smallint,
	@intType	smallint,
	@strUsercode		nvarchar(50),
	@intMachineID	bigint =0,
	@strMachineName	nvarchar(50) =''
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @intCount INT
		--DECLARE @ID INT
		--SELECT @intCount = ISNULL(COUNT(mUser_ID), 0) FROM tblUserMobile NOLOCK 
		--WHERE (mUser_LoginID = @strLoginID )

		Declare @strBranchCode		nvarchar(50) = ''
		set @strBranchCode = 'Hall001'

		set @intCount = 0
		IF @intCount = 0 
		BEGIN
			--DECLARE @PrefixType VARCHAR(50), @intRowCount INT
			--set @PrefixType = 'MobileUser'
			--EXEC sp_tblPrefixNumber_GetNextRunNumber 'MobileUser', @PrefixType, 0, @strUserCode OUTPUT

			Declare @strCompanyCode nvarchar(50)
			select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

			INSERT INTO tblCounter
			(Counter_Code, Counter_BranchCode, Counter_Name, Counter_Cashless, Counter_Status, 
			Counter_CompanyCode, Counter_ReceiptPrinterName, Counter_KitchenPrinterName, Counter_Machine_ID, Counter_Machine_Name)
			VALUES (
			@strCode,@strBranchCode,@strName, @intType, @intStatus,@strCompanyCode,'','', @intMachineID, @strMachineName)
			SELECT @ID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			RAISERROR ('Error',16,1);  
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
