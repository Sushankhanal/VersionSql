/****** Object:  Procedure [dbo].[Local_api2_tblCard_Trans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_api2_tblCard_Trans_Add]
-- Add the parameters for the stored procedure here
@strCardNumber NVARCHAR(50), 
@dblAmt        MONEY, 
@intTransType  INT, 
@strUniqueKey  NVARCHAR(50),
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        BEGIN TRANSACTION;
        -- SET NOCOUNT ON addedto prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        --step 1

        DECLARE @transDate AS DATETIME= GETDATE();
        DECLARE @intialAmount AS MONEY= 0.00;
        DECLARE @finalAmount AS MONEY= 0.00;

        --step 1
        DECLARE @strErrorText NVARCHAR(255)= '';
        DECLARE @intErrorCode INT= 0;
        DECLARE @ID BIGINT= 0;
        DECLARE @dblValue MONEY= @dblAmt;
        --@strRemarks		nvarchar(50),
        DECLARE @strUserID NVARCHAR(50)= 'WEBAPI';
        --@strBranchCode	nvarchar(50),

        DECLARE @PrefixType VARCHAR(50), @intRowCount INT;
        DECLARE @strReceiptNo NVARCHAR(50)= '';
        SET @PrefixType = 'Receipt';
        EXEC sp_tblPrefixNumber_GetNextRunNumber 
             'Payment', 
             @PrefixType, 
             0, 
             @strReceiptNo OUTPUT;
        DECLARE @strCompanyCode NVARCHAR(50);
        SELECT TOP 1 @strCompanyCode = c.Company_Code
        FROM tblCompany c(NOLOCK);
        DECLARE @intPaymentType INT= 1;
        DECLARE @intItemSign INT= 0;
        SELECT @intItemSign = WTransType_Sign
        FROM tblWalletTransType
        WHERE WTransType_ID = @intTransType;

        --step 2

        SELECT @intialAmount = C.Card_Balance
        FROM tblCard C
        WHERE Card_SerialNo = @strCardNumber;

		--

		IF @intTransType = 28
            BEGIN
                SET @finalAmount = @intialAmount + @dblValue
            END;
        IF @intTransType = 29
            BEGIN
                SET @finalAmount = @intialAmount - @dblValue
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
         CardTrans_APIKey,
		 CardTrans_InitialAmount,
		 CardTrans_FinalAmount
        )
        VALUES
        (
        --@strCardTrans,
        @strReceiptNo, 
        @strCardNumber, 
        @transDate, 
        @intTransType, 
        @dblValue * @intItemSign, 
        @dblValue, 
        @strReceiptNo, 
        @strUserID, 
        @transDate, 
        '', 
        @intPaymentType, 
        @strUniqueKey,
		@intialAmount,
		@finalAmount
        );
        SELECT @ID = SCOPE_IDENTITY();
        IF @intTransType = 28
            BEGIN
                UPDATE tblCard
                  SET 
                      Card_Balance = Card_Balance + @dblValue, Card_balance_Edit_DateTime = @transDate
                WHERE Card_SerialNo = @strCardNumber;
				set @CardId=@strCardNumber
				
            END;
        IF @intTransType = 29
            BEGIN
                UPDATE tblCard
                  SET 
                      Card_Balance = Card_Balance - @dblValue, Card_balance_Edit_DateTime = @transDate
                WHERE Card_SerialNo = @strCardNumber;
				set @CardId=@strCardNumber
            END;
        DECLARE @dblCardBalance MONEY= 0;
        SELECT @dblCardBalance = Card_Balance
        FROM tblCard c(NOLOCK)
        WHERE Card_SerialNo = @strCardNumber;
        SELECT @strReceiptNo AS ReceiptNo, 
               1 AS TransStatus, 
               @dblCardBalance AS CardBalance;
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        ROLLBACK TRANSACTION;
        RETURN(@@ERROR);
    END;
