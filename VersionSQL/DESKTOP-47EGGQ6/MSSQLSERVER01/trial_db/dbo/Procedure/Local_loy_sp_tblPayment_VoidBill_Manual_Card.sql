/****** Object:  Procedure [dbo].[Local_loy_sp_tblPayment_VoidBill_Manual_Card]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec loy_sp_tblPayment_VoidBill_Manual_Card 'user1','user1','hallaway01','C1RE00000804','0010460954','','',0
CREATE PROCEDURE [dbo].[Local_loy_sp_tblPayment_VoidBill_Manual_Card]
-- Add the parameters for the stored procedure here
--@intID			nvarchar(50) OUT,
@strPOSUserCode    NVARCHAR(50), 
@strClientUserCode NVARCHAR(50), 
@strCompanyCode    NVARCHAR(50), 
@strReceiptNo      NVARCHAR(50), 
@strCardNumber     NVARCHAR(50), 
@strNewReceiptNo   NVARCHAR(50) OUT, 
@strClientFullName NVARCHAR(50) OUT, 
@strClientBalance  MONEY OUT,
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        BEGIN TRANSACTION;
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @transDate AS DATETIME= GETDATE();
        DECLARE @intialAmount AS MONEY= 0.00;
        DECLARE @finalAmount AS MONEY= 0.00;
        DECLARE @strClientRandomCode NVARCHAR(1024);
        SET @strClientUserCode = @strCardNumber;
        SET @strClientFullName = '';
        SET @strClientRandomCode = '';
        SELECT @strClientFullName = CO.CardOwner_Name, 
               @strClientBalance = C.Card_Balance, 
               @intialAmount = C.Card_Balance
        FROM tblCard C
             INNER JOIN tblCardOwner CO ON C.Card_CardOwner_ID = CO.CardOwner_ID
        WHERE Card_SerialNo = @strCardNumber;
        SET @strClientBalance = 0;
        IF @strClientFullName = ''
            BEGIN
                SET @strClientFullName = '';
                SET @strClientBalance = 0;
                COMMIT TRANSACTION;
                SET NOCOUNT OFF;
                RETURN(-6);
            END;

        --Declare @intCount_CorrectUserCode int
        --select @intCount_CorrectUserCode = payment_isRefund from tblPayment_Header where Payment_ReceiptNo = @strReceiptNo

        DECLARE @intCount INT;
        SELECT @intCount = ISNULL(COUNT(Payment_ID), 0)
        FROM tblPayment_Header
        WHERE Payment_ReceiptNo = @strReceiptNo
              AND Payment_UserCode = @strCardNumber;
        IF @intCount = 0
            BEGIN
                COMMIT TRANSACTION;
                SET NOCOUNT OFF;
                --print -1
                RETURN(-1);
            END;
            ELSE
            BEGIN
                DECLARE @intIsRefund INT;
                DECLARE @strReceiptUserCode NVARCHAR(50);
                DECLARE @Payment_TableCode NVARCHAR(1024);
                DECLARE @Payment_Remarks NVARCHAR(1024);
                SELECT @intIsRefund = payment_isRefund, 
                       @strReceiptUserCode = Payment_UserCode, 
                       @Payment_TableCode = tblPayment_Header.Payment_TableCode, 
                       @Payment_Remarks = tblPayment_Header.Payment_Remarks
                FROM tblPayment_Header
                WHERE Payment_ReceiptNo = @strReceiptNo;
                IF @strCardNumber <> @strReceiptUserCode
                    BEGIN
                        COMMIT TRANSACTION;
                        SET NOCOUNT OFF;
                        RETURN(-8);
                    END;
                IF @intIsRefund = 0
                    BEGIN
                        DECLARE @PrefixType VARCHAR(50), @intRowCount INT;
                        --Declare @strNewReceiptNo nvarchar(50)
                        SET @PrefixType = 'Receipt';
                        EXEC sp_tblPrefixNumber_GetNextRunNumber 
                             'Payment', 
                             @PrefixType, 
                             0, 
                             @strNewReceiptNo OUTPUT;
                        DECLARE @intPaymentType INT;
                        SET @intPaymentType = 10;
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
                         Payment_IsRefund, 
                         Payment_CreatedBy, 
                         Payment_TableCode, 
                         Payment_Remarks
                        )
                               SELECT @strNewReceiptNo, 
                                      @transDate, 
                                      Payment_GrossAmt * -1, 
                                      Payment_DiscountAmt * -1, 
                                      Payment_NetAmt * -1, 
                                      Payment_RoundUp * -1, 
                                      Payment_FinalAmt * -1, 
                                      Payment_CounterCode, 
                                      Payment_PaymentType, 
                                      Payment_PayAmt * -1, 
                                      Payment_ReturnAmt * -1, 
                                      Payment_Status, 
                                      @transDate, 
                                      Payment_CardNumber, 
                                      Payment_CardType, 
                                      @strReceiptNo, 
                                      @strCardNumber, 
                                      Payment_GlobalDiscount * -1, 
                                      Payment_GlobalDiscountAmt * -1, 
                                      Payment_AdjustmentAmt * -1, 
                                      Payment_IsSettlement, 
                                      Payment_TotalTaxAmt * -1, 
                                      2, 
                                      @strPOSUserCode, 
                                      @Payment_TableCode, 
                                      'Voided : (' + @Payment_Remarks + ')'
                               FROM tblPayment_Header
                               WHERE Payment_ReceiptNo = @strReceiptNo;
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
                         PaymentD_TaxAmt
                        )
                               SELECT @strNewReceiptNo, 
                                      PaymentD_ItemCode, 
                                      PaymentD_UOM, 
                                      PaymentD_UnitPrice, 
                                      PaymentD_DiscountPercent * -1, 
                                      PaymentD_DiscountAmt * -1, 
                                      PaymentD_NetAmount * -1, 
                                      @transDate, 
                                      PaymentD_Qty * -1, 
                                      @transDate, 
                                      PaymentD_UnitCost, 
                                      PaymentD_TaxCode, 
                                      PaymentD_TaxRate, 
                                      PaymentD_TaxAmt * -1
                               FROM tblPayment_Details
                               WHERE PaymentD_ReceiptNo = @strReceiptNo;
                        DECLARE @intWalletTransType INT= 0;
                        DECLARE @intWalletTransType_Refund INT= 0;
                        --set @intWalletTransType = 3
                        SELECT TOP 1 @intWalletTransType = Product_WalletsTransType
                        FROM tblPayment_Details
                             INNER JOIN tblProduct ON PaymentD_ItemCode = Product_ItemCode
                             INNER JOIN tblWalletTransType ON Product_WalletsTransType = WTransType_ID
                        WHERE PaymentD_ReceiptNo = @strReceiptNo;
                        IF(@intWalletTransType = 2
                           OR @intWalletTransType = 14)
                            BEGIN
                                SET @intWalletTransType_Refund = 3;  --Void 
                            END;
                            ELSE
                            IF @intWalletTransType = 16
                                BEGIN
                                    SET @intWalletTransType_Refund = 18;  --Void by Non-Cashable
                                END;
                                ELSE
                                IF @intWalletTransType = 17
                                    BEGIN
                                        SET @intWalletTransType_Refund = 19;  --Void by Cashable
                                    END;
                        DECLARE @dblNetAmt MONEY= 0;
                        SELECT @dblNetAmt = Payment_FinalAmt
                        FROM tblPayment_Header
                        WHERE Payment_ReceiptNo = @strReceiptNo;
                        IF(@intWalletTransType = 2
                           OR @intWalletTransType = 14)
                            BEGIN
                                SET @finalAmount = @intialAmount + @dblNetAmt;
                            END;
                            ELSE
                            BEGIN
                                SET @intialAmount = 0;
                                SET @finalAmount = 0;
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
                         CardTrans_FinalAmount, 
                         CardTrans_InitialAmount
                        )
                        VALUES
                        (@strNewReceiptNo, 
                         @strCardNumber, 
                         @transDate, 
                         @intWalletTransType_Refund, 
                         @dblNetAmt, 
                         @dblNetAmt, 
                         @strReceiptNo, 
                         @strCardNumber, 
                         @transDate, 
                         '', 
                         @intPaymentType, 
                         @finalAmount, 
                         @intialAmount
                        );
                        UPDATE tblPayment_Header
                          SET 
                              Payment_IsRefund = 1
                        WHERE Payment_ReceiptNo = @strReceiptNo;
                        DECLARE @dblNetAmount MONEY;
                        SET @dblNetAmount = 0;
                        SELECT @dblNetAmount = Payment_FinalAmt
                        FROM tblPayment_Header
                        WHERE Payment_ReceiptNo = @strReceiptNo;
                        IF(@intWalletTransType = 2
                           OR @intWalletTransType = 14)
                            BEGIN
                                --Void
                                UPDATE tblCard
                                  SET 
                                      Card_Balance = Card_Balance + @dblNetAmount, 
                                      Card_balance_Edit_DateTime = @transDate
                                WHERE Card_SerialNo = @strCardNumber;
								set @CardId=@strCardNumber;
                            END;
                            ELSE
                            IF @intWalletTransType = 16
                                BEGIN
                                    --Void by Non-Cashable
                                    UPDATE tblCard
                                      SET 
                                          Card_Balance_Cashable_No = Card_Balance_Cashable_No + @dblNetAmount
                                    WHERE Card_SerialNo = @strCardNumber;
									set @CardId=@strCardNumber;
                                END;
                                ELSE
                                IF @intWalletTransType = 17
                                    BEGIN
                                        --Void by Cashable
                                        UPDATE tblCard
                                          SET 
                                              Card_Balance_Cashable = Card_Balance_Cashable + @dblNetAmount
                                        WHERE Card_SerialNo = @strCardNumber;
										set @CardId=@strCardNumber;
                                    END;
                        SELECT @strClientBalance = Card_Balance
                        FROM tblCard
                        WHERE Card_SerialNo = @strCardNumber;
                        --set @strClientBalance = @dblWalletBalance
                        --Update tblUserMobile set mUser_RandomCode = NULL, 
                        --mUser_TotalBalance = @strClientBalance where mUser_Code = @strClientUserCode
                        --Declare @intPointTransType int = 3
                        --	Declare @strPointRemarks nvarchar(50) =''
                        --	set @strPointRemarks = 'Void from ' + @strReceiptNo
                        --	INSERT INTO tblPointTrans
                        --	(PointTrans_Code, PointTrans_UserCode, PointTrans_Type, PointTrans_Value, PointTrans_PointValue, 
                        --	PointTrans_RefCode, PointTrans_Remarks, PointTrans_CreatedBy, PointTrans_CreatedDate, PointTrans_CampaignCode, 
                        --	PointTrans_QRCodeText, PointTrans_WalletAmt, PointTrans_Ratio)
                        --	select @strNewReceiptNo, PointTrans_UserCode, @intPointTransType, PointTrans_Value * -1, 
                        --	PointTrans_PointValue, @strReceiptNo, @strPointRemarks, @strPOSUserCode, GETDATE(), 
                        --             '', '', PointTrans_WalletAmt, PointTrans_Ratio * -1
                        --	from tblPointTrans where PointTrans_Code = @strReceiptNo
                        --	Declare @dblTotalAddMinusPoint money =0
                        --	select @dblTotalAddMinusPoint = ISNULL(SUM(PointTrans_Value),0) from tblPointTrans where PointTrans_Code = @strNewReceiptNo
                        --	Update tblUserMobile set mUser_TotalPoint = mUser_TotalPoint + @dblTotalAddMinusPoint
                        --	where mUser_Code = @strClientUserCode

                        DECLARE @intRedeemType INT= 11;
                        IF
                        (
                            SELECT COUNT(T.CardPointTrans_ID)
                            FROM tblCardPointTrans T(NOLOCK)
                            WHERE T.CardPointTrans_Code = @strReceiptNo + '-3'
                                  AND T.CardPointTrans_Type = @intRedeemType
                        ) > 0
                            BEGIN
                                DECLARE @RedeemPoint DECIMAL(38, 10)= 0;
                                SELECT @RedeemPoint = T.CardPointTrans_PointValue
                                FROM tblCardPointTrans T(NOLOCK)
                                WHERE T.CardPointTrans_Code = @strReceiptNo + '-3'
                                      AND T.CardPointTrans_Type = @intRedeemType;
                                DECLARE @strRemarks NVARCHAR(50)= 'Void from ' + @strReceiptNo + '-3';
                                INSERT INTO tblCardPointTrans
                                (CardPointTrans_Code, 
                                 CardPointTrans_SerialNo, 
                                 CardPointTrans_Type, 
                                 CardPointTrans_Value, 
                                 CardPointTrans_PointValue, 
                                 CardPointTrans_RefCode, 
                                 CardPointTrans_Remarks, 
                                 CardPointTrans_CreatedBy, 
                                 CardPointTrans_CreatedDate, 
                                 CardPointTrans_CampaignCode, 
                                 CardPointTrans_QRCodeText, 
                                 CardPointTrans_WalletAmt, 
                                 CardPointTrans_Ratio
                                )
                                VALUES
                                (@strNewReceiptNo, 
                                 @strCardNumber, 
                                 3, 
                                 @RedeemPoint, 
                                 @RedeemPoint, 
                                 @strReceiptNo, 
                                 @strRemarks, 
                                 @strPOSUserCode, 
                                 @transDate, 
                                 '', 
                                 @strCardNumber, 
                                 0, 
                                 0
                                );
                                UPDATE tblCard
                                  SET 
                                      Card_Point = Card_Point + @RedeemPoint
                                WHERE Card_SerialNo = @strCardNumber;
								set @CardId=@strCardNumber;
                            END;
                    END;
                    ELSE
                    BEGIN
                        COMMIT TRANSACTION;
                        SET NOCOUNT OFF;
                        --print -2
                        RETURN(-2);
                    END;
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
