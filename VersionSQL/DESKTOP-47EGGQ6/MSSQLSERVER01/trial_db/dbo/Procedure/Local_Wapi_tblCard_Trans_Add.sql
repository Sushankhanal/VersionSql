/****** Object:  Procedure [dbo].[Local_Wapi_tblCard_Trans_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
--exec Wapi_tblCard_Trans_Add '23432532',22,100,'','','',''
CREATE PROCEDURE [dbo].[Local_Wapi_tblCard_Trans_Add]
-- Add the parameters for the stored procedure her
@strCardNumber      NVARCHAR(50), 
@intTransType       INT, 
@dblValue           MONEY, 
@strRemarks         NVARCHAR(50), 
@strUserID          NVARCHAR(50), 
@strManagerLogin    NVARCHAR(50) = '', 
@strManagerPassword NVARCHAR(50) = '',
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

        DECLARE @intID BIGINT= 0;
        DECLARE @strResultText NVARCHAR(255)= '';
        DECLARE @intResultCode INT= 0;
        DECLARE @PrefixType VARCHAR(50), @intRowCount INT;
        DECLARE @strReceiptNo NVARCHAR(50)= '';
        --if @intTransType = 22 or @intTransType = 23 or @intTransType = 24
        --BEGIN
        --	Declare @intCount int = 0
        --	select @intCount = COUNT(P.POSUser_ID) from tblPOSUser P (NOLOCK) where P.POSUser_UserType = 1 and
        --	POSUser_LoginID = @strManagerLogin and 
        --	POSUser_Password = @strManagerPassword
        --	if @intCount = 0
        --	BEGIN
        --		set @intResultCode = -1
        --		set @strResultText = 'Invalid manager login and password.'
        --		--RAISERROR (@strResultText,16,1);  
        --		ROLLBACK TRANSACTION
        --		SET NOCOUNT OFF
        --		select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
        --		Return @intResultCode
        --	END
        --END

        SET @PrefixType = 'Receipt';
        EXEC sp_tblPrefixNumber_GetNextRunNumber 
             'Payment', 
             @PrefixType, 
             0, 
             @strReceiptNo OUTPUT;

        --DECLARE @strCompanyCode nvarchar(50)
        --select @strCompanyCode = Branch_CompanyCode from tblBranch where Branch_Code = @strBranchCode

        DECLARE @intPaymentType INT= 1;
        DECLARE @intItemSign INT= 0;

        --
        SELECT @intItemSign = WTransType_Sign
        FROM tblWalletTransType
        WHERE WTransType_ID = @intTransType;

        --
        --step 2

        IF @intTransType = 22
            BEGIN
                SELECT @intialAmount = C.Card_Balance
                FROM tblCard C
                WHERE Card_SerialNo = @strCardNumber;
                --
                SET @finalAmount = @intialAmount + @dblValue;
            END;

        --step 2
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
        @intialAmount, 
        @finalAmount
        );
        SELECT @intID = SCOPE_IDENTITY();
        IF @intTransType = 22
            BEGIN
                UPDATE tblCard
                  SET 
                      Card_Balance = Card_Balance + @dblValue,
					  Card_balance_Edit_DateTime = @transDate
                WHERE Card_SerialNo = @strCardNumber;
				set @CardId=@strCardNumber
            END;
        IF @intTransType = 23
            BEGIN
                UPDATE tblCard
                  SET 
                      Card_Balance_Cashable_No = Card_Balance_Cashable_No + @dblValue
                WHERE Card_SerialNo = @strCardNumber;
				set @CardId=@strCardNumber
            END;
        IF @intTransType = 24
            BEGIN
                UPDATE tblCard
                  SET 
                      Card_Balance_Cashable = Card_Balance_Cashable + @dblValue
                WHERE Card_SerialNo = @strCardNumber;
				set @CardId=@strCardNumber
            END;
        SET @intResultCode = @intID;
        SET @strResultText = 'Success';
        SELECT @intResultCode AS RETURN_RESULT, 
               @strResultText AS RETURN_RESULT_TEXT;
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        ROLLBACK TRANSACTION;
        RETURN(@@ERROR);
    END;
