/****** Object:  Procedure [dbo].[api_CancelOrderMaster4]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[api_CancelOrderMaster4] @strDeviceCode nvarchar(50),
@strCompanyCode nvarchar(50),
@strTableCode nvarchar(50),
@strOrderNo nvarchar(50),
@newabc nvarchar(50),
@newdef nvarchar(50)
AS
BEGIN
  BEGIN TRANSACTION
    SET NOCOUNT ON;


    DECLARE @strErrorText nvarchar(255) = ''
    DECLARE @intErrorCode int = 0

    DECLARE @intBranchID int = 0
    SELECT TOP 1
      @intBranchID = Branch_ID
    FROM tblBranch
    WHERE Branch_CompanyCode = @strCompanyCode



    DECLARE @intTableStatus int = -1
    SELECT
      @intTableStatus = Table_Status
    FROM tblTable
    WHERE Table_Code = @strTableCode
    AND Table_CompanyCode = @strCompanyCode

    IF @strOrderNo = ''
    BEGIN
      SET @intErrorCode = -2
      SET @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50), @intErrorCode) +
      ' - Invalid Order number.'
      RAISERROR (@strErrorText, 16, 1);
      ROLLBACK TRANSACTION
      SET NOCOUNT OFF
      RETURN (@intErrorCode)
    END

    IF (SELECT
        ISNULL(COUNT(Payment_ID), 0)
      FROM tblPayment_Order
      WHERE Payment_ReceiptNo = @strOrderNo)
      = 0
    BEGIN
      SET @intErrorCode = -3
      SET @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50), @intErrorCode) +
      ' - Order number not found.'
      RAISERROR (@strErrorText, 16, 1);
      ROLLBACK TRANSACTION
      SET NOCOUNT OFF
      SELECT
        @intErrorCode AS ResultCode,
        @strErrorText AS ResultText
      RETURN (@intErrorCode)
    END


    IF @intTableStatus = 1
    BEGIN


      DELETE FROM tblPayment_Order
      WHERE Payment_ReceiptNo = @strOrderNo
      DELETE FROM tblPayment_Details
      WHERE PaymentD_ReceiptNo = @strOrderNo
      DELETE FROM tblPayment_Extra
      WHERE PaymentEx_ReceiptNo = @strOrderNo

      UPDATE tblTable
      SET Table_Status = 0
      WHERE Table_Code = @strTableCode
      AND Table_CompanyCode = @strCompanyCode

      SET @intErrorCode = 0
      SET @strErrorText = 'Success'
      SELECT
        @intErrorCode AS ResultCode,
        @strErrorText AS ResultText

    END
    ELSE
    BEGIN
      SET @intErrorCode = -4
      SET @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50), @intErrorCode) +
      ' - Table code not in occupy status.'
      RAISERROR (@strErrorText, 16, 1);
      ROLLBACK TRANSACTION
      SET NOCOUNT OFF
      RETURN (@intErrorCode)
    END



    IF @@ERROR <> 0
      GOTO ErrorHandler

  COMMIT TRANSACTION
  SET NOCOUNT OFF
  RETURN (0)

ErrorHandler:
  ROLLBACK TRANSACTION
  RETURN (@@ERROR)
END

--New id 111 9999 morecode here nowww please goooooooo
