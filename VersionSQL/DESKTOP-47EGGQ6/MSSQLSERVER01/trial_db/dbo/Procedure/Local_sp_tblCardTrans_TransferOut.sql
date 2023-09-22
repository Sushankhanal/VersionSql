/****** Object:  Procedure [dbo].[Local_sp_tblCardTrans_TransferOut]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblCardTrans_TransferOut '1234567890','60124536362'
-- sp_tblCardTrans_TransferOut(CardSerialNo,MobileUserCode)
create PROCEDURE [dbo].[Local_sp_tblCardTrans_TransferOut]
-- Add the parameters for the stored procedure here
@strCardSerialNumber NVARCHAR(50), 
@strMobileUserCode   NVARCHAR(50),
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        BEGIN TRANSACTION;

        --step 1

        DECLARE @transDate AS DATETIME= GETDATE();
        DECLARE @intialAmount AS MONEY= 0.00;
        DECLARE @finalAmount AS MONEY= 0.00;

        --step 1
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @intCount_Card INT;
        SELECT @intCount_Card = COUNT(Card_ID)
        FROM tblCard
        WHERE Card_SerialNo = @strCardSerialNumber
              AND Card_Status = 0;
        IF @intCount_Card = 0
            BEGIN
                RAISERROR('Card Number not existed', 16, 1);
                COMMIT TRANSACTION;
                SET NOCOUNT OFF;
                RETURN(-20);
                --  card number not exist
            END;
        DECLARE @intCount_User INT;
        SELECT @intCount_User = COUNT(mUser_ID)
        FROM tblUserMobile
        WHERE mUser_Code = @strMobileUserCode;
        IF @intCount_User = 0
            BEGIN
                RAISERROR('User Code/Mobile Number not existed', 16, 1);
                COMMIT TRANSACTION;
                SET NOCOUNT OFF;
                RETURN(-30);
                --  user code/mobile number not exist
            END;
        DECLARE @PrefixType VARCHAR(50), @intRowCount INT;
        DECLARE @strCardTrans NVARCHAR(50);
        SET @strCardTrans = '';
        SET @PrefixType = 'CardTrans';
        EXEC sp_tblPrefixNumber_GetNextRunNumber 
             'CardTrans', 
             @PrefixType, 
             0, 
             @strCardTrans OUTPUT;
        DECLARE @intType INT;
        SET @intType = 5;
        DECLARE @dblCardBalance MONEY;
        SET @dblCardBalance = 0;
        SELECT @dblCardBalance = Card_Balance
        FROM tblCard
        WHERE Card_SerialNo = @strCardSerialNumber;
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
         CardTrans_PaymentMode
        )
        VALUES
        (@strCardTrans, 
         @strCardSerialNumber, 
         @transDate, 
         @intType, 
         @dblCardBalance * -1, 
         @dblCardBalance, 
         '', 
         @strMobileUserCode, 
         @transDate, 
         '', 
         6
        );
        DECLARE @dblWalletBalance MONEY;
        DECLARE @strWalletCode NVARCHAR(50);
        SELECT @dblWalletBalance = UWallet_Balance, 
               @strWalletCode = UWallet_Code
        FROM tblUserWallet
        WHERE UWallet_UserCode = @strMobileUserCode;
        DECLARE @intWalletTransType INT;
        SET @intWalletTransType = 4;
        INSERT INTO tblWalletTrans
        (WalletTrans_Code, 
         WalletTrans_UserCode, 
         WalletTrans_WalletCode, 
         WalletTrans_Type, 
         WalletTrans_Value, 
         WalletTrans_MoneyValue, 
         WalletTrans_RefCode, 
         WalletTrans_Remarks, 
         WalletTrans_CreatedBy, 
         WalletTrans_CreatedDate, 
         WalletTrans_CampaignCode, 
         WalletTrans_PaymentMode, 
         WalletTrans_QRCodeText
        )
        VALUES
        (@strCardTrans, 
         @strMobileUserCode, 
         @strWalletCode, 
         @intWalletTransType, 
         @dblCardBalance, 
         @dblCardBalance, 
         @strCardTrans, 
         '', 
         @strMobileUserCode, 
         @transDate, 
         '', 
         10, 
         @strCardSerialNumber
        );
        UPDATE tblUserMobile
          SET 
              mUser_TotalBalance = mUser_TotalBalance + @dblCardBalance
        WHERE mUser_Code = @strMobileUserCode;
        UPDATE tblCard
          SET 
              Card_Balance = Card_Balance - @dblCardBalance, 
              Card_balance_Edit_DateTime = @transDate
        WHERE Card_SerialNo = @strCardSerialNumber;
		set @CardId=@strCardSerialNumber;
        UPDATE tblUserWallet
          SET 
              UWallet_Balance = UWallet_Balance + @dblCardBalance
        WHERE UWallet_Code = @strWalletCode;
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        ROLLBACK TRANSACTION;
        RETURN(@@ERROR);
    END;
