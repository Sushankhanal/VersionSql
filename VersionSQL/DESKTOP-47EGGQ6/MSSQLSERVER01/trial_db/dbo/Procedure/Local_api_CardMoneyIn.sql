/****** Object:  Procedure [dbo].[Local_api_CardMoneyIn]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Local_api_CardMoneyIn]
-- Add the parameters for the stored procedure here
@strUniqueID    NVARCHAR(50), 
@strCardNo      NVARCHAR(50), 
@dblAmount      MONEY, 
@intType        INT, 
@strCompanyCode NVARCHAR(50)
AS
    BEGIN

        -- SET NOCOUNT ON addedto prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @ID BIGINT= 0;
        DECLARE @strErrorText NVARCHAR(255)= '';
        DECLARE @intErrorCode INT= 0;
        DECLARE @intCount INT= 0;
        PRINT 1;
		--SELECT @intCount = COUNT(P.CardTrans_ID)
  --      FROM [CloudServer].POSv3.dbo.tblCard_Trans P --(NOLOCK)
  --      WHERE P.CardTrans_Code = 'RE00004209';
		
        SELECT @intCount = COUNT(P.CardTrans_ID)
        FROM tblCard_Trans P --(NOLOCK)
        WHERE P.CardTrans_Code = @strUniqueID;
        IF @intCount <> 0
            BEGIN
			print 100

                --set @intErrorCode = -1
                --set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
                --' - Unqiue number duplicate'
                --RAISERROR (@strErrorText,16,1);  
                --ROLLBACK TRANSACTION
                --SET NOCOUNT OFF
                --Return @intErrorCode

                SET @intErrorCode = 0;
                SET @strErrorText = 'Save Successful';
                -- COMMIT TRANSACTION;
                SET NOCOUNT OFF;
                RETURN @intErrorCode;
			
            END;
        SELECT @intCount = COUNT(C.Card_ID)
        FROM [CloudServer].POSv3.dbo.tblCard C--(NOLOCK)
        WHERE C.Card_SerialNo = @strCardNo;
   --     IF @intCount = 0
   --         BEGIN
			--print 3
   --             SET @intErrorCode = -2;
   --             SET @strErrorText = 'Error Code: ' + CONVERT(NVARCHAR(50), @intErrorCode) + ' - Card number not exist';
   --             RAISERROR(@strErrorText, 16, 1);
   --             --ROLLBACK TRANSACTION;
   --             SET NOCOUNT OFF;
   --             RETURN @intErrorCode;
   --         END;
        DECLARE @strUserID BIGINT= -80;
        DECLARE @intPaymentType INT= 1;
        DECLARE @intItemSign INT= 0;
        SELECT @intItemSign = WTransType_Sign
        FROM tblWalletTransType
        WHERE WTransType_ID = @intType;
        DECLARE @oldbalance1 DECIMAL(18, 2);
        DECLARE @newbalance1 DECIMAL(18, 2);
        PRINT 5;
        BEGIN TRANSACTION;
        IF @intType = 37
            BEGIN
			print 2
                UPDATE [CloudServer].POSv3.dbo.tblCard
                  SET 
                      @oldbalance1 = Card_Balance, 
                      @newbalance1 = Card_Balance + @dblAmount, 
                      Card_Balance = Card_Balance + @dblAmount, 
                      Card_balance_Edit_DateTime = GETDATE(), 
                      Card_without_sync = 1
                WHERE Card_SerialNo = @strCardNo;
            END;
        IF @intType = 39
            BEGIN
                UPDATE [CloudServer].POSv3.dbo.tblCard
                  SET 
                      @oldbalance1 = Card_Balance_Cashable_No, 
                      @newbalance1 = Card_Balance_Cashable_No + @dblAmount, 
                      Card_Balance_Cashable_No = Card_Balance_Cashable_No + @dblAmount, 
                      Card_balance_Edit_DateTime = GETDATE(), 
                      Card_without_sync = 1
                WHERE Card_SerialNo = @strCardNo;
            END;
        IF @intType = 38
            BEGIN
                UPDATE [CloudServer].POSv3.dbo.tblCard
                  SET 
                      @oldbalance1 = Card_Balance_Cashable, 
                      @newbalance1 = Card_Balance_Cashable + @dblAmount, 
                      Card_Balance_Cashable = Card_Balance_Cashable + @dblAmount, 
                      Card_balance_Edit_DateTime = GETDATE(), 
                      Card_without_sync = 1
                WHERE Card_SerialNo = @strCardNo;
            END;
        PRINT 6;
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
                      @newbalance1;
        --WHERE NOT EXISTS
        --(
        --    SELECT 1
        --    FROM tblCard_Trans P --(NOLOCK)
        --    WHERE P.CardTrans_Code = @strUniqueID
        --);
        IF @@ROWCOUNT = 0
            BEGIN
                GOTO ErrorHandler;
            END;
        SELECT @ID = SCOPE_IDENTITY();
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
		print 20
        ROLLBACK TRANSACTION;
        RETURN(@@ERROR);
    END;
