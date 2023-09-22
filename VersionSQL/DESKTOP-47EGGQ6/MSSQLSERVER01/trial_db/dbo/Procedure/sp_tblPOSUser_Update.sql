/****** Object:  Procedure [dbo].[sp_tblPOSUser_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblPOSUser_Update]
	-- Add the parameters for the stored procedure here
	@ID		int ,
	@strName	nvarchar(50),
	@intStatus	smallint,
	@strCompanyCode	nvarchar(50),
	@strUsercode	nvarchar(50),
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

		Update tblPOSUser Set
		POSUser_Name = @strName, POSUser_Status = @intStatus, POSUser_CompanyCode = @strCompanyCode,
		POSUser_UserType = @intUserType, POSUser_MinGiveOutDiscountAmt = @minDisAmt, POSUser_MinGiveOutDiscountRate = @minDisRate
		Where POSUser_ID = @ID

		
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
