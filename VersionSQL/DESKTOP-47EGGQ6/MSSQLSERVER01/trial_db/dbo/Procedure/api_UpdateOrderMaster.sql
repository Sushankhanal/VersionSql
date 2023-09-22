/****** Object:  Procedure [dbo].[api_UpdateOrderMaster]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- 
-- exec api_UpdateOrderMaster 'Tablet01','comp02','1111','TB26','C1SO00000022',3
CREATE PROCEDURE [dbo].[api_UpdateOrderMaster]
	-- Add the parameters for the stored procedure here
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strUserCode	nvarchar(50),
	@strTableCode	nvarchar(50),
	@strOrderNo		nvarchar(50),
	@intPax			int
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
	
	--if @strUserCode <> ''
	--BEGIN
	--	if (select ISNULL(COUNT(POSUser_ID),0) from tblPOSUser where POSUser_CompanyCode = @strCompanyCode
	--	AND POSUser_Code = @strUserCode AND POSUser_Password = @strUserCode) = 0
	--	BEGIN
	--		set @intErrorCode = -1
	--		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
	--		' - Invalid Access Code.'
	--		RAISERROR (@strErrorText,16,1);  
	--		ROLLBACK TRANSACTION
	--		SET NOCOUNT OFF
	--		Select @intErrorCode as ResultCode, @strErrorText as ResultText
	--		RETURN (@intErrorCode)
	--	END
		
	--END

	Declare @strCurrentTableCode nvarchar(50) = ''
	select @strCurrentTableCode = Payment_TableCode from tblPayment_Order where Payment_ReceiptNo = @strOrderNo

	if @strOrderNo = ''
	BEGIN
		set @intErrorCode = -2
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Invalid order number.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		Select @intErrorCode as ResultCode, @strErrorText as ResultText
		RETURN (@intErrorCode)
	END

	if (select ISNULL(COUNT(Payment_ID),0) from tblPayment_Order where Payment_ReceiptNo = @strOrderNo) = 0
	BEGIN
		set @intErrorCode = -3
		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
		' - Order number not found.'
		RAISERROR (@strErrorText,16,1);  
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		Select @intErrorCode as ResultCode, @strErrorText as ResultText
		RETURN (@intErrorCode)
	END

	Update tblPayment_Order set Payment_TableCode = @strTableCode, Payment_Pax = @intPax
	where Payment_ReceiptNo = @strOrderNo 

	Update tblTable set Table_Status = 0 where Table_Code = @strCurrentTableCode 
	Update tblTable set Table_Status = 1 where Table_Code = @strTableCode 

	set @intErrorCode = 0
	set @strErrorText = 'Success'
	Select @intErrorCode as ResultCode, @strErrorText as ResultText

	--select @strOrderNo

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
