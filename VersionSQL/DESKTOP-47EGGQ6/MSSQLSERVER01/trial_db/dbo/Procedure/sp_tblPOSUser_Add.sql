/****** Object:  Procedure [dbo].[sp_tblPOSUser_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblPOSUser_Add]
	-- Add the parameters for the stored procedure here
	@intID		int OUT,
	@strName	nvarchar(50),
	@intStatus	smallint,
    @strCompanyCode	nvarchar(50),
	@strUsercode	nvarchar(50),
	@strLoginID		nvarchar(50),
	@strPassword	nvarchar(50),
	@intUserGroup	smallint,
	@intUserType	smallint,
	@minDisAmt		money,
	@minDisRate		money

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		
		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(POSUser_ID), 0) FROM tblPOSUser NOLOCK 
		WHERE (POSUser_LoginID = @strLoginID )
		
		--set @intCount = 0
		IF @intCount = 0 
		BEGIN
			
			--Declare @strCompanyCode nvarchar(50)
			--select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

			Declare @strPOSUserCode nvarchar(50)
			--DECLARE @PrefixType VARCHAR(50), @intRowCount INT
			--set @PrefixType = 'POSUser'
			--EXEC sp_tblPrefixNumber_GetNextRunNumber 'POSUser', @PrefixType, 0, @strPOSUserCode OUTPUT
			set @strPOSUserCode = @strLoginID

			INSERT INTO tblPOSUser
			(POSUser_Code, POSUser_LoginID, POSUser_Password, POSUser_Status, POSUser_Name, 
			POSUser_CreatedBy, POSUser_CreatedDate, POSUser_UserType, POSUser_CompanyCode, POSUser_UserGroupID,
			POSUser_MinGiveOutDiscountAmt, POSUser_MinGiveOutDiscountRate)
			VALUES (
			@strPOSUserCode,@strLoginID, @strPassword, @intStatus, @strName, 
			@strUserCode, GETDATE(), @intUserType, @strCompanyCode, @intUserGroup, @minDisAmt, @minDisRate)
			SELECT @intID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			RAISERROR ('Error: Login ID used by another use, Please try another Login ID.',16,1);  
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
