/****** Object:  Procedure [dbo].[Local_api_CardMoneyVoid]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_api_CardMoneyVoid]
-- Add the parameters for the stored procedure here
@strUniqueID    NVARCHAR(50), 
@strCardNo      NVARCHAR(50), 
@strCompanyCode NVARCHAR(50),
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        BEGIN TRANSACTION;
        -- SET NOCOUNT ON addedto prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @ID BIGINT= 0;
        DECLARE @strErrorText NVARCHAR(255)= '';
        DECLARE @intErrorCode INT= 0;
        DECLARE @intCount INT= 0;
        SELECT @intCount = COUNT(P.CardTrans_ID)
        FROM tblCard_Trans P --(NOLOCK)
        WHERE P.CardTrans_Code = @strUniqueID
              AND p.CardTrans_SerialNo = @strCardNo;
        IF @intCount = 0
            BEGIN
                SET @intErrorCode = -1;
                SET @strErrorText = 'Error Code: ' + CONVERT(NVARCHAR(50), @intErrorCode) + ' - Unqiue number not exist';
                RAISERROR(@strErrorText, 16, 1);
                ROLLBACK TRANSACTION;
                SET NOCOUNT OFF;
                RETURN @intErrorCode;
            END;
        SELECT @intCount = COUNT(C.Card_ID)
        FROM tblCard C --(NOLOCK)
        WHERE C.Card_SerialNo = @strCardNo;
        IF @intCount = 0
            BEGIN
                SET @intErrorCode = -2;
                SET @strErrorText = 'Error Code: ' + CONVERT(NVARCHAR(50), @intErrorCode) + ' - Card number not exist';
                RAISERROR(@strErrorText, 16, 1);
                ROLLBACK TRANSACTION;
                SET NOCOUNT OFF;
                RETURN @intErrorCode;
            END;
        --SELECT @intCount = COUNT(P.CardTrans_ID)
        --FROM tblCard_Trans P --(NOLOCK)
        --WHERE P.CardTrans_RefCode = @strUniqueID;

        SELECT @intCount = COUNT(1)
        FROM tblCard_Trans
        WHERE CardTrans_PaymentMode = 15
              AND CardTrans_Code = @strUniqueID;
        IF @intCount <> 0
            BEGIN
                SET @intErrorCode = -3;
                SET @strErrorText = 'Error Code: ' + CONVERT(NVARCHAR(50), @intErrorCode) + ' - This Unqiue number already void';
                ROLLBACK TRANSACTION;
                RETURN(0);
                RAISERROR(@strErrorText, 16, 1);
                SET NOCOUNT OFF;
                RETURN @intErrorCode;
            END;
        DECLARE @strUserID BIGINT= -80;
        DECLARE @intOriType INT= 0;
        DECLARE @dblAmount MONEY= 0;
        SELECT @intOriType = P.CardTrans_Type, 
               @dblAmount = CardTrans_Value
        FROM tblCard_Trans P--(NOLOCK)
        WHERE P.CardTrans_Code = @strUniqueID;
        DECLARE @intType INT= 0;
        IF @intOriType = 37
            BEGIN
                SET @intType = 43;
            END;
            ELSE
            IF @intOriType = 39
                BEGIN
                    SET @intType = 45;
                END;
                ELSE
                IF @intOriType = 38
                    BEGIN
                        SET @intType = 44;
                    END;
        IF @intOriType = 40
            BEGIN
                SET @intType = 43;
            END;
            ELSE
            IF @intOriType = 42
                BEGIN
                    SET @intType = 45;
                END;
                ELSE
                IF @intOriType = 41
                    BEGIN
                        SET @intType = 44;
                    END;
        DECLARE @intPaymentType INT= 1;
        DECLARE @intItemSign INT= 0;
        SELECT @intItemSign = WTransType_Sign
        FROM tblWalletTransType
        WHERE WTransType_ID = @intType;
        DECLARE @strReceiptNo NVARCHAR(50)= '';
        DECLARE @PrefixType VARCHAR(50), @intRowCount INT;
        SET @PrefixType = 'Receipt';
        EXEC sp_tblPrefixNumber_GetNextRunNumber 
             'Payment', 
             @PrefixType, 
             0, 
             @strReceiptNo OUTPUT;

        --Declare @dblTotalNet money = @dblAmount * @intItemSign
        DECLARE @dblTotalNet MONEY= @dblAmount * -1;
        --
        DECLARE @oldbalance1 DECIMAL(18, 2);
        DECLARE @newbalance1 DECIMAL(18, 2);
        IF @intType = 43
            BEGIN
                UPDATE tblCard
                  SET 
                      @oldbalance1 = Card_Balance, 
                      @newbalance1 = Card_Balance + @dblTotalNet, 
                      Card_Balance = Card_Balance + @dblTotalNet, 
                      Card_balance_Edit_DateTime = GETDATE(), 
                      Card_without_sync = 1
                WHERE Card_SerialNo = @strCardNo;
				set @CardId=@strCardNo
            END;
        IF @intType = 45
            BEGIN
                UPDATE tblCard
                  SET 
                      @oldbalance1 = Card_Balance_Cashable_No, 
                      @newbalance1 = Card_Balance_Cashable_No + @dblTotalNet, 
                      Card_Balance_Cashable_No = Card_Balance_Cashable_No + @dblTotalNet, 
                      Card_balance_Edit_DateTime = GETDATE(), 
                      Card_without_sync = 1
                WHERE Card_SerialNo = @strCardNo;
				set @CardId=@strCardNo
            END;
        IF @intType = 44
            BEGIN
                UPDATE tblCard
                  SET 
                      @oldbalance1 = Card_Balance_Cashable, 
                      @newbalance1 = Card_Balance_Cashable + @dblTotalNet, 
                      Card_Balance_Cashable = Card_Balance_Cashable + @dblTotalNet, 
                      Card_balance_Edit_DateTime = GETDATE(), 
                      Card_without_sync = 1
                WHERE Card_SerialNo = @strCardNo;
				set @CardId=@strCardNo
            END;

        --
        --

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
         CardTrans_InitialAmount, 
         tblCard_Trans.CardTrans_FinalAmount
        )
        VALUES
        (@strReceiptNo, 
         @strCardNo, 
         GETDATE(), 
         @intType, 
         @dblTotalNet, 
         @dblAmount, 
         @strUniqueID, 
         @strUserID, 
         GETDATE(), 
         '', 
         @intPaymentType, 
         @oldbalance1, 
         @newbalance1
        );
        SELECT @ID = SCOPE_IDENTITY();

        --
        UPDATE tblCard_Trans
          SET 
              CardTrans_PaymentMode = 15
        WHERE CardTrans_Code = @strUniqueID;
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        ROLLBACK TRANSACTION;
        RETURN(@@ERROR);
    END;
