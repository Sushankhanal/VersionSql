/****** Object:  Procedure [dbo].[sp_tblPayment_Order_Cancel]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblPayment_Order_Cancel]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50),
	@strOrderNumber		nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @strPOSUserCode = ''
	BEGIN
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		RETURN (-1)
	END
	ELSE
	BEGIN
		
		if (select COUNT(POSUser_ID) from tblPOSUser where POSUser_Password = @strPOSUserCode 
		AND POSUser_CompanyCode = @strCompanyCode AND POSUser_UserType = 1) = 0 
		BEGIN
			ROLLBACK TRANSACTION
			SET NOCOUNT OFF
			RETURN (-12)
		END
	END

	if @strOrderNumber <> ''
	BEGIN
		Declare @strTableCode nvarchar(50) = ''
		select @strTableCode = Payment_TableCode from tblPayment_Order where Payment_ReceiptNo = @strOrderNumber
		Delete from tblPayment_Order where Payment_ReceiptNo = @strOrderNumber
		Delete from tblPayment_Details where PaymentD_ReceiptNo = @strOrderNumber
		Delete from tblPayment_Extra where PaymentEx_ReceiptNo = @strOrderNumber

		Update tblTable set Table_Status = 0, Table_isCalling = 0 where Table_Code = @strTableCode
	END
		
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
