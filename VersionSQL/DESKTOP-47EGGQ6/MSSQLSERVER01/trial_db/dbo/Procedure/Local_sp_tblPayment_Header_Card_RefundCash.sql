/****** Object:  Procedure [dbo].[Local_sp_tblPayment_Header_Card_RefundCash]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Card_Add 'user001','','COUNTER1','Hallaway01',10,0,0,0,10,'',xml,'','',2,'',6,'','','',0
create PROCEDURE [dbo].[Local_sp_tblPayment_Header_Card_RefundCash]
-- Add the parameters for the stored procedure here
--@intID			nvarchar(50) OUT,
@strPOSUserCode        NVARCHAR(50), 
@strCounterCode        NVARCHAR(50), 
@strCompanyCode        NVARCHAR(50), 
@dblRefundAmount       MONEY, 
@strRemarks            NVARCHAR(MAX), 
@strCardNumber         NVARCHAR(50), 
@intPaymentType        INT, 
@strPaymentTypeRemarks NVARCHAR(50), 
@intIsRefundDeposit    INT, 
@strReceiptNo          NVARCHAR(50) OUT, 
@strClientFullName     NVARCHAR(50) OUT, 
@strClientBalance      MONEY OUT, 
@strClientPoint        DECIMAL(38, 10) OUT,
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        BEGIN TRANSACTION;
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

        --step 1

        DECLARE @transDate AS DATETIME= GETDATE();
        DECLARE @intialAmount AS MONEY= 0.00;
        DECLARE @finalAmount AS MONEY= 0.00;

        --step 1

        DECLARE @strClientUserCode NVARCHAR(50)= '';
        DECLARE @intCount_Card INT;
        DECLARE @strMobileUser NVARCHAR(50);
        SELECT @intCount_Card = COUNT(Card_ID)
        FROM tblCard
        WHERE Card_SerialNo = @strCardNumber;
        SET @strReceiptNo = '';
        SET @strMobileUser = '';
        SET @strClientFullName = '';
        SET @strClientBalance = 0;
        SET @strClientPoint = 0;
        IF @intCount_Card = 0
            BEGIN
                ROLLBACK TRANSACTION;
                SET NOCOUNT OFF;
                RETURN(-20);
            END;
        IF @intCount_Card > 0
            BEGIN
                SELECT @strMobileUser = Card_MobileUser
                FROM tblCard
                WHERE Card_SerialNo = @strCardNumber;
            END;
        DECLARE @dblCardBalance MONEY;
        SELECT @dblCardBalance = Card_Balance, 
               @strClientBalance = Card_Balance, 
               @intialAmount = Card_Balance, 
               @strClientPoint = Card_Point
        FROM tblCard
        WHERE Card_SerialNo = @strCardNumber;
        SET @strClientFullName = @strCardNumber;
        DECLARE @PrefixType VARCHAR(50), @intRowCount INT;
        SET @PrefixType = 'Receipt';
        EXEC sp_tblPrefixNumber_GetNextRunNumber 
             'Payment', 
             @PrefixType, 
             0, 
             @strReceiptNo OUTPUT;
        DECLARE @strCounterPrefix NVARCHAR(50)= '';
        SELECT @strCounterPrefix = Counter_ID
        FROM tblCounter
        WHERE Counter_Code = @strCounterCode;
        SET @strCounterPrefix = 'C' + @strCounterPrefix;
        SET @strReceiptNo = @strCounterPrefix + @strReceiptNo;
        DECLARE @dblCardTransAmt MONEY= 0;
        DECLARE @dblWalletTransAmt MONEY= 0;
        DECLARE @dblCardDepositAmt MONEY= 0;
        DECLARE @intItemSign INT= 0;
        SET @dblCardTransAmt = @dblRefundAmount;
        SELECT TOP 1 @dblCardDepositAmt = Product_UnitPrice
        FROM tblProduct P
             INNER JOIN tblWalletTransType T ON P.Product_WalletsTransType = T.WTransType_ID
        WHERE T.WTransType_Sign = 0
              AND P.Product_UnitPrice <> 0;
        SET @dblCardTransAmt = @dblRefundAmount;
        SET @dblWalletTransAmt = @dblRefundAmount; 
        --if @intIsRefundDeposit = 1
        --BEGIN
        --	set @dblCardTransAmt = @dblCardTransAmt + @dblCardDepositAmt
        --END
        --set @dblWalletTransAmt = @dblCardTransAmt

        DECLARE @intWalletTransType INT= 13;
        SET @intItemSign = -1;
        IF @strMobileUser = '' -- Mean havent attach any mobile user yet
            BEGIN
                SET @finalAmount = @intialAmount + (@dblCardTransAmt * @intItemSign);
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
                @intWalletTransType, 
                @dblCardTransAmt * @intItemSign, 
                @dblCardTransAmt, 
                @strReceiptNo, 
                @strCardNumber, 
                @transDate, 
                '', 
                @intPaymentType, 
                @intialAmount, 
                @finalAmount
                );
                UPDATE tblCard
                  SET 
                      Card_Balance = Card_Balance + (@dblCardTransAmt * @intItemSign), 
                      Card_balance_Edit_DateTime = @transDate
                WHERE Card_SerialNo = @strCardNumber;
                SELECT @strClientBalance = Card_Balance, 
                       @strClientPoint = Card_Point
                FROM tblCard
                WHERE Card_SerialNo = @strCardNumber;
                SET @strClientUserCode = @strCardNumber;
				set @CardId=@strCardNumber;
            END;
            ELSE -- Attach mobile user already
            BEGIN
                SET @strClientUserCode = '';
                SET @strClientBalance = 0;
                SET @strClientPoint = 0;
                SELECT @strClientUserCode = mUser_Code, 
                       @strClientFullName = mUser_FullName, 
                       @strClientBalance = mUser_TotalBalance
                FROM tblUserMobile
                WHERE mUser_Code = @strMobileUser;
                DECLARE @dblWalletBalance MONEY;
                DECLARE @strWalletCode NVARCHAR(50);
                SELECT @dblWalletBalance = UWallet_Balance, 
                       @strWalletCode = UWallet_Code
                FROM tblUserWallet
                WHERE UWallet_UserCode = @strClientUserCode;
                SET @strClientBalance = @dblWalletBalance;
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
                (@strReceiptNo, 
                 @strClientUserCode, 
                 @strWalletCode, 
                 @intWalletTransType, 
                 @dblWalletTransAmt * @intItemSign, 
                 @dblWalletTransAmt, 
                 @strReceiptNo, 
                 @strRemarks, 
                 @strPOSUserCode, 
                 @transDate, 
                 '', 
                 @intPaymentType, 
                 @strCardNumber
                );
                DECLARE @dblFinalNetAmount MONEY;
                SET @dblFinalNetAmount = @dblWalletTransAmt * @intItemSign; -- Make it negative if minus

                UPDATE tblUserWallet
                  SET 
                      UWallet_Balance = UWallet_Balance + @dblFinalNetAmount
                WHERE UWallet_Code = @strWalletCode;
                SELECT @dblWalletBalance = UWallet_Balance
                FROM tblUserWallet
                WHERE UWallet_UserCode = @strClientUserCode;
                SET @strClientBalance = @dblWalletBalance;
                UPDATE tblUserMobile
                  SET 
                      mUser_RandomCode = NULL, 
                      mUser_TotalBalance = @strClientBalance
                WHERE mUser_Code = @strClientUserCode;

                -- Calc point
                DECLARE @dblDefaultPointRate MONEY;
                SELECT @dblDefaultPointRate = WTransType_DefaultPointRate
                FROM tblWalletTransType
                WHERE WTransType_ID = @intWalletTransType;
                DECLARE @dblTotalPointEarn DECIMAL(38, 10)= 0;
                SET @dblTotalPointEarn = @dblWalletTransAmt * @dblDefaultPointRate;
                IF @dblDefaultPointRate <> 0
                    BEGIN
                        INSERT INTO tblPointTrans
                        (PointTrans_Code, 
                         PointTrans_UserCode, 
                         PointTrans_Type, 
                         PointTrans_Value, 
                         PointTrans_PointValue, 
                         PointTrans_RefCode, 
                         PointTrans_Remarks, 
                         PointTrans_CreatedBy, 
                         PointTrans_CreatedDate, 
                         PointTrans_CampaignCode, 
                         PointTrans_QRCodeText, 
                         PointTrans_WalletAmt, 
                         PointTrans_Ratio
                        )
                        VALUES
                        (@strReceiptNo, 
                         @strClientUserCode, 
                         @intWalletTransType, 
                         @dblTotalPointEarn, 
                         @dblTotalPointEarn, 
                         @strReceiptNo, 
                         @strRemarks, 
                         @strPOSUserCode, 
                         @transDate, 
                         '', 
                         @strCardNumber, 
                         @dblWalletTransAmt, 
                         @dblDefaultPointRate
                        );
                    END;
                UPDATE tblUserMobile
                  SET 
                      mUser_RandomCode = NULL, 
                      mUser_TotalBalance = @strClientBalance, 
                      mUser_TotalPoint = mUser_TotalPoint + @dblTotalPointEarn
                WHERE mUser_Code = @strClientUserCode;
                SELECT @strClientUserCode = mUser_Code, 
                       @strClientFullName = mUser_FullName, 
                       @strClientBalance = mUser_TotalBalance, 
                       @strClientPoint = mUser_TotalPoint
                FROM tblUserMobile
                WHERE mUser_Code = @strMobileUser;
            END;

        --- INsert receipt info
        DECLARE @dblGrossAmt MONEY= @dblWalletTransAmt * @intItemSign;
        DECLARE @dblNetAmount MONEY= @dblWalletTransAmt * @intItemSign;
        DECLARE @dblRoundUp MONEY= 0;
        DECLARE @dblGlobalDiscount MONEY= 0;
        DECLARE @dblTaxAmt MONEY= 0;
        DECLARE @intDiscountMode MONEY= 0;
        IF @intIsRefundDeposit = 1
            BEGIN
                SET @dblGrossAmt = @dblGrossAmt + (@dblCardDepositAmt * @intItemSign);
                SET @dblNetAmount = @dblNetAmount + (@dblCardDepositAmt * @intItemSign);
            END;
        INSERT INTO tblPayment_Header
        (Payment_ReceiptNo, 
         Payment_Date, 
         Payment_GrossAmt, 
         Payment_DiscountAmt, 
         Payment_NetAmt, 
         Payment_RoundUp, 
         Payment_FinalAmt, 
         Payment_CounterCode, 
         Payment_PaymentType, 
         Payment_PayAmt, 
         Payment_ReturnAmt, 
         Payment_Status, 
         Payment_CreatedDate, 
         Payment_CardNumber, 
         Payment_CardType, 
         Payment_RefundCode, 
         Payment_UserCode, 
         Payment_GlobalDiscount, 
         Payment_GlobalDiscountAmt, 
         Payment_AdjustmentAmt, 
         Payment_IsSettlement, 
         Payment_TotalTaxAmt, 
         Payment_CreatedBy, 
         Payment_Remarks, 
         Payment_DiscountMode
        )
        VALUES
        (@strReceiptNo, 
         @transDate, 
         @dblGrossAmt, 
         0, 
         @dblNetAmount, 
         @dblRoundUp, 
         @dblNetAmount, 
         @strCounterCode, 
         @intPaymentType, 
         @dblNetAmount, 
         0, 
         0, 
         @transDate, 
         @strPaymentTypeRemarks, 
         0, 
         '', 
         @strClientUserCode, 
         @dblGlobalDiscount, 
         @dblGlobalDiscount, 
         0, 
         0, 
         @dblTaxAmt, 
         @strPOSUserCode, 
         @strRemarks, 
         @intDiscountMode
        );

        -- INsert refund cash amt
        --Refund Cash, Have to insert
        DECLARE @strItemCode NVARCHAR(50);
        DECLARE @strItemUOM NVARCHAR(50);
        DECLARE @intQty INT= 1;
        SELECT @strItemCode = Product_ItemCode, 
               @strItemUOM = Product_UOM
        FROM tblProduct 
        --where Product_Desc = 'Refund Cash'
        WHERE Product_ItemCode = 'P0814';
        INSERT INTO tblPayment_Details
        (PaymentD_ReceiptNo, 
         PaymentD_ItemCode, 
         PaymentD_UOM, 
         PaymentD_UnitPrice, 
         PaymentD_DiscountPercent, 
         PaymentD_DiscountAmt, 
         PaymentD_NetAmount, 
         PaymentD_TransDate, 
         PaymentD_Qty, 
         PaymentD_CreatedDate, 
         PaymentD_UnitCost, 
         PaymentD_TaxCode, 
         PaymentD_TaxRate, 
         PaymentD_TaxAmt, 
         PaymentD_RunNo
        )
        VALUES
        (@strReceiptNo, 
         @strItemCode, 
         @strItemUOM, 
         @dblRefundAmount * @intItemSign, 
         0, 
         0, 
         @dblRefundAmount * @intItemSign, 
         @transDate, 
         @intQty, 
         @transDate, 
         @dblRefundAmount * @intItemSign, 
         'ZR', 
         0, 
         0, 
         1
        );
        IF @intIsRefundDeposit = 1
            BEGIN
                --select @strItemCode = Product_ItemCode, @strItemUOM = Product_UOM from tblProduct where Product_Desc = 'Card - Deposit'

                SELECT TOP 1 @strItemCode = P.Product_ItemCode, 
                             @strItemUOM = P.Product_UOM
                FROM tblProduct P
                     INNER JOIN tblWalletTransType T ON P.Product_WalletsTransType = T.WTransType_ID
                WHERE T.WTransType_Sign = 0
                      AND P.Product_UnitPrice <> 0;
                INSERT INTO tblPayment_Details
                (PaymentD_ReceiptNo, 
                 PaymentD_ItemCode, 
                 PaymentD_UOM, 
                 PaymentD_UnitPrice, 
                 PaymentD_DiscountPercent, 
                 PaymentD_DiscountAmt, 
                 PaymentD_NetAmount, 
                 PaymentD_TransDate, 
                 PaymentD_Qty, 
                 PaymentD_CreatedDate, 
                 PaymentD_UnitCost, 
                 PaymentD_TaxCode, 
                 PaymentD_TaxRate, 
                 PaymentD_TaxAmt, 
                 PaymentD_RunNo
                )
                VALUES
                (@strReceiptNo, 
                 @strItemCode, 
                 @strItemUOM, 
                 @dblCardDepositAmt * @intItemSign, 
                 0, 
                 0, 
                 @dblCardDepositAmt * @intItemSign, 
                 @transDate, 
                 @intQty, 
                 @transDate, 
                 @dblCardDepositAmt * @intItemSign, 
                 'ZR', 
                 0, 
                 0, 
                 1
                );
            END;
        UPDATE tblPayment_Details
          SET 
              PaymentD_ItemName = Product_Desc, 
              PaymentD_ItemNameChi = Product_ChiDesc, 
              PaymentD_PrinterName = ''
        FROM tblPayment_Details d
             INNER JOIN tblProduct P ON d.PaymentD_ItemCode = P.Product_ItemCode
        WHERE PaymentD_ReceiptNo = @strReceiptNo
              AND PaymentD_ItemName = '';
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        ROLLBACK TRANSACTION;
        RETURN(@@ERROR);
    END;
