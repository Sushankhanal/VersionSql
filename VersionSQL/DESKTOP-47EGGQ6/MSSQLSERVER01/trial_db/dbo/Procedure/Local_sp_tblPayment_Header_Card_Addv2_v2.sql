/****** Object:  Procedure [dbo].[Local_sp_tblPayment_Header_Card_Addv2_v2]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Card_Add 'user001','','COUNTER1','Hallaway01',10,0,0,0,10,'',xml,'','',2,'',6,'','','',0
create PROCEDURE [dbo].[Local_sp_tblPayment_Header_Card_Addv2_v2]
-- POSPayment_Card_LoyatlyV2
--@intID			nvarchar(50) OUT,
@strPOSUserCode             NVARCHAR(50), 
@strClientUserCode          NVARCHAR(50), 
@strCounterCode             NVARCHAR(50), 
@strCompanyCode             NVARCHAR(50), 
@dblGrossAmt                MONEY, 
@dblGlobalDiscountRate      MONEY, 
@dblRoundUp                 MONEY, 
@dblTaxAmt                  MONEY, 
@dblNetAmount               MONEY, 
@strRemarks                 NVARCHAR(MAX), 
@PaymentDetailXml           XML, 
@strCardNumber              NVARCHAR(50), 
@intPaymentType             INT, 
@strPaymentTypeRemarks      NVARCHAR(50), 
@strReceiptNo               NVARCHAR(50) OUT, 
@strClientFullName          NVARCHAR(50) OUT, 
@strClientBalance           MONEY OUT, 
@PaymentDetailAddOnXml      XML, 
@RedeemPoint                DECIMAL(38, 10), 
@RedeemAmt                  MONEY, 
@strClientPoint             DECIMAL(38, 10) OUT, 
@intDiscountMode            SMALLINT, 
@strCollectCode             NVARCHAR(50), 
@dblCollectedAmt            MONEY, 
@dblGlobalDiscountAmt       MONEY, 
@strTableCode               NVARCHAR(50), 
@strOrderNumber             NVARCHAR(50), 
@PaymentDetailModeXml       XML             = '', 
@intPax                     INT             = 0, 
@intSyncLocalID             NVARCHAR(100)   = 0, 
@dblClientBalanceCashableNo MONEY OUT, 
@dblClientBalanceCashable   MONEY OUT, 
@dblClientPointAccumulate   DECIMAL(38, 10) OUT, 
@dblClientPointTier         DECIMAL(38, 10) OUT, 
@dblClientPointHidden       DECIMAL(38, 10) OUT,
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
        DECLARE @dblCompanySST MONEY= 0;
        DECLARE @dblCompanySC MONEY= 0;
        SELECT @dblCompanySST = Company_SST, 
               @dblCompanySC = Company_SC
        FROM tblCompany
        WHERE Company_Code = @strCompanyCode;
        IF @dblCompanySST = 0
           AND @dblCompanySC = 0
            BEGIN
                SELECT @dblCompanySST = Counter_SST, 
                       @dblCompanySC = Counter_SC
                FROM tblCounter
                WHERE Counter_Code = @strCounterCode
                      AND Counter_CompanyCode = @strCompanyCode;
            END;
        SET @dblCompanySST = (@dblCompanySST / 100);
        SET @dblCompanySC = (@dblCompanySC / 100);
        IF @strOrderNumber = '0'
            BEGIN
                SET @strOrderNumber = '';
            END;

        --Declare @dblTaxAmount_Order money = 0
        --if @strOrderNumber <> ''
        --	BEGIN
        --		select @dblTaxAmt = Payment_TotalTaxAmt, @dblNetAmount = Payment_NetAmt from tblPayment_Order where Payment_ReceiptNo = @strOrderNumber
        --		--Update tblPayment_Order set Payment_Status = 1 where Payment_ReceiptNo = @strOrderNumber
        --	END

        SET @strReceiptNo = '';
        SET @strClientFullName = '';
        SET @strClientBalance = 0;
        SET @strClientPoint = 0;
        SET @dblClientBalanceCashableNo = 0;
        SET @dblClientBalanceCashable = 0;
        SET @dblClientPointAccumulate = 0;
        SET @dblClientPointTier = 0;
        SET @dblClientPointHidden = 0;
        DECLARE @intCount_Card INT;
        DECLARE @strMobileUser NVARCHAR(50);
        SELECT @intCount_Card = COUNT(Card_ID)
        FROM tblCard
        WHERE Card_SerialNo = @strCardNumber
              AND Card_Status = 0;
        SET @strMobileUser = '';
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
               @strClientBalance = Card_Balance
        FROM tblCard
        WHERE Card_SerialNo = @strCardNumber;
        SET @strClientFullName = @strCardNumber;

        ---------- Added by ricky, check local trans valid or not
        IF @intSyncLocalID <> 0
            BEGIN
                IF
                (
                    SELECT COUNT(Payment_ID)
                    FROM tblPayment_Header H(NOLOCK)
                    WHERE H.Payment_SyncLocalID = @intSyncLocalID
                ) <> 0
                    BEGIN
                        SELECT @strReceiptNo = Payment_ReceiptNo
                        FROM tblPayment_Header H(NOLOCK)
                        WHERE H.Payment_SyncLocalID = @intSyncLocalID;
                        SELECT @strClientBalance = Card_Balance, 
                               @strClientPoint = Card_Point, 
                               @dblClientBalanceCashableNo = Card_Balance_Cashable_No, 
                               @dblClientBalanceCashable = Card_Balance_Cashable, 
                               @dblClientPointAccumulate = Card_PointAccumulate, 
                               @dblClientPointTier = Card_Point_Tier, 
                               @dblClientPointHidden = Card_Point_Hidden
                        FROM tblCard
                        WHERE Card_SerialNo = @strCardNumber;
                        COMMIT TRANSACTION;
                        SET NOCOUNT OFF;
                        RETURN(0);
                    END;
            END;
        DECLARE @intWalletTransType INT;
        DECLARE @objXml XML, @intDoc INT;
        SELECT @objXml = @PaymentDetailXml;
        --print convert(nvarchar(max),@objXml)
        EXEC sp_xml_preparedocument 
             @intDoc OUTPUT, 
             @objXml;
        --print @intDoc

        DECLARE @tblTemp TABLE
        (ID                     INT, 
         itemCode               NVARCHAR(50), 
         UOM                    NVARCHAR(50), 
         UnitPrice              MONEY, 
         Qty                    INT, 
         ItemDiscountAmt        MONEY, 
         ItemDiscountPercentage FLOAT, 
         ItemTaxCode            NVARCHAR(50), 
         ItemTaxRate            MONEY, 
         ItemTaxAmt             MONEY, 
         NetAmount              MONEY, 
         DiscountMode           INT, 
         UnitCost               MONEY, 
         ItemSign               SMALLINT, 
         WalletTransType        INT, 
         ISPROCCESS             INT
        );
        INSERT INTO @tblTemp
        (ID, 
         itemCode, 
         UOM, 
         UnitPrice, 
         Qty, 
         ItemDiscountAmt, 
         ItemDiscountPercentage, 
         ItemTaxCode, 
         ItemTaxRate, 
         ItemTaxAmt, 
         NetAmount, 
         DiscountMode, 
         UnitCost, 
         ItemSign, 
         WalletTransType, 
         ISPROCCESS
        )
               SELECT DetailID, 
                      itemCode, 
                      UOM, 
                      UnitPrice, 
                      Qty, 
                      ItemDiscountAmt, 
                      ItemDiscountPercentage, 
                      ItemTaxCode, 
                      ItemTaxRate, 
                      ItemTaxAmt, 
                      NetAmount, 
                      DiscountMode, 
                      0, 
                      0, 
                      0, 
                      0
               FROM OPENXML(@intDoc, N'/NewDataSet/Table1', 2) WITH(DetailID INT, itemCode NVARCHAR(50), UOM NVARCHAR(50), UnitPrice MONEY, Qty INT, ItemDiscountAmt MONEY, ItemDiscountPercentage FLOAT, ItemTaxCode NVARCHAR(50), ItemTaxRate MONEY, ItemTaxAmt MONEY, NetAmount MONEY, DiscountMode INT);
        UPDATE @tblTemp
          SET 
              ItemSign = WT.WTransType_Sign, 
              WalletTransType = P.Product_WalletsTransType
        FROM @tblTemp t
             INNER JOIN tblProduct P ON t.itemCode = P.Product_ItemCode
             INNER JOIN tblWalletTransType WT ON P.Product_WalletsTransType = WT.WTransType_ID;
        SELECT @@ROWCOUNT
        FROM @tblTemp
        WHERE ItemSign <> 0
        GROUP BY ItemSign;
        DECLARE @intCount_Mix INT;
        DECLARE @intItemSign INT;
        SELECT @intCount_Mix = @@ROWCOUNT
        FROM @tblTemp
        WHERE ItemSign <> 0
        GROUP BY ItemSign;
        --print @intCount_Mix
        IF @intCount_Mix > 1
            BEGIN
                ROLLBACK TRANSACTION;
                SET NOCOUNT OFF;
                RETURN(-8);
            END;
            ELSE
            BEGIN
                SELECT @intItemSign = ItemSign, 
                       @intWalletTransType = WalletTransType
                FROM @tblTemp
                WHERE ItemSign <> 0
                GROUP BY ItemSign, 
                         WalletTransType;
            END;
        IF
        (
            SELECT COUNT(ID)
            FROM @tblTemp
        ) = 0
            BEGIN
                ROLLBACK TRANSACTION;
                SET NOCOUNT OFF;
                RETURN(-8);
            END;

        --- Added by Hong
        DECLARE @dblTotalNet_Detail MONEY= 0;
        SELECT @dblTotalNet_Detail = SUM(NetAmount)
        FROM @tblTemp;
        DECLARE @objXml_Addon2 XML, @intDoc_Addon2 INT;
        SELECT @objXml_Addon2 = @PaymentDetailaddonXml;
        EXEC sp_xml_preparedocument 
             @intDoc_Addon2 OUTPUT, 
             @objXml_Addon2;
        DECLARE @tblExtraSUM TABLE
        (DetailID BIGINT, 
         ExtraSum MONEY
        );
        INSERT INTO @tblExtraSUM
        (DetailID, 
         ExtraSum
        )
               SELECT detailid, 
                      AddOnPrice
               FROM OPENXML(@intDoc_Addon2, N'/NewDataSet/Table1', 2) WITH(DetailID INT, AddOnPrice MONEY);
        DECLARE @dblTotalNet_Extra MONEY= 0;
        SELECT @dblTotalNet_Extra = SUM(ExtraSum)
        FROM @tblExtraSUM;
        SET @dblTotalNet_Detail = @dblTotalNet_Detail + @dblTotalNet_Extra;
        IF @dblTotalNet_Detail <> @dblGrossAmt
            BEGIN
                ROLLBACK TRANSACTION;
                SET NOCOUNT OFF;
                RETURN(-8);
            END;
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

        -- get point
        DECLARE @dblDefaultPointRate MONEY;
        SELECT @dblDefaultPointRate = WTransType_DefaultPointRate
        FROM tblWalletTransType
        WHERE WTransType_ID = @intWalletTransType;
        DECLARE @dblTotalPointEarn DECIMAL(38, 10)= 0;
        SET @dblTotalPointEarn = @dblNetAmount * @dblDefaultPointRate;
        DECLARE @intRedeemType INT;
        DECLARE @strClientPointRedeemRate MONEY;
        SET @intRedeemType = 11;
        SET @strClientPointRedeemRate = 0;
        SELECT @strClientPointRedeemRate = WTransType_DefaultPointRate
        FROM tblWalletTransType
        WHERE WTransType_Name = 'Redeem';
        DECLARE @dblCardTransAmt MONEY;
        SET @dblCardTransAmt = @dblNetAmount;
        IF @intItemSign = -1 -- Minus Case
            BEGIN
                IF @dblCardBalance < @dblCardTransAmt
                    BEGIN
                        ROLLBACK TRANSACTION;
                        SET NOCOUNT OFF;
                        RETURN(-1);
                    END;
            END;
        IF @intItemSign = 1 -- Top Up Case
            BEGIN
                SELECT @dblCardTransAmt = SUM(NetAmount)
                FROM @tblTemp
                WHERE ItemSign <> 0; 
                --if @dblCardBalance < @dblCardTransAmt
                --BEGIN
                --	COMMIT TRANSACTION
                --	SET NOCOUNT OFF
                --	RETURN (-1)
                --END
            END;

        --Declare @strCardTrans nvarchar(50)
        --set @strCardTrans = ''
        --set @PrefixType = 'CardTrans'
        --EXEC sp_tblPrefixNumber_GetNextRunNumber 'CardTrans', @PrefixType, 0, @strCardTrans OUTPUT

        SELECT @intialAmount = Card_Balance, 
               @finalAmount = Card_Balance + (@dblCardTransAmt * @intItemSign)
        FROM tblCard
        WHERE Card_SerialNo = @strCardNumber;
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

        -- Calc point

        IF @dblDefaultPointRate <> 0
            BEGIN
                IF @dblTotalPointEarn <> 0
                    BEGIN
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
                         CardPointTrans_MachineID
                        )
                        VALUES
                        (@strReceiptNo + '-2', 
                         @strCardNumber, 
                         @intWalletTransType, 
                         @dblTotalPointEarn, 
                         @dblTotalPointEarn, 
                         @strReceiptNo, 
                         @strRemarks, 
                         @strPOSUserCode, 
                         @transDate, 
                         '', 
                         @strCardNumber, 
                         0, 
                         @dblDefaultPointRate, 
                         0, 
                         0
                        );
                        IF @dblTotalPointEarn > 0
                            BEGIN
                                UPDATE tblCard
                                  SET 
                                      Card_Point = Card_Point + @dblTotalPointEarn, 
                                      Card_PointAccumulate = Card_PointAccumulate + @dblTotalPointEarn
                                WHERE Card_SerialNo = @strCardNumber;
								set @CardId=@strCardNumber;
                            END;
                    END;
            END;

        --- Calc Point
        --Redeem Card Point
        IF @RedeemPoint <> 0
            BEGIN
                DECLARE @dblCardPoint DECIMAL(38, 10)= 0;
                SELECT @dblCardPoint = Card_Point
                FROM tblCard
                WHERE Card_SerialNo = @strCardNumber;
                IF @RedeemPoint > @dblCardPoint
                    BEGIN
                        ROLLBACK TRANSACTION;
                        SET NOCOUNT OFF;
                        RETURN(-999);
                    END;
                    ELSE
                    BEGIN
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
                        (@strReceiptNo + '-3', 
                         @strCardNumber, 
                         @intRedeemType, 
                         @RedeemPoint * -1, 
                         @RedeemPoint, 
                         @strReceiptNo, 
                         @strRemarks, 
                         @strPOSUserCode, 
                         @transDate, 
                         '', 
                         @strCardNumber, 
                         @RedeemAmt, 
                         @strClientPointRedeemRate
                        );
                        UPDATE tblCard
                          SET 
                              Card_Point = Card_Point + (@RedeemPoint * -1) --check
                        WHERE Card_SerialNo = @strCardNumber;
						set @CardId=@strCardNumber;
                    END;
            END;

        -- Customize by ricky, 2020-04-16
        IF(@intWalletTransType = 16
           OR @intWalletTransType = 18
           OR @intWalletTransType = 20)
            BEGIN
                IF
                (
                    SELECT Card_Balance_Cashable_No
                    FROM tblCard
                    WHERE Card_SerialNo = @strCardNumber
                ) < @dblCardTransAmt
                    BEGIN
                        ROLLBACK TRANSACTION;
                        SET NOCOUNT OFF;
                        RETURN(-657);
                    END;
                UPDATE tblCard
                  SET 
                      Card_Balance_Cashable_No = Card_Balance_Cashable_No + (@dblCardTransAmt * @intItemSign), 
                      Card_Point = Card_Point + @dblTotalPointEarn
                WHERE Card_SerialNo = @strCardNumber;
				set @CardId=@strCardNumber;
            END;
            ELSE
            IF(@intWalletTransType = 17
               OR @intWalletTransType = 19
               OR @intWalletTransType = 21)
                BEGIN
                    IF
                    (
                        SELECT Card_Balance_Cashable
                        FROM tblCard
                        WHERE Card_SerialNo = @strCardNumber
                    ) < @dblCardTransAmt
                        BEGIN
                            ROLLBACK TRANSACTION;
                            SET NOCOUNT OFF;
                            RETURN(-656);
                        END;
                    UPDATE tblCard
                      SET 
                          Card_Balance_Cashable = Card_Balance_Cashable + (@dblCardTransAmt * @intItemSign), 
                          Card_Point = Card_Point + @dblTotalPointEarn
                    WHERE Card_SerialNo = @strCardNumber;
					set @CardId=@strCardNumber
                END;
                ELSE
                BEGIN
                    UPDATE tblCard
                      SET 
                          Card_Balance = Card_Balance + (@dblCardTransAmt * @intItemSign), 
                          Card_Point = Card_Point + @dblTotalPointEarn, 
                          Card_balance_Edit_DateTime = @transDate
                    WHERE Card_SerialNo = @strCardNumber;
					set @CardId=@strCardNumber
                END;

        --Update tblCard set Card_Balance = Card_Balance + (@dblCardTransAmt * @intItemSign),
        --Card_Point = Card_Point + @dblTotalPointEarn
        --where Card_SerialNo = @strCardNumber

        SELECT @strClientBalance = Card_Balance, 
               @strClientPoint = Card_Point
        FROM tblCard
        WHERE Card_SerialNo = @strCardNumber;
        SET @strClientUserCode = @strCardNumber;
        DECLARE @dblReturnAmt MONEY= 0;
        SET @dblReturnAmt = @dblNetAmount - @dblCollectedAmt;

        --- Add wallet trans
        DECLARE @strWalletCode NVARCHAR(50);
        SET @strClientUserCode = '';
        SET @strClientBalance = 0;
        SELECT @strClientUserCode = mUser_Code, 
               @strClientFullName = mUser_FullName, 
               @strClientBalance = mUser_TotalBalance
        FROM tblUserMobile
        WHERE mUser_Code = @strMobileUser;
        SELECT @strWalletCode = UWallet_Code
        FROM tblUserWallet
        WHERE UWallet_UserCode = @strClientUserCode;
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
         @dblNetAmount * @intItemSign, 
         @dblNetAmount, 
         @strReceiptNo, 
         @strRemarks, 
         @strPOSUserCode, 
         @transDate, 
         '', 
         @intPaymentType, 
         @strCardNumber
        );
        SELECT @strClientFullName = mUser_FullName, 
               @strClientBalance = mUser_TotalBalance, 
               @strClientPoint = mUser_TotalPoint
        FROM tblUserMobile
        WHERE mUser_Code = @strClientUserCode;
        SET @strClientUserCode = @strCardNumber;
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
         Payment_DiscountMode, 
         Payment_RedeemPoint, 
         Payment_RedeemAmt, 
         Payment_CollectionCode, 
         Payment_TableCode, 
         Payment_OrderNumber, 
         Payment_pax, 
         Payment_SyncLocalID
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
         @dblCollectedAmt, 
         @dblReturnAmt, 
         0, 
         @transDate, 
         @strPaymentTypeRemarks, 
         0, 
         '', 
         @strClientUserCode, 
         @dblGlobalDiscountRate, 
         @dblGlobalDiscountAmt, 
         0, 
         0, 
         @dblTaxAmt, 
         @strPOSUserCode, 
         @strRemarks, 
         @intDiscountMode, 
         @RedeemPoint, 
         @RedeemAmt, 
         @strCollectCode, 
         @strTableCode, 
         @strOrderNumber, 
         @intPax, 
         @intSyncLocalID
        );
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
         PaymentD_RunNo, 
         PaymentD_DiscountMode
        )
               SELECT @strReceiptNo, 
                      itemCode, 
                      UOM, 
                      UnitPrice, 
                      ItemDiscountPercentage, 
                      ItemDiscountAmt, 
                      NetAmount, 
                      @transDate, 
                      Qty, 
                      @transDate, 
                      UnitCost, 
                      ItemTaxCode, 
                      ItemTaxRate, 
                      ItemTaxAmt, 
                      ID, 
                      DiscountMode
               FROM @tblTemp;
        --select @@IDENTITY
        -- Added By Ricky -- 15/11/2019
        UPDATE tblPayment_Details
          SET 
              PaymentD_ItemName = (CASE d.PaymentD_UOM
                                       WHEN 'half'
                                       THEN P.Product_Desc2
                                       ELSE P.Product_Desc
                                   END), 
              PaymentD_ItemNameChi = (CASE d.PaymentD_UOM
                                          WHEN 'half'
                                          THEN P.Product_ChiDesc2
                                          ELSE P.Product_ChiDesc
                                      END), 
              PaymentD_PrinterName = P.Product_PrinterName
        FROM tblPayment_Details d
             INNER JOIN tblProduct P ON d.PaymentD_ItemCode = P.Product_ItemCode
        WHERE PaymentD_ReceiptNo = @strReceiptNo;

        --Insert Addon Data
        --- Add in Extra add on
        DECLARE @objXml_Addon XML, @intDoc_Addon INT;
        SELECT @objXml_Addon = @PaymentDetailaddonXml;
        EXEC sp_xml_preparedocument 
             @intDoc_Addon OUTPUT, 
             @objXml_Addon;
        INSERT INTO tblPayment_Extra
        (PaymentEx_ReceiptNo, 
         PaymentEx_RunNo, 
         PaymentEx_ItemCode, 
         PaymentEx_ItemDesc, 
         PaymentEx_AddOnPrice, 
         PaymentEx_CreatedBy, 
         PaymentEx_CreatedDate
        )
               SELECT @strReceiptNo, 
                      detailid, 
                      AddOnCode, 
                      AddOnDesc, 
                      AddOnPrice, 
                      @strPOSUserCode, 
                      @transDate
               FROM OPENXML(@intDoc_Addon, N'/NewDataSet/Table1', 2) WITH(DetailID INT, AddOnCode NVARCHAR(50), AddOnDesc NVARCHAR(50), AddOnPrice MONEY);
        IF @strOrderNumber <> ''
            BEGIN
                UPDATE tblPayment_Order
                  SET 
                      Payment_Status = 1
                WHERE Payment_ReceiptNo = @strOrderNumber;
            END;
        DECLARE @dblItemTax AS MONEY= 0;
        DECLARE @dblItemTotalAmt AS MONEY= 0;
        IF @dblCompanySC <> 0
            BEGIN
                DECLARE @dblFinalSetAmt MONEY= 0;
                DECLARE @dblFinalRoundUpAmt MONEY= 0;
                DECLARE @dblFinalSSTAmt MONEY= 0;
                DECLARE @dblFinalSCAmt MONEY= 0;
                SELECT @dblFinalSetAmt = (Payment_GrossAmt - Payment_DiscountAmt - Payment_GlobalDiscountAmt), 
                       @dblFinalSSTAmt = Payment_TotalTaxAmt
                FROM tblPayment_Header
                WHERE Payment_ReceiptNo = @strReceiptNo;

                --set @dblFinalSSTAmt = ROUND(@dblFinalSetAmt * @dblCompanySST,2)
                SET @dblFinalSCAmt = ROUND(@dblFinalSetAmt * @dblCompanySC, 2);
                UPDATE tblPayment_Header
                  SET 
                --Payment_SST = @dblFinalSSTAmt, 
                      Payment_SC = @dblFinalSCAmt
                --Payment_TotalTaxAmt = @dblFinalSSTAmt
                WHERE Payment_ReceiptNo = @strReceiptNo;
                SET @dblFinalSetAmt = @dblFinalSetAmt + (@dblFinalSCAmt) + @dblFinalSSTAmt;
                SELECT @dblFinalRoundUpAmt = dbo.fnGetRoundUp(@dblFinalSetAmt);
                UPDATE tblPayment_Header
                  SET 
                      Payment_RoundUp = @dblFinalRoundUpAmt
                WHERE Payment_ReceiptNo = @strReceiptNo;
                SET @dblFinalSetAmt = @dblFinalSetAmt + @dblFinalRoundUpAmt;
                UPDATE tblPayment_Header
                  SET 
                      Payment_FinalAmt = @dblFinalSetAmt, 
                      Payment_CompanyCode = @strCompanyCode
                WHERE Payment_ReceiptNo = @strReceiptNo;
            END;
        UPDATE tblPayment_Header
          SET 
              Payment_CompanyCode = @strCompanyCode
        WHERE Payment_ReceiptNo = @strReceiptNo;
        UPDATE tblPayment_Header
          SET 
              Payment_SST = Payment_TotalTaxAmt
        WHERE Payment_ReceiptNo = @strReceiptNo;
        UPDATE tblTable
          SET 
              Table_Status = 0, 
              Table_isCalling = 0
        WHERE Table_Code = @strTableCode
              AND Table_CompanyCode = @strCompanyCode;
        SET @dblClientBalanceCashableNo = 0;
        SET @dblClientBalanceCashable = 0;
        SET @dblClientPointAccumulate = 0;
        SET @dblClientPointTier = 0;
        SET @dblClientPointHidden = 0;
        SELECT @strClientBalance = Card_Balance, 
               @strClientPoint = Card_Point, 
               @dblClientBalanceCashableNo = Card_Balance_Cashable_No, 
               @dblClientBalanceCashable = Card_Balance_Cashable, 
               @dblClientPointAccumulate = Card_PointAccumulate, 
               @dblClientPointTier = Card_Point_Tier, 
               @dblClientPointHidden = Card_Point_Hidden
        FROM tblCard
        WHERE Card_SerialNo = @strCardNumber;
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
