/****** Object:  Procedure [dbo].[Local_sp_tblPayment_Header_Add_Multiplay]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_tblPayment_Header_Add_Multiplay 'user001','','COUNTER-01','Hallaway01',10,0,0,0,10,'',xml,'','',2,'xml',0,0,0,0,'',0,0,'','',xml
--,'','',0
create PROCEDURE [dbo].[Local_sp_tblPayment_Header_Add_Multiplay]
-- Add the parameters for the stored procedure here
--@intID			nvarchar(50) OUT,
@strPOSUserCode        NVARCHAR(50), 
@strClientUserCode     NVARCHAR(50), 
@strCounterCode        NVARCHAR(50), 
@strCompanyCode        NVARCHAR(50), 
@dblGrossAmt           MONEY, 
@dblGlobalDiscountRate MONEY, 
@dblRoundUp            MONEY, 
@dblTaxAmt             MONEY, 
@dblNetAmount          MONEY, 
@strRemarks            NVARCHAR(MAX), 
@PaymentDetailXml      XML, 
@strReceiptNo          NVARCHAR(50) OUT, 
@strClientFullName     NVARCHAR(50) OUT, 
@strClientBalance      MONEY OUT, 
@PaymentDetailAddOnXml XML, 
@RedeemPoint           DECIMAL(38, 10), 
@RedeemAmt             MONEY, 
@strClientPoint        DECIMAL(38, 10) OUT, 
@intDiscountMode       SMALLINT, 
@strCollectCode        NVARCHAR(50), 
@dblCollectedAmt       MONEY, 
@dblGlobalDiscountAmt  MONEY, 
@strTableCode          NVARCHAR(50), 
@strOrderNumber        NVARCHAR(50), 
@PaymentDetailModeXml  XML             = '', 
@intPax                INT             = 0,
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
        ----------------- Check Card Payment Available
        DECLARE @tblTemp_PaymentMode TABLE
        (PaymentMode       NVARCHAR(50), 
         PaymentAmt        MONEY, 
         PaymentRemarks    NVARCHAR(200), 
         DetailID          INT, 
         PaymentCollect    MONEY, 
         PaymentChange     MONEY, 
         PaymentCardNumber NVARCHAR(50), 
         ISPROCCESS        INT
        );
        IF CONVERT(NVARCHAR(MAX), @PaymentDetailModeXml) <> ''
            BEGIN
                DECLARE @objXml_PayMode XML, @intDoc_PayMode INT;
                SELECT @objXml_PayMode = @PaymentDetailModeXml;
                --print convert(nvarchar(max),@objXml)
                EXEC sp_xml_preparedocument 
                     @intDoc_PayMode OUTPUT, 
                     @objXml_PayMode;
                --print @intDoc

                INSERT INTO @tblTemp_PaymentMode
                (PaymentMode, 
                 PaymentAmt, 
                 PaymentRemarks, 
                 DetailID, 
                 PaymentCollect, 
                 PaymentChange, 
                 PaymentCardNumber, 
                 ISPROCCESS
                )
                       SELECT PaymentMode, 
                              PaymentAmt, 
                              PaymentRemarks, 
                              DetailID, 
                              PaymentCollect, 
                              PaymentChange, 
                              PaymentCardNumber, 
                              0
                       FROM OPENXML(@intDoc_PayMode, N'/NewDataSet/Table1', 2) WITH(PaymentMode NVARCHAR(50), PaymentAmt MONEY, PaymentRemarks NVARCHAR(200), DetailID INT, PaymentCollect MONEY, PaymentChange MONEY, PaymentCardNumber NVARCHAR(50));
            END;
        DECLARE @intMemberCardPaymentMode INT= 10;
        DECLARE @strMemberCardNumber NVARCHAR(50)= '';
        SELECT TOP 1 @strMemberCardNumber = PaymentCardNumber
        FROM @tblTemp_PaymentMode
        WHERE PaymentMode = @intMemberCardPaymentMode;

        --------------------------------------

        SET @strReceiptNo = '';
        SET @strClientFullName = '';
        SET @strClientBalance = 0;
        SET @strClientPoint = 0;
        DECLARE @intCount_Card INT;
        DECLARE @strMobileUser NVARCHAR(50)= '';
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
        PRINT @intCount_Mix;
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

        --print @intItemSign
        --print @intWalletTransType
        --select * from @tblTemp
        --return 0

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

        -------------------------------------- Check if got card payment
        IF @strMemberCardNumber <> ''
            BEGIN
                SELECT @intCount_Card = COUNT(Card_ID)
                FROM tblCard
                WHERE Card_SerialNo = @strMemberCardNumber;
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
                        WHERE Card_SerialNo = @strMemberCardNumber;
                    END;
                DECLARE @dblCardBalance MONEY= 0;
                SELECT @dblCardBalance = Card_Balance, 
                       @strClientBalance = Card_Balance, 
                       @intialAmount = Card_Balance
                FROM tblCard
                WHERE Card_SerialNo = @strMemberCardNumber;
                SET @strClientFullName = @strMemberCardNumber;
                DECLARE @dblCardTransAmt MONEY= 0;
                SELECT TOP 1 @dblCardTransAmt = PaymentAmt
                FROM @tblTemp_PaymentMode
                WHERE PaymentMode = 10;
                --set @dblCardTransAmt = @dblNetAmount
                PRINT @dblCardTransAmt;
                IF @intItemSign = -1 -- Minus Case
                    BEGIN
                        IF @dblCardBalance < @dblCardTransAmt
                            BEGIN
                                ROLLBACK TRANSACTION;
                                SET NOCOUNT OFF;
                                RETURN(-1);
                            END;
                    END;

                --if @intItemSign = 1 -- Top Up Case
                --BEGIN
                --	select @dblCardTransAmt = SUM(NetAmount) from @tblTemp where ItemSign <> 0 
                --	--if @dblCardBalance < @dblCardTransAmt
                --	--BEGIN
                --	--	COMMIT TRANSACTION
                --	--	SET NOCOUNT OFF
                --	--	RETURN (-1)
                --	--END
                --END

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
                @strMemberCardNumber, 
                GETDATE(), 
                @intWalletTransType, 
                @dblCardTransAmt * @intItemSign, 
                @dblCardTransAmt, 
                @strReceiptNo, 
                @strMemberCardNumber, 
                GETDATE(), 
                '', 
                @intMemberCardPaymentMode, 
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
                                 CardPointTrans_LocalTransID, 
                                 CardPointTrans_BranchID, 
                                 CardPointTrans_MachineID
                                )
                                VALUES
                                (@strReceiptNo, 
                                 @strMemberCardNumber, 
                                 @intWalletTransType, 
                                 @dblTotalPointEarn, 
                                 @dblTotalPointEarn, 
                                 @strReceiptNo, 
                                 @strRemarks, 
                                 @strPOSUserCode, 
                                 GETDATE(), 
                                 '', 
                                 @strMemberCardNumber, 
                                 0, 
                                 @dblDefaultPointRate, 
                                 0, 
                                 0, 
                                 0
                                );
                            END;
                    END;

                --	--- Calc Point
                ----Redeem Card Point
                --if @RedeemPoint <> 0
                --BEGIN
                --	Declare @dblCardPoint money = 0
                --	select @dblCardPoint = Card_Point from tblCard
                --	where Card_SerialNo = @strMemberCardNumber
                --	if @RedeemPoint > @dblCardPoint
                --	BEGIN
                --		ROLLBACK TRANSACTION
                --		SET NOCOUNT OFF
                --		RETURN (-9)
                --	END
                --	ELSE
                --	BEGIN
                --		INSERT INTO tblCardPointTrans
                --		(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, CardPointTrans_PointValue, 
                --		CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, CardPointTrans_CreatedDate, 
                --		CardPointTrans_CampaignCode, 
                --		CardPointTrans_QRCodeText, CardPointTrans_WalletAmt, CardPointTrans_Ratio)
                --		VALUES (
                --		@strReceiptNo,@strCardNumber,@intRedeemType,@RedeemPoint * -1,@RedeemPoint,
                --		@strReceiptNo,@strRemarks,@strPOSUserCode,GETDATE(),'',
                --		@strCardNumber,@RedeemAmt,@strClientPointRedeemRate)
                --		Update tblCard set Card_Point = Card_Point + (@RedeemPoint * -1)
                --		where Card_SerialNo = @strCardNumber
                --	END
                --END
                UPDATE tblCard
                  SET 
                      Card_Balance = Card_Balance + (@dblCardTransAmt * @intItemSign), 
                      Card_Point = Card_Point + @dblTotalPointEarn, 
                      Card_balance_Edit_DateTime = @transDate
                WHERE Card_SerialNo = @strMemberCardNumber;
                SELECT @strClientBalance = Card_Balance, 
                       @strClientPoint = Card_Point
                FROM tblCard
                WHERE Card_SerialNo = @strMemberCardNumber;
                SET @strClientUserCode = @strMemberCardNumber;
				set @CardId=@strMemberCardNumber
            END;
        DECLARE @dblReturnAmt MONEY= 0;
        SET @dblReturnAmt = @dblNetAmount - @dblCollectedAmt;
        DECLARE @intPaymentType_New INT= 0;
        DECLARE @strPaymentTypeRemarks_New NVARCHAR(50)= '';
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
         Payment_Pax
        )
        VALUES
        (@strReceiptNo, 
         GETDATE(), 
         @dblGrossAmt, 
         0, 
         @dblNetAmount, 
         @dblRoundUp, 
         @dblNetAmount, 
         @strCounterCode, 
         @intPaymentType_New, 
         @dblCollectedAmt, 
         @dblReturnAmt, 
         0, 
         GETDATE(), 
         @strPaymentTypeRemarks_New, 
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
         @intPax
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
                      GETDATE(), 
                      Qty, 
                      GETDATE(), 
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
                      GETDATE()
               FROM OPENXML(@intDoc_Addon, N'/NewDataSet/Table1', 2) WITH(DetailID INT, AddOnCode NVARCHAR(50), AddOnDesc NVARCHAR(50), AddOnPrice MONEY);
        IF @strOrderNumber <> ''
            BEGIN
                --Delete from tblPayment_Order where Payment_ReceiptNo = @strOrderNumber
                --Delete from tblPayment_Details where PaymentD_ReceiptNo = @strOrderNumber
                --Delete from tblPayment_Extra where PaymentEx_ReceiptNo = @strOrderNumber
                UPDATE tblPayment_Order
                  SET 
                      Payment_Status = 1
                WHERE Payment_ReceiptNo = @strOrderNumber;
            END;

        --- Cal Service charges
        -- select SUM((PaymentD_UnitPrice * PaymentD_Qty) - Payment_DiscountAmt) from tblPayment_Header h
        --inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo where Payment_ReceiptNo = 'C16-00121126'
        --AND PaymentD_TaxRate <> 0
        --Group by PaymentD_TaxRate

        DECLARE @dblItemTax AS MONEY= 0;
        DECLARE @dblItemTotalAmt AS MONEY= 0;
        --select @dblItemTax = PaymentD_TaxRate from tblPayment_Header h
        --inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo where Payment_ReceiptNo = @strReceiptNo
        --AND PaymentD_TaxRate <> 0
        --Group by PaymentD_TaxRate
        --select @dblItemTotalAmt = SUM((PaymentD_UnitPrice * PaymentD_Qty) - Payment_DiscountAmt), 
        --@dblItemTax = PaymentD_TaxRate 
        --from tblPayment_Header h
        --inner join tblPayment_Details d on h.Payment_ReceiptNo = d.PaymentD_ReceiptNo where Payment_ReceiptNo = @strReceiptNo
        --AND PaymentD_TaxRate <> 0
        --Group by PaymentD_TaxRate
        --if @dblItemTax <> 0
        --BEGIN
        --	Declare @dblTotalTax as money = 0
        --	Declare @dblFinalSetAmt2 money = 0
        --	Declare @dblFinalRoundUpAmt2 money = 0
        --	set @dblItemTotalAmt = @dblItemTotalAmt - @dblGlobalDiscountAmt
        --	set @dblTotalTax =ROUND( @dblItemTotalAmt * (@dblItemTax/100),2)
        --	Update tblPayment_Header set 
        --	Payment_TotalTaxAmt = @dblTotalTax, Payment_FinalAmt = Payment_GrossAmt - @dblGlobalDiscountAmt + @dblTotalTax,
        --	Payment_NetAmt = Payment_GrossAmt -@dblGlobalDiscountAmt+ @dblTotalTax
        --	where Payment_ReceiptNo = @strReceiptNo
        --	select @dblFinalSetAmt2 = Payment_FinalAmt from  tblPayment_Header where Payment_ReceiptNo = @strReceiptNo
        --	select @dblFinalRoundUpAmt2 = dbo.fnGetRoundUp(@dblFinalSetAmt2)
        --	update tblPayment_Header set  Payment_RoundUp = @dblFinalRoundUpAmt2 where Payment_ReceiptNo = @strReceiptNo
        --END

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

        ------------- ADD Payment mode dataset
        IF CONVERT(NVARCHAR(MAX), @PaymentDetailModeXml) <> ''
            BEGIN
                --DECLARE @objXml_PayMode XML, @intDoc_PayMode INT
                --SELECT @objXml_PayMode = @PaymentDetailModeXml
                ----print convert(nvarchar(max),@objXml)
                --EXEC sp_xml_preparedocument @intDoc_PayMode OUTPUT, @objXml_PayMode
                ----print @intDoc

                INSERT INTO tblPayment_Multi
                (PaymentM_ReceiptNo, 
                 PaymentM_Type, 
                 PaymentM_Amt, 
                 PaymentM_Remarks, 
                 PaymentM_CreatedBy, 
                 PaymentM_CreatedDate, 
                 PaymentM_RunNo, 
                 PaymentM_CollectAmt, 
                 PaymentM_Change, 
                 PaymentM_CardNumber
                )
                       SELECT @strReceiptNo, 
                              PaymentMode, 
                              PaymentAmt, 
                              PaymentRemarks, 
                              @strPOSUserCode, 
                              GETDATE(), 
                              DetailID, 
                              PaymentCollect, 
                              PaymentChange, 
                              PaymentCardNumber
                       FROM OPENXML(@intDoc_PayMode, N'/NewDataSet/Table1', 2) WITH(PaymentMode NVARCHAR(50), PaymentAmt MONEY, PaymentRemarks NVARCHAR(200), DetailID INT, PaymentCollect MONEY, PaymentChange MONEY, PaymentCardNumber NVARCHAR(50));
            END;
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
