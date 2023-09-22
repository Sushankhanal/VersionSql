/****** Object:  Procedure [dbo].[Local_Wapi_tblCardOwner_AssignPrintCardUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_Wapi_tblCardOwner_AssignPrintCardUpdate]
-- Add the parameters for the stored procedure here
@intNewCardID     BIGINT, 
@intPlayerID      BIGINT, 
@strCreatedBy     NVARCHAR(50), 
@strCompanyCode   NVARCHAR(50), 
@strPic           NVARCHAR(50), 
@strOldCardNumber NVARCHAR(50), 
@intTransType     INT ,-- 0: New Assign, 1: Transfer
	@CardId             bigint = NULL OUTPUT

AS
    BEGIN
        BEGIN TRANSACTION;
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        SELECT TOP 1 @strCompanyCode = Company_Code
        FROM tblCompany c(NOLOCK)
        ORDER BY Company_ID;
        DECLARE @strResultText NVARCHAR(255)= '';
        DECLARE @intResultCode INT= 0;
        DECLARE @intID BIGINT= 0;
        DECLARE @strCardNumber NVARCHAR(50)= '';
        DECLARE @PrefixType VARCHAR(50)= '';
        DECLARE @strReceiptNo NVARCHAR(50)= '';
        DECLARE @intCount INT;
        DECLARE @ID INT;
        SELECT @intCount = ISNULL(COUNT(Card_ID), 0)
        FROM tblCard NOLOCK
        WHERE Card_ID = @intNewCardID;
        IF @intCount = 0
            BEGIN
                SET @intResultCode = -1;
                SET @strResultText = 'Invalid Card Number. Please try another.';
                ROLLBACK TRANSACTION;
                SET NOCOUNT OFF;
                SELECT @intResultCode AS RETURN_RESULT, 
                       @strResultText AS RETURN_RESULT_TEXT;
                RETURN(-1);
            END;
        IF @intTransType = 1
            BEGIN
                SELECT @intCount = ISNULL(COUNT(Card_ID), 0)
                FROM tblCard NOLOCK
                WHERE Card_SerialNo = @strOldCardNumber;
                IF @intCount = 0
                    BEGIN
                        SET @intResultCode = -2;
                        SET @strResultText = 'Invalid Old Card Number. Please try another.';
                        ROLLBACK TRANSACTION;
                        SET NOCOUNT OFF;
                        SELECT @intResultCode AS RETURN_RESULT, 
                               @strResultText AS RETURN_RESULT_TEXT;
                        RETURN(-1);
                    END;
            END;
        SELECT @strCardNumber = Card_SerialNo
        FROM tblCard NOLOCK
        WHERE Card_ID = @intNewCardID;
        SET @intCount = 0;
        IF @intCount = 0
            BEGIN
                DECLARE @strMobileNumber NVARCHAR(50)= '';
                SELECT @strMobileNumber = C.CardOwner_MobileNumber
                FROM tblCardOwner(NOLOCK) C
                WHERE C.CardOwner_ID = @intPlayerID;
                UPDATE tblCard
                  SET 
                      Card_img = @strPic, 
                      Card_Status = 0, 
                      Card_PrintDate = GETDATE()
                WHERE Card_ID = @intNewCardID;
				set @CardId=@intNewCardID
                SELECT @intID = @intNewCardID;
                IF @intTransType = 1
                    BEGIN
                        DECLARE @dblCard_Balance MONEY= 0;
                        DECLARE @dblCard_Point DECIMAL(38, 10)= 0;
                        DECLARE @dblCard_Balance_Cashable_No MONEY= 0;
                        DECLARE @dblCard_Balance_Cashable MONEY= 0;
                        DECLARE @dblCard_PointAccumulate DECIMAL(38, 10)= 0;
                        DECLARE @dblCard_Point_Tier DECIMAL(38, 10)= 0;
                        DECLARE @dblCard_Point_Hidden DECIMAL(38, 10)= 0;
                        DECLARE @intPaymentType INT= 1;
                        DECLARE @intItemSign INT= 0;
                        DECLARE @intCardTransType INT= 0;
                        SELECT @dblCard_Balance = Card_Balance, 
                               @dblCard_Point = Card_Point, 
                               @dblCard_Balance_Cashable_No = Card_Balance_Cashable_No, 
                               @dblCard_Balance_Cashable = Card_Balance_Cashable, 
                               @dblCard_PointAccumulate = Card_PointAccumulate, 
                               @dblCard_Point_Tier = Card_Point_Tier, 
                               @dblCard_Point_Hidden = Card_Point_Hidden
                        FROM tblCard C(NOLOCK)
                        WHERE Card_SerialNo = @strOldCardNumber;
                        UPDATE tblCard
                          SET 
                              Card_Status = 9
                        WHERE Card_SerialNo = @strOldCardNumber;
						set @CardId=@strOldCardNumber

                        ------ Credit Transfer IN
                        SET @PrefixType = 'Receipt';
                        SET @intItemSign = 1;
                        SET @intCardTransType = 4;
                        IF @dblCard_Balance <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'Payment', 
                                     @PrefixType, 
                                     0, 
                                     @strReceiptNo OUTPUT;
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
                                 CardTrans_OldCardNumber
                                )
                                VALUES
                                (@strReceiptNo, 
                                 @strCardNumber, 
                                 GETDATE(), 
                                 @intCardTransType, 
                                 @dblCard_Balance * @intItemSign, 
                                 @dblCard_Balance, 
                                 @strReceiptNo, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 @intPaymentType, 
                                 @strOldCardNumber
                                );
                            END;
                        SET @intCardTransType = 31;
                        IF @dblCard_Balance_Cashable <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'Payment', 
                                     @PrefixType, 
                                     0, 
                                     @strReceiptNo OUTPUT;
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
                                 CardTrans_OldCardNumber
                                )
                                VALUES
                                (@strReceiptNo, 
                                 @strCardNumber, 
                                 GETDATE(), 
                                 @intCardTransType, 
                                 @dblCard_Balance_Cashable * @intItemSign, 
                                 @dblCard_Balance_Cashable, 
                                 @strReceiptNo, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 @intPaymentType, 
                                 @strOldCardNumber
                                );
                            END;
                        SET @intCardTransType = 33;
                        IF @dblCard_Balance_Cashable_No <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'Payment', 
                                     @PrefixType, 
                                     0, 
                                     @strReceiptNo OUTPUT;
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
                                 CardTrans_OldCardNumber
                                )
                                VALUES
                                (@strReceiptNo, 
                                 @strCardNumber, 
                                 GETDATE(), 
                                 @intCardTransType, 
                                 @dblCard_Balance_Cashable_No * @intItemSign, 
                                 @dblCard_Balance_Cashable_No, 
                                 @strReceiptNo, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 @intPaymentType, 
                                 @strOldCardNumber
                                );
                            END;

                        ----- Credit Transfer out 
                        SET @intItemSign = -1;
                        SET @intCardTransType = 5;
                        IF @dblCard_Balance <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'Payment', 
                                     @PrefixType, 
                                     0, 
                                     @strReceiptNo OUTPUT;
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
                                 CardTrans_OldCardNumber
                                )
                                VALUES
                                (@strReceiptNo, 
                                 @strOldCardNumber, 
                                 GETDATE(), 
                                 @intCardTransType, 
                                 @dblCard_Balance * @intItemSign, 
                                 @dblCard_Balance, 
                                 @strReceiptNo, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 @intPaymentType, 
                                 @strCardNumber
                                );
                            END;
                        SET @intCardTransType = 32;
                        IF @dblCard_Balance_Cashable <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'Payment', 
                                     @PrefixType, 
                                     0, 
                                     @strReceiptNo OUTPUT;
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
                                 CardTrans_OldCardNumber
                                )
                                VALUES
                                (@strReceiptNo, 
                                 @strOldCardNumber, 
                                 GETDATE(), 
                                 @intCardTransType, 
                                 @dblCard_Balance_Cashable * @intItemSign, 
                                 @dblCard_Balance_Cashable, 
                                 @strReceiptNo, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 @intPaymentType, 
                                 @strCardNumber
                                );
                            END;
                        SET @intCardTransType = 34;
                        IF @dblCard_Balance_Cashable_No <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'Payment', 
                                     @PrefixType, 
                                     0, 
                                     @strReceiptNo OUTPUT;
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
                                 CardTrans_OldCardNumber
                                )
                                VALUES
                                (@strReceiptNo, 
                                 @strOldCardNumber, 
                                 GETDATE(), 
                                 @intCardTransType, 
                                 @dblCard_Balance_Cashable_No * @intItemSign, 
                                 @dblCard_Balance_Cashable_No, 
                                 @strReceiptNo, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 @intPaymentType, 
                                 @strCardNumber
                                );
                            END;

                        --- Transfer IN Point
                        SET @intItemSign = 1;
                        --Declare @dblCard_Point money = 0  
                        --Declare @dblCard_PointAccumulate money = 0 
                        --Declare @dblCard_Point_Tier money = 0  
                        --Declare @dblCard_Point_Hidden money = 0 
                        DECLARE @strTransNo NVARCHAR(50)= '';
                        DECLARE @intPointType INT= 0;
                        SET @PrefixType = 'CardTrans';
                        SET @intTransType = 4;
                        SET @intPointType = 0;
                        IF @dblCard_Point <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'CardTrans', 
                                     @PrefixType, 
                                     0, 
                                     @strTransNo OUTPUT;
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
                                 CardPointTrans_Ratio, 
                                 CardPointTrans_BranchID, 
                                 CardPointTrans_ApprovedBy, 
                                 CardPointTrans_ApprovedDate, 
                                 CardPointTrans_PointType, 
                                 CardPointTrans_OldCardNumber
                                )
                                VALUES
                                (@strTransNo, 
                                 @strCardNumber, 
                                 @intTransType, 
                                 @dblCard_Point * @intItemSign, 
                                 @dblCard_Point, 
                                 @intPlayerID, 
                                 '', 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 '', 
                                 0, 
                                 0, 
                                 0, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 @intPointType, 
                                 @strOldCardNumber
                                );
                            END;
                        SET @intPointType = 1;
                        IF @dblCard_Point_Tier <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'CardTrans', 
                                     @PrefixType, 
                                     0, 
                                     @strTransNo OUTPUT;
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
                                 CardPointTrans_Ratio, 
                                 CardPointTrans_BranchID, 
                                 CardPointTrans_ApprovedBy, 
                                 CardPointTrans_ApprovedDate, 
                                 CardPointTrans_PointType, 
                                 CardPointTrans_OldCardNumber
                                )
                                VALUES
                                (@strTransNo, 
                                 @strCardNumber, 
                                 @intTransType, 
                                 @dblCard_Point_Tier * @intItemSign, 
                                 @dblCard_Point_Tier, 
                                 @intPlayerID, 
                                 '', 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 '', 
                                 0, 
                                 0, 
                                 0, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 @intPointType, 
                                 @strOldCardNumber
                                );
                            END;
                        SET @intPointType = 2;
                        IF @dblCard_Point_Hidden <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'CardTrans', 
                                     @PrefixType, 
                                     0, 
                                     @strTransNo OUTPUT;
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
                                 CardPointTrans_Ratio, 
                                 CardPointTrans_BranchID, 
                                 CardPointTrans_ApprovedBy, 
                                 CardPointTrans_ApprovedDate, 
                                 CardPointTrans_PointType, 
                                 CardPointTrans_OldCardNumber
                                )
                                VALUES
                                (@strTransNo, 
                                 @strCardNumber, 
                                 @intTransType, 
                                 @dblCard_Point_Hidden * @intItemSign, 
                                 @dblCard_Point_Hidden, 
                                 @intPlayerID, 
                                 '', 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 '', 
                                 0, 
                                 0, 
                                 0, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 @intPointType, 
                                 @strOldCardNumber
                                );
                            END;
                        SET @intTransType = 5;
                        --- Transfer Out Point
                        SET @intItemSign = -1;
                        SET @intPointType = 0;
                        IF @dblCard_Point <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'CardTrans', 
                                     @PrefixType, 
                                     0, 
                                     @strTransNo OUTPUT;
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
                                 CardPointTrans_Ratio, 
                                 CardPointTrans_BranchID, 
                                 CardPointTrans_ApprovedBy, 
                                 CardPointTrans_ApprovedDate, 
                                 CardPointTrans_PointType, 
                                 CardPointTrans_OldCardNumber
                                )
                                VALUES
                                (@strTransNo, 
                                 @strOldCardNumber, 
                                 @intTransType, 
                                 @dblCard_Point * @intItemSign, 
                                 @dblCard_Point, 
                                 @intPlayerID, 
                                 '', 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 '', 
                                 0, 
                                 0, 
                                 0, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 @intPointType, 
                                 @strCardNumber
                                );
                            END;
                        SET @intPointType = 1;
                        IF @dblCard_Point_Tier <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'CardTrans', 
                                     @PrefixType, 
                                     0, 
                                     @strTransNo OUTPUT;
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
                                 CardPointTrans_Ratio, 
                                 CardPointTrans_BranchID, 
                                 CardPointTrans_ApprovedBy, 
                                 CardPointTrans_ApprovedDate, 
                                 CardPointTrans_PointType, 
                                 CardPointTrans_OldCardNumber
                                )
                                VALUES
                                (@strTransNo, 
                                 @strOldCardNumber, 
                                 @intTransType, 
                                 @dblCard_Point_Tier * @intItemSign, 
                                 @dblCard_Point_Tier, 
                                 @intPlayerID, 
                                 '', 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 '', 
                                 0, 
                                 0, 
                                 0, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 @intPointType, 
                                 @strCardNumber
                                );
                            END;
                        SET @intPointType = 2;
                        IF @dblCard_Point_Hidden <> 0
                            BEGIN
                                EXEC sp_tblPrefixNumber_GetNextRunNumber 
                                     'CardTrans', 
                                     @PrefixType, 
                                     0, 
                                     @strTransNo OUTPUT;
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
                                 CardPointTrans_Ratio, 
                                 CardPointTrans_BranchID, 
                                 CardPointTrans_ApprovedBy, 
                                 CardPointTrans_ApprovedDate, 
                                 CardPointTrans_PointType, 
                                 CardPointTrans_OldCardNumber
                                )
                                VALUES
                                (@strTransNo, 
                                 @strOldCardNumber, 
                                 @intTransType, 
                                 @dblCard_Point_Hidden * @intItemSign, 
                                 @dblCard_Point_Hidden, 
                                 @intPlayerID, 
                                 '', 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 '', 
                                 '', 
                                 0, 
                                 0, 
                                 0, 
                                 @strCreatedBy, 
                                 GETDATE(), 
                                 @intPointType, 
                                 @strCardNumber
                                );
                            END;
                        UPDATE tblCard
                          SET 
                              Card_Balance = @dblCard_Balance, 
                              Card_Point = @dblCard_Point, 
                              Card_Balance_Cashable_No = @dblCard_Balance_Cashable_No, 
                              Card_Balance_Cashable = @dblCard_Balance_Cashable, 
                              Card_PointAccumulate = @dblCard_PointAccumulate, 
                              Card_Point_Tier = @dblCard_Point_Tier, 
                              Card_Point_Hidden = @dblCard_Point_Hidden
                        WHERE Card_ID = @intNewCardID;
						set @CardId=@intNewCardID
                        UPDATE tblCard
                          SET 
                              Card_Balance = 0, 
                              Card_Point = 0, 
                              Card_Balance_Cashable_No = 0, 
                              Card_Balance_Cashable = 0, 
                              Card_PointAccumulate = 0, 
                              Card_Point_Tier = 0, 
                              Card_Point_Hidden = 0
                        WHERE Card_SerialNo = @strOldCardNumber;
						set @CardId=@strOldCardNumber
                        SET @intResultCode = @intID;
                        SET @strResultText = 'Success';
                        SELECT @intResultCode AS RETURN_RESULT, 
                               @strResultText AS RETURN_RESULT_TEXT, 
                               @intID AS intNewID;
                    END;
                    ELSE
                    BEGIN
                        DECLARE @intCardType AS INT= 0;
                        SELECT @intCardType = c.Card_Type
                        FROM tblCard c(NOLOCK)
                        WHERE Card_ID = @intID;
                        DECLARE @dblRPoint MONEY= 0;
                        DECLARE @dblRCredit MONEY= 0;
                        DECLARE @dblRCreditCashable MONEY= 0;
                        DECLARE @dblRCreditCashableNon MONEY= 0;
                        SELECT @dblRPoint = a.Reward_Points, 
                               @dblRCredit = a.Reward_Credit, 
                               @dblRCreditCashable = a.Reward_CreditCashable, 
                               @dblRCreditCashableNon = a.Reward_CreditNonCashable
                        FROM tblCampaign_Reward a(NOLOCK)
                        WHERE GETDATE() >= a.Reward_StartDate
                              AND GETDATE() <= a.Reward_EndDate
                              AND a.Reward_Status = 0
                              AND a.Reward_Type_ID = 1
                              AND a.Reward_CardType = @intCardType;
                        UPDATE tblCard
                          SET 
                              Card_Point = Card_Point + @dblRPoint, 
                              Card_Balance = Card_Balance + @dblRCredit, 
                              Card_Balance_Cashable = Card_Balance_Cashable + @dblRCreditCashable, 
                              Card_Balance_Cashable_No = Card_Balance_Cashable_No + @dblRCreditCashableNon
                        WHERE Card_ID = @intID;
						set @CardId=@intID
                    END;
                SET @intResultCode = @intID;
                SET @strResultText = 'Success';
                SELECT @intResultCode AS RETURN_RESULT, 
                       @strResultText AS RETURN_RESULT_TEXT, 
                       @intID AS intNewID;
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
