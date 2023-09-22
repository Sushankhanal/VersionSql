/****** Object:  Procedure [dbo].[Local_api_CardMoneyOutByAmt]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_api_CardMoneyOutByAmt]
-- Add the parameters for the stored procedure here
@strUniqueID    NVARCHAR(50), 
@strCardNo      NVARCHAR(50), 
@intType        INT, 
@strCompanyCode NVARCHAR(50), 
@dblTotal       MONEY OUT, 
@dblMoneyOutAmt MONEY        = 0,
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        -- SET NOCOUNT ON addedto prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @ID BIGINT= 0;
        DECLARE @strErrorText NVARCHAR(255)= '';
        DECLARE @intErrorCode INT= 0;
        DECLARE @intCount INT= 0;
        SELECT @intCount = COUNT(P.CardTrans_ID)
        FROM tblCard_Trans P --(NOLOCK)
        WHERE P.CardTrans_Code = @strUniqueID;
        IF @intCount <> 0
            BEGIN
                --set @intErrorCode = -1
                --set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
                --' - Unqiue number duplicate'
                --RAISERROR (@strErrorText,16,1);  
                --ROLLBACK TRANSACTION
                --SET NOCOUNT OFF
                --Return @intErrorCode
                SELECT @dblTotal = CardTrans_Value
                FROM tblCard_Trans P --(NOLOCK)
                WHERE P.CardTrans_Code = @strUniqueID;
                IF @dblTotal < 0
                    BEGIN
                        SET @dblTotal = @dblTotal * -1;
                    END;
                SET @intErrorCode = 0;
                SET @strErrorText = 'Save Successful';
                -- COMMIT TRANSACTION;
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
                -- ROLLBACK TRANSACTION;
                SET NOCOUNT OFF;
                RETURN @intErrorCode;
            END;
        DECLARE @strUserID BIGINT= -80;
        DECLARE @intPaymentType INT= 1;
        DECLARE @intItemSign INT= 0;
        SELECT @intItemSign = WTransType_Sign
        FROM tblWalletTransType
        WHERE WTransType_ID = @intType;
        DECLARE @dblAmount2 MONEY= 0;
        IF @intType = 40
            BEGIN
                SELECT @dblAmount2 = Card_Balance
                FROM tblCard
                WHERE Card_SerialNo = @strCardNo;
            END;
        IF @intType = 42
            BEGIN
                SELECT @dblAmount2 = Card_Balance_Cashable_No
                FROM tblCard
                WHERE Card_SerialNo = @strCardNo;
            END;
        IF @intType = 41
            BEGIN
                SELECT @dblAmount2 = Card_Balance_Cashable
                FROM tblCard
                WHERE Card_SerialNo = @strCardNo;
            END;
        IF @dblMoneyOutAmt > @dblAmount2
            BEGIN
                SET @intErrorCode = -3;
                SET @strErrorText = 'Error Code: ' + CONVERT(NVARCHAR(50), @intErrorCode) + ' - Insufficient balance to money out';
                RAISERROR(@strErrorText, 16, 1);
                -- ROLLBACK TRANSACTION;
                SET NOCOUNT OFF;
                RETURN @intErrorCode;
            END;
        DECLARE @dblAmount MONEY= @dblMoneyOutAmt;
        DECLARE @oldbalance1 DECIMAL(18, 2);
        DECLARE @newbalance1 DECIMAL(18, 2);
        --nee trn
        BEGIN TRANSACTION;
        IF @intType = 40
            BEGIN
                UPDATE tblCard
                  SET 
                      @oldbalance1 = Card_Balance, 
                      @newbalance1 = Card_Balance - @dblAmount, 
                      Card_Balance = Card_Balance - @dblAmount, 
                      Card_balance_Edit_DateTime = GETDATE(), 
                      Card_without_sync = 1
                WHERE Card_SerialNo = @strCardNo
                      AND Card_Balance - @dblAmount >= 0;
					  set @CardId=@strCardNo
                IF @@ROWCOUNT <= 0
                    BEGIN
                        GOTO ErrorHandler;
                    END;
            END;
        IF @intType = 42
            BEGIN
                UPDATE tblCard
                  SET 
                      @oldbalance1 = Card_Balance_Cashable_No, 
                      @newbalance1 = Card_Balance_Cashable_No - @dblAmount, 
                      Card_Balance_Cashable_No = Card_Balance_Cashable_No - @dblAmount, 
                      Card_balance_Edit_DateTime = GETDATE(), 
                      Card_without_sync = 1
                WHERE Card_SerialNo = @strCardNo
                      AND Card_Balance_Cashable_No - @dblAmount >= 0;
					  set @CardId=@strCardNo
                IF @@ROWCOUNT <= 0
                    BEGIN
                        GOTO ErrorHandler;
                    END;
            END;
        IF @intType = 41
            BEGIN
                UPDATE tblCard
                  SET 
                      @oldbalance1 = Card_Balance_Cashable, 
                      @newbalance1 = Card_Balance_Cashable - @dblAmount, 
                      Card_Balance_Cashable = Card_Balance_Cashable - @dblAmount, 
                      Card_balance_Edit_DateTime = GETDATE(), 
                      Card_without_sync = 1
                WHERE Card_SerialNo = @strCardNo
                      AND Card_Balance_Cashable - @dblAmount >= 0;
					   set @CardId=@strCardNo
                IF @@ROWCOUNT <= 0
                    BEGIN
                        GOTO ErrorHandler;
                    END;
            END;
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
               SELECT @strUniqueID, 
                      @strCardNo, 
                      GETDATE(), 
                      @intType, 
                      @dblAmount * @intItemSign, 
                      @dblAmount, 
                      '', 
                      @strUserID, 
                      GETDATE(), 
                      '', 
                      @intPaymentType, 
                      @oldbalance1, 
                      @newbalance1
               WHERE NOT EXISTS
               (
                   SELECT 1
                   FROM tblCard_Trans P --(NOLOCK)
                   WHERE P.CardTrans_Code = @strUniqueID
               );
        IF @@ROWCOUNT = 0
            BEGIN
                GOTO ErrorHandler;
            END;
        SELECT @ID = SCOPE_IDENTITY();
        SET @dblTotal = @dblAmount;
        IF @dblTotal < 0
            BEGIN
                SET @dblTotal = @dblTotal * -1;
            END;
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        ROLLBACK TRANSACTION;
        RETURN(@@ERROR);
    END;
