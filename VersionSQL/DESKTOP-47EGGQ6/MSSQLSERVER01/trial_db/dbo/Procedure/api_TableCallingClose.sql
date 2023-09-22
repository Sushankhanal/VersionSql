/****** Object:  Procedure [dbo].[api_TableCallingClose]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec api_TableCallingClose 'comp02','Tablet01','Tablet01','R1'
CREATE PROCEDURE [dbo].[api_TableCallingClose]
	-- Add the parameters for the stored procedure here
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strUserCode	nvarchar(50),
	@strTableCode	nvarchar(50)
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
	
    update  tblTable set Table_isCalling = 0 where Table_Code = @strTableCode
	AND Table_CompanyCode= @strCompanyCode

	set @intErrorCode = 0
	set @strErrorText = 'Success'
	Select @intErrorCode as ResultCode, @strErrorText as ResultText
	--return @intErrorCode

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
