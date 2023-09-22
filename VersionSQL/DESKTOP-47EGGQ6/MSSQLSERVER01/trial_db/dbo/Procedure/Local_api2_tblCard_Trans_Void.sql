/****** Object:  Procedure [dbo].[Local_api2_tblCard_Trans_Void]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_api2_tblCard_Trans_Void]
-- Add the parameters for the stored procedure here
@strCardNumber NVARCHAR(50), 
@strUniqueKey  NVARCHAR(50),
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN

        --step 1

        DECLARE @transDate AS DATETIME= GETDATE();
        DECLARE @intialAmount AS MONEY= 0.00;
        DECLARE @finalAmount AS MONEY= 0.00;

        --step 1
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @strErrorText NVARCHAR(255)= '';
        DECLARE @intErrorCode INT= 0;
        IF
        (
            SELECT COUNT(t.CardTrans_ID)
            FROM tblCard_Trans t(NOLOCK)
            WHERE CardTrans_APIKey = @strUniqueKey
                  AND t.CardTrans_SerialNo = @strCardNumber
        ) = 0
            BEGIN
                SET @intErrorCode = -1;
                SET @strErrorText = 'Error Code: ' + CONVERT(NVARCHAR(50), @intErrorCode) + ' - Unique Key Records not found.';
                RAISERROR(@strErrorText, 16, 1);
                SET NOCOUNT OFF;
                RETURN @intErrorCode;
            END;
        IF
        (
            SELECT COUNT(t.CardTrans_ID)
            FROM tblCard_Trans t(NOLOCK)
            WHERE CardTrans_APIKey = @strUniqueKey
                  AND t.CardTrans_SerialNo = @strCardNumber
                  AND CardTrans_PaymentMode = 15
        ) <> 0
            BEGIN
                SET @intErrorCode = -2;
                SET @strErrorText = 'Error Code: ' + CONVERT(NVARCHAR(50), @intErrorCode) + ' - Record already void.';
                RAISERROR(@strErrorText, 16, 1);
                SET NOCOUNT OFF;
                RETURN @intErrorCode;
            END;
        DECLARE @PrefixType VARCHAR(50), @intRowCount INT;
        DECLARE @strNewReceiptNo NVARCHAR(50)= '';
        SET @PrefixType = 'Receipt';
        EXEC sp_tblPrefixNumber_GetNextRunNumber 
             'Payment', 
             @PrefixType, 
             0, 
             @strNewReceiptNo OUTPUT;
        DECLARE @strOldReceiptNo NVARCHAR(50)= '';
        DECLARE @intTransType BIGINT= 0;
        DECLARE @dblValue MONEY= 0;
        DECLARE @dblMoneyValue MONEY= 0;
        SELECT @intTransType = t.CardTrans_Type, 
               @strOldReceiptNo = t.CardTrans_Code, 
               @dblValue = t.CardTrans_Value, 
               @dblMoneyValue = t.CardTrans_MoneyValue
        FROM tblCard_Trans t(NOLOCK)
        WHERE CardTrans_APIKey = @strUniqueKey
              AND t.CardTrans_SerialNo = @strCardNumber;
        SET @dblValue = @dblValue * -1;
        DECLARE @ID BIGINT= 0;
        IF @intTransType = 28
            BEGIN
                SET @intTransType = 30;
            END;
            ELSE
            IF @intTransType = 29
                BEGIN
                    SET @intTransType = 35;
                END;
        DECLARE @strUserID NVARCHAR(50)= 'WEBAPI';
        DECLARE @strRemarks NVARCHAR(50)= 'Void from ' + @strOldReceiptNo;

        --step 2

        SELECT @intialAmount = C.Card_Balance
        FROM tblCard C
        WHERE Card_SerialNo = @strCardNumber;

        --

        IF @intTransType = 30
            BEGIN
                SET @finalAmount = @intialAmount - @dblValue;
            END;
        IF @intTransType = 35
            BEGIN
                SET @finalAmount = @intialAmount + @dblValue;
            END;
        --step 2

        INSERT INTO tblCard_Trans
        (CardTrans_Code, 
         CardTrans_SerialNo, 
         CardTrans_Date, 
         CardTrans_Type, 
         CardTrans_Value, 
         CardTrans_MoneyValue, 
         CardTrans_RefCode, 
         CardTrans_CreatedBy, 
         CardTrans_CreatedDate, 
         CardTrans_CampaignCode, 
         CardTrans_PaymentMode, 
         CardTrans_Remarks, 
         CardTrans_InitialAmount, 
         CardTrans_FinalAmount
        )
               SELECT @strNewReceiptNo, 
                      CardTrans_SerialNo, 
                      @transDate, 
                      @intTransType, 
                      @dblValue, 
                      @dblMoneyValue, 
                      @strOldReceiptNo, 
                      @strUserID, 
                      @transDate, 
                      CardTrans_CampaignCode, 
                      CardTrans_PaymentMode, 
                      @strRemarks, 
                      @intialAmount, 
                      @finalAmount
               FROM tblCard_Trans t(NOLOCK)
               WHERE CardTrans_APIKey = @strUniqueKey
                     AND t.CardTrans_SerialNo = @strCardNumber;
        SELECT @ID = SCOPE_IDENTITY();
        UPDATE tblCard_Trans
          SET 
              CardTrans_PaymentMode = 15
        WHERE CardTrans_APIKey = @strUniqueKey
              AND CardTrans_SerialNo = @strCardNumber;
			  set @CardId=@strCardNumber
        IF @intTransType = 30
            BEGIN
                UPDATE tblCard
                  SET 
                      Card_Balance = Card_Balance - @dblValue, 
                      Card_balance_Edit_DateTime = @transDate
                WHERE Card_SerialNo = @strCardNumber;
				set @CardId=@strCardNumber
            END;
        IF @intTransType = 35
            BEGIN
                UPDATE tblCard
                  SET 
                      Card_Balance = Card_Balance + @dblValue, 
                      Card_balance_Edit_DateTime = @transDate
                WHERE Card_SerialNo = @strCardNumber;
				set @CardId=@strCardNumber
            END;
        DECLARE @dblCardBalance MONEY= 0;
        SELECT @dblCardBalance = Card_Balance
        FROM tblCard c(NOLOCK)
        WHERE Card_SerialNo = @strCardNumber;
        SELECT @strNewReceiptNo AS ReceiptNo, 
               1 AS TransStatus, 
               @dblCardBalance AS CardBalance;
    END;
