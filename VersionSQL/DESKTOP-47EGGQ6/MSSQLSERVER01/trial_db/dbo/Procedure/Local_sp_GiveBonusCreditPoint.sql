/****** Object:  Procedure [dbo].[Local_sp_GiveBonusCreditPoint]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Local_sp_GiveBonusCreditPoint] @intUserID             BIGINT, 
                                                @strCardNumber         NVARCHAR(50), 
                                                @dblAddAmt             MONEY, 
                                                @dblAddPoint           DECIMAL(38, 10), 
                                                @strRemarks            NVARCHAR(500), 
                                                @strPOSUserCode        NVARCHAR(50), 
                                                @strCompanyCode        NVARCHAR(50), 
                                                @strClientFullName     NVARCHAR(50) OUT, 
                                                @strClientBalance      MONEY OUT, 
                                                @strClientPoint        DECIMAL(38, 10) OUT, 
                                                @intLocalTransID       NVARCHAR(100), 
                                                @intBranchID           INT, 
                                                @intMachineID          INT, 
                                                @dblAddAmt_NonCashable MONEY, 
                                                @dblAddAmt_Cashable    MONEY, 
                                                @strExtraInfo          XML, 
                                                @strTransTimespan      NVARCHAR(50), 
                                                @intPointTransType     INT             = 0, 
                                                @strTransNo            NVARCHAR(50) OUT,
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        BEGIN TRANSACTION;
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        --SET NOCOUNT ON;

        DECLARE @transDate AS DATETIME= GETDATE();
        DECLARE @intialAmount AS MONEY= 0.00;
        DECLARE @finalAmount AS MONEY= 0.00;
        SET @strCardNumber = RTRIM(LTRIM(@strCardNumber));
        DECLARE @strClientUserCode NVARCHAR(50);
        SET @strClientUserCode = '';
        SET @strClientFullName = '';
        SET @strClientBalance = 0;
        SET @strClientPoint = 0;
        SET @strTransNo = '';
        SET @intUserID = 0;
        IF @intUserID <> 0
            BEGIN
                SELECT @strClientUserCode = mUser_Code, 
                       @strClientFullName = mUser_FullName, 
                       @strClientBalance = mUser_TotalBalance, 
                       @strClientPoint = mUser_TotalPoint
                FROM tblUserMobile
                WHERE mUser_ID = @intUserID;
                IF @strClientUserCode = ''
                    BEGIN
                        ROLLBACK TRANSACTION;
                        SET NOCOUNT OFF;
                        RETURN(-6);
                        -- invalid user id
                    END;
            END;
            ELSE
            BEGIN
                IF @strCardNumber <> ''
                    BEGIN
                        DECLARE @intCount_Card INT;
                        SELECT @intCount_Card = COUNT(Card_ID)
                        FROM tblCard
                        WHERE Card_SerialNo = @strCardNumber
                              AND Card_CompanyCode = @strCompanyCode;
                        SET @strClientUserCode = @strCardNumber;
                        IF @intCount_Card = 0
                            BEGIN
                                ROLLBACK TRANSACTION;
                                SET NOCOUNT OFF;
                                RETURN(-20);
                                -- Not available card number
                            END;
                        IF @intCount_Card > 0
                            BEGIN
                                SELECT @strClientUserCode = Card_MobileUser, 
                                       @strClientBalance = Card_Balance, 
                                       @strClientPoint = Card_Point
                                FROM tblCard
                                WHERE Card_SerialNo = @strCardNumber
                                      AND Card_CompanyCode = @strCompanyCode;
                            END;
                    END;
                    ELSE
                    BEGIN
                        ROLLBACK TRANSACTION;
                        SET NOCOUNT OFF;
                        RETURN(-10);
                        -- PLease provide card number
                    END;
            END;

        --- Get xml Data
        DECLARE @MoneyIn MONEY= 0;
        DECLARE @MoneyOut MONEY= 0;
        DECLARE @Turnover MONEY= 0;
        DECLARE @Won MONEY= 0;
        DECLARE @GamePlayed MONEY= 0;
        DECLARE @PointEarned MONEY= 0;
        DECLARE @Happy_hour_rate MONEY= 0;
        DECLARE @Member_card_type_rate MONEY= 0;
        DECLARE @Machine_rate MONEY= 0;
        DECLARE @Player_multiplier MONEY= 0;
        DECLARE @Base_rate MONEY= 0;
        DECLARE @ptmsessionId BIGINT= 0;
        DECLARE @clssessionId BIGINT= 0;
        DECLARE @PaymentDetailaddonXml NVARCHAR(MAX)= '';
        SET @PaymentDetailaddonXml = CONVERT(NVARCHAR(MAX), @strExtraInfo);
        IF @PaymentDetailaddonXml <> ''
            BEGIN
                DECLARE @objXml_Addon XML, @intDoc_Addon INT;
                SELECT @objXml_Addon = @PaymentDetailaddonXml;
                EXEC sp_xml_preparedocument 
                     @intDoc_Addon OUTPUT, 
                     @objXml_Addon;
                SELECT TOP 1 @MoneyIn = MoneyIn, 
                             @MoneyOut = MoneyOut, 
                             @Turnover = Turnover, 
                             @Won = Won, 
                             @GamePlayed = GamePlayed, 
                             @PointEarned = PointEarned, 
                             @Happy_hour_rate = Happy_hour_rate, 
                             @Member_card_type_rate = Member_card_type_rate, 
                             @Machine_rate = Machine_rate, 
                             @Player_multiplier = Player_multiplier, 
                             @Base_rate = Base_rate, 
                             @ptmsessionId = ptmSessionId, 
                             @clssessionId = sessionId
                FROM OPENXML(@intDoc_Addon, N'/PTMServiceSessionData', 2) WITH(MoneyIn MONEY, MoneyOut MONEY, Turnover MONEY, Won MONEY, GamePlayed MONEY, PointEarned MONEY, Happy_hour_rate MONEY, Member_card_type_rate MONEY, Machine_rate MONEY, Player_multiplier MONEY, Base_rate MONEY, sessionId BIGINT, ptmSessionId BIGINT);
            END;
        --			<?xml version="1.0" encoding="utf-16"?>
        --<PTMServiceSessionData>
        --	<MoneyIn>0</MoneyIn>
        --	<MoneyOut>0</MoneyOut>
        --	<Turnover>0</Turnover>
        --	<Won>0</Won>
        --	<GamePlayed>0</GamePlayed>
        --	<Happy_hour_rate>1</Happy_hour_rate>
        --	<Member_card_type_rate>2</Member_card_type_rate>
        --	<Machine_rate>1</Machine_rate>
        --	<Player_multiplier>1</Player_multiplier>
        --	<Base_rate>0.0001</Base_rate>
        --	<PointEarned>0.00</PointEarned>
        --</PTMServiceSessionData>
        --- Start Insert
        DECLARE @strTransCode NVARCHAR(50);
        DECLARE @intWalletTransType INT= 12;
        DECLARE @intPaymentType INT= 10;
        DECLARE @PrefixType VARCHAR(50), @intRowCount INT;
        SET @PrefixType = 'ManualTrans';
        EXEC sp_tblPrefixNumber_GetNextRunNumber 
             'ManualTrans', 
             @PrefixType, 
             0, 
             @strTransCode OUTPUT;
        SET @strTransNo = @strTransCode;
        DECLARE @dblDefaultPointRate MONEY= 0;
        SELECT @dblDefaultPointRate = WTransType_DefaultPointRate
        FROM tblWalletTransType
        WHERE WTransType_Name = 'Bonus';
        DECLARE @intCardTransID_2 BIGINT= 0;
        DECLARE @intCardTransID_3 BIGINT= 0;

        --if @strClientUserCode <> '' -- Mean is mobile user
        IF @intUserID <> 0
           AND 1 = 0 -- Mean is mobile user
            BEGIN
                RETURN;
                IF @dblAddAmt <> 0
                    BEGIN
                        DECLARE @strWalletCode NVARCHAR(50);
                        SELECT @strWalletCode = UWallet_Code
                        FROM tblUserWallet
                        WHERE UWallet_UserCode = @strClientUserCode;
                        IF
                        (
                            SELECT COUNT(WalletTrans_ID)
                            FROM tblWalletTrans w(NOLOCK)
                            WHERE w.WalletTrans_Timespan = @strTransTimespan
                        ) = 0
                            BEGIN
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
                                 WalletTrans_QRCodeText, 
                                 WalletTrans_Timespan
                                )
                                VALUES
                                (@strTransCode, 
                                 @strClientUserCode, 
                                 @strWalletCode, 
                                 @intPointTransType, 
                                 @dblAddAmt, 
                                 @dblAddAmt, 
                                 @strTransCode, 
                                 @strRemarks, 
                                 @strPOSUserCode, 
                                 @transDate, 
                                 '', 
                                 @intPaymentType, 
                                 '', 
                                 @strTransTimespan
                                );
                                UPDATE tblUserWallet
                                  SET 
                                      UWallet_Balance = UWallet_Balance + @dblAddAmt
                                WHERE UWallet_Code = @strWalletCode;
                                UPDATE tblUserMobile
                                  SET 
                                      mUser_TotalBalance = mUser_TotalBalance + @dblAddAmt
                                WHERE mUser_Code = @strClientUserCode;
                            END;
                    END;

                --if @dblAddPoint <> 0
                IF 0 = 0
                    BEGIN
                        IF
                        (
                            SELECT COUNT(CardPointTrans_ID)
                            FROM tblCardPointTrans Pt(NOLOCK)
                            WHERE Pt.CardPointTrans_Timespan = @strTransTimespan
                                  AND CardPointTrans_LocalTransID = @intLocalTransID
                        ) = 0
                            BEGIN
                                DECLARE @intCardPointTransID_ BIGINT= 0;
                                SELECT @intCardPointTransID_ = CardPointTrans_ID
                                FROM tblCardPointTrans
                                WHERE CardPointTrans_LocalTransID = @intLocalTransID
                                      AND CardPointTrans_BranchID = @intBranchID
                                      AND CardPointTrans_MachineID = @intMachineID
                                      AND CardPointTrans_SerialNo = @strCardNumber;
                                IF @intCardPointTransID_ = 0
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
                                         CardPointTrans_MachineID, 
                                         CardPointTrans_Timespan
                                        )
                                        VALUES
                                        (@strTransCode, 
                                         @strCardNumber, 
                                         @intPointTransType, 
                                         @dblAddPoint, 
                                         @dblAddPoint, 
                                         @strTransCode, 
                                         @strRemarks, 
                                         @strPOSUserCode, 
                                         @transDate, 
                                         '', 
                                         @strCardNumber, 
                                         0, 
                                         @dblDefaultPointRate, 
                                         @intLocalTransID, 
                                         @intBranchID, 
                                         @intMachineID, 
                                         @strTransTimespan
                                        );
                                        DECLARE @intCardTransID2 BIGINT= 0;
                                        SELECT @intCardTransID2 = SCOPE_IDENTITY();
                                        UPDATE tblCardPointTrans
                                          SET 
                                              CardPointTrans_Remarks = @PaymentDetailaddonXml, 
                                              CardPointTrans_MoneyIn = @MoneyIn, 
                                              CardPointTrans_MoneyOut = @MoneyOut, 
                                              CardPointTrans_Turnover = @Turnover, 
                                              CardPointTrans_Won = @Won, 
                                              CardPointTrans_GamePlayed = @GamePlayed, 
                                              CardPointTrans_PointEarned = @PointEarned, 
                                              CardPointTrans_HappyHourRate = @Happy_hour_rate, 
                                              CardPointTrans_MemberCardTypeRate = @Member_card_type_rate, 
                                              CardPointTrans_MachineRate = @Machine_rate, 
                                              CardPointTrans_PlayerMultiplier = @Player_multiplier, 
                                              CardPointTrans_BaseRate = @Base_rate, 
                                              CardPointTrans_Timespan = @strTransTimespan
                                        WHERE CardPointTrans_ID = @intCardTransID2;
                                        IF @dblAddPoint > 0
                                            BEGIN
                                                UPDATE tblCard
                                                  SET 
                                                      Card_PointAccumulate = Card_PointAccumulate + @dblAddPoint
                                                WHERE Card_SerialNo = @strCardNumber;
												set @CardId=@strCardNumber;
                                            END;
                                    END;
                                    ELSE
                                    BEGIN
                                        UPDATE tblCardPointTrans
                                          SET 
                                              CardPointTrans_Value = CardPointTrans_Value + @dblAddPoint, 
                                              CardPointTrans_PointValue = CardPointTrans_PointValue + 1, 
                                              CardPointTrans_CreatedBy = @strPOSUserCode, 
                                              CardPointTrans_CreatedDate = @transDate, 
                                              CardPointTrans_Remarks = @PaymentDetailaddonXml, 
                                              CardPointTrans_MoneyIn = @MoneyIn, 
                                              CardPointTrans_MoneyOut = @MoneyOut, 
                                              CardPointTrans_Turnover = @Turnover, 
                                              CardPointTrans_Won = @Won, 
                                              CardPointTrans_GamePlayed = @GamePlayed, 
                                              CardPointTrans_PointEarned = @PointEarned, 
                                              CardPointTrans_HappyHourRate = @Happy_hour_rate, 
                                              CardPointTrans_MemberCardTypeRate = @Member_card_type_rate, 
                                              CardPointTrans_MachineRate = @Machine_rate, 
                                              CardPointTrans_PlayerMultiplier = @Player_multiplier, 
                                              CardPointTrans_BaseRate = @Base_rate
                                        WHERE CardPointTrans_ID = @intCardPointTransID_;
                                    END;
                                UPDATE tblCard
                                  SET 
                                      Card_Point = Card_Point + @dblAddPoint
                                WHERE Card_SerialNo = @strCardNumber
                                      AND Card_CompanyCode = @strCompanyCode;
									  set @CardId=@strCardNumber;
                                UPDATE tblUserMobile
                                  SET 
                                      mUser_TotalPoint = mUser_TotalPoint + @dblAddPoint
                                WHERE mUser_Code = @strClientUserCode;
                            END;
                    END;
                IF @dblAddAmt_NonCashable <> 0
                    BEGIN
                        IF
                        (
                            SELECT COUNT(CardTrans_ID)
                            FROM tblCard_Trans ct(NOLOCK)
                            WHERE ct.CardTrans_Timespan = @strTransTimespan
                        ) = 0
                            BEGIN
                                SET @intWalletTransType = 20;
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
                                 CardTrans_Timespan, 
                                 CardTrans_Remarks
                                )
                                VALUES
                                (@strTransCode, 
                                 @strCardNumber, 
                                 @transDate, 
                                 @intWalletTransType, 
                                 @dblAddAmt_NonCashable, 
                                 @dblAddAmt_NonCashable, 
                                 @strTransCode, 
                                 @strCardNumber, 
                                 @transDate, 
                                 '', 
                                 @intPaymentType, 
                                 @strTransTimespan, 
                                 @strRemarks
                                );
                                SELECT @intCardTransID_2 = SCOPE_IDENTITY();
                                UPDATE tblCard
                                  SET 
                                      Card_Balance_Cashable_No = Card_Balance_Cashable_No + @dblAddAmt_NonCashable
                                WHERE Card_SerialNo = @strCardNumber;
								set @CardId=@strCardNumber;
                            END;
                    END;
                IF @dblAddAmt_Cashable <> 0
                    BEGIN
                        IF
                        (
                            SELECT COUNT(CardTrans_ID)
                            FROM tblCard_Trans ct(NOLOCK)
                            WHERE ct.CardTrans_Timespan = @strTransTimespan
                        ) = 0
                            BEGIN
                                SET @intWalletTransType = 21;
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
                                 CardTrans_Remarks
                                )
                                VALUES
                                (@strTransCode, 
                                 @strCardNumber, 
                                 @transDate, 
                                 @intWalletTransType, 
                                 @dblAddAmt_Cashable, 
                                 @dblAddAmt_Cashable, 
                                 @strTransCode, 
                                 @strCardNumber, 
                                 @transDate, 
                                 '', 
                                 @intPaymentType, 
                                 @strRemarks
                                );
                                SELECT @intCardTransID_3 = SCOPE_IDENTITY();
                                UPDATE tblCard
                                  SET 
                                      Card_Balance_Cashable = Card_Balance_Cashable + @dblAddAmt_Cashable
                                WHERE Card_SerialNo = @strCardNumber;
								set @CardId=@strCardNumber
                            END;
                    END;
                SELECT @strClientFullName = mUser_FullName, 
                       @strClientBalance = mUser_TotalBalance, 
                       @strClientPoint = mUser_TotalPoint
                FROM tblUserMobile
                WHERE mUser_Code = @strClientUserCode;
            END;
            ELSE
            BEGIN
                PRINT 100;
                IF @dblAddAmt <> 0
                    BEGIN
                        PRINT 101;
                        IF
                        (
                            SELECT COUNT(CardTrans_ID)
                            FROM tblCard_Trans ct(NOLOCK)
                            WHERE ct.CardTrans_Timespan = @strTransTimespan + '-1'
                                  AND CardTrans_LocalID = @intLocalTransID
                        ) = 0
                            BEGIN
                                PRINT 106;
                                SELECT @intialAmount = Card_Balance, 
                                       @finalAmount = Card_Balance + (@dblAddAmt)
                                FROM tblCard
                                WHERE Card_SerialNo = @strCardNumber;
                                DECLARE @intCardTransID BIGINT= 0;
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
                                 CardTrans_Timespan, 
                                 CardTrans_LocalID, 
                                 CardTrans_Remarks, 
                                 CardTrans_InitialAmount, 
                                 CardTrans_FinalAmount
                                )
                                VALUES
                                (@strTransCode, 
                                 @strCardNumber, 
                                 @transDate, 
                                 @intPointTransType, 
                                 @dblAddAmt, 
                                 @dblAddAmt, 
                                 @strTransCode, 
                                 @strCardNumber, 
                                 @transDate, 
                                 '', 
                                 @intPaymentType, 
                                 @strTransTimespan + '-1', 
                                 @intLocalTransID, 
                                 @strRemarks, 
                                 @intialAmount, 
                                 @finalAmount
                                );
                                SELECT @intCardTransID = SCOPE_IDENTITY();
                                UPDATE tblCard
                                  SET 
                                      Card_Balance = Card_Balance + @dblAddAmt, 
                                      Card_balance_Edit_DateTime = @transDate
                                WHERE Card_SerialNo = @strCardNumber
                                      AND Card_CompanyCode = @strCompanyCode;
									  set @CardId=@strCardNumber
                            END;
                    END;
                IF @dblAddPoint <> 0
                    BEGIN
                        PRINT 102;
                        IF
                        (
                            SELECT COUNT(CardPointTrans_ID)
                            FROM tblCardPointTrans pt(NOLOCK)
                            WHERE pt.CardPointTrans_Timespan = @strTransTimespan
                                  AND CardPointTrans_LocalTransID = @intLocalTransID
                        ) = 0
                            BEGIN
                                -- Added by RIcky on 16 April 2019
                                DECLARE @intCardPointTransID BIGINT= 0;
                                SELECT @intCardPointTransID = CardPointTrans_ID
                                FROM tblCardPointTrans
                                WHERE CardPointTrans_LocalTransID = @intLocalTransID
                                      AND CardPointTrans_BranchID = @intBranchID
                                      AND CardPointTrans_MachineID = @intMachineID
                                      AND CardPointTrans_SerialNo = @strCardNumber;
                                IF @intCardPointTransID = 0
                                --BEGIN
                                --    UPDATE tblCard
                                --      SET 
                                --          Card_Point = Card_Point + @dblAddPoint
                                --    WHERE Card_SerialNo = @strCardNumber
                                --          AND Card_CompanyCode = @strCompanyCode;
                                --    DECLARE @dblActualPointType INT= 0;
                                --    INSERT INTO tblCardPointTrans
                                --    (CardPointTrans_Code, 
                                --     CardPointTrans_SerialNo, 
                                --     CardPointTrans_Type, 
                                --     CardPointTrans_Value, 
                                --     CardPointTrans_PointValue, 
                                --     CardPointTrans_RefCode, 
                                --     CardPointTrans_Remarks, 
                                --     CardPointTrans_CreatedBy, 
                                --     CardPointTrans_CreatedDate, 
                                --     CardPointTrans_CampaignCode, 
                                --     CardPointTrans_QRCodeText, 
                                --     CardPointTrans_WalletAmt, 
                                --     CardPointTrans_Ratio, 
                                --     CardPointTrans_LocalTransID, 
                                --     CardPointTrans_BranchID, 
                                --     CardPointTrans_MachineID, 
                                --     CardPointTrans_PointType
                                --    )
                                --    VALUES
                                --    (@strTransCode, 
                                --     @strCardNumber, 
                                --     @intPointTransType, 
                                --     @dblAddPoint, 
                                --     @dblAddPoint, 
                                --     @strTransCode, 
                                --     @strRemarks, 
                                --     @strPOSUserCode, 
                                --     @transDate, 
                                --     '', 
                                --     @strCardNumber, 
                                --     0, 
                                --     @dblDefaultPointRate, 
                                --     @intLocalTransID, 
                                --     @intBranchID, 
                                --     @intMachineID, 
                                --     @dblActualPointType
                                --    );
                                --    SELECT @intCardTransID = SCOPE_IDENTITY();
                                --    UPDATE tblCardPointTrans
                                --      SET 
                                --          CardPointTrans_Remarks = @PaymentDetailaddonXml, 
                                --          CardPointTrans_MoneyIn = @MoneyIn, 
                                --          CardPointTrans_MoneyOut = @MoneyOut, 
                                --          CardPointTrans_Turnover = @Turnover, 
                                --          CardPointTrans_Won = @Won, 
                                --          CardPointTrans_GamePlayed = @GamePlayed, 
                                --          CardPointTrans_PointEarned = @PointEarned, 
                                --          CardPointTrans_HappyHourRate = @Happy_hour_rate, 
                                --          CardPointTrans_MemberCardTypeRate = @Member_card_type_rate, 
                                --          CardPointTrans_MachineRate = @Machine_rate, 
                                --          CardPointTrans_PlayerMultiplier = @Player_multiplier, 
                                --          CardPointTrans_BaseRate = @Base_rate
                                --    WHERE CardPointTrans_ID = @intCardTransID;
                                --    IF @dblAddPoint > 0
                                --        BEGIN
                                --            UPDATE tblCard
                                --              SET 
                                --                  Card_PointAccumulate = Card_PointAccumulate + @dblAddPoint
                                --            WHERE Card_SerialNo = @strCardNumber;
                                --        END;
                                --    SET @dblActualPointType = 1;
                                --    INSERT INTO tblCardPointTrans
                                --    (CardPointTrans_Code, 
                                --     CardPointTrans_SerialNo, 
                                --     CardPointTrans_Type, 
                                --     CardPointTrans_Value, 
                                --     CardPointTrans_PointValue, 
                                --     CardPointTrans_RefCode, 
                                --     CardPointTrans_Remarks, 
                                --     CardPointTrans_CreatedBy, 
                                --     CardPointTrans_CreatedDate, 
                                --     CardPointTrans_CampaignCode, 
                                --     CardPointTrans_QRCodeText, 
                                --     CardPointTrans_WalletAmt, 
                                --     CardPointTrans_Ratio, 
                                --     CardPointTrans_LocalTransID, 
                                --     CardPointTrans_BranchID, 
                                --     CardPointTrans_MachineID, 
                                --     CardPointTrans_PointType
                                --    )
                                --    VALUES
                                --    (@strTransCode + '-1', 
                                --     @strCardNumber, 
                                --     @intPointTransType, 
                                --     @dblAddPoint, 
                                --     @dblAddPoint, 
                                --     @strTransCode, 
                                --     @strRemarks, 
                                --     @strPOSUserCode, 
                                --     @transDate, 
                                --     '', 
                                --     @strCardNumber, 
                                --     0, 
                                --     @dblDefaultPointRate, 
                                --     @intLocalTransID, 
                                --     @intBranchID, 
                                --     @intMachineID, 
                                --     @dblActualPointType
                                --    );
                                --    SELECT @intCardTransID = SCOPE_IDENTITY();
                                --    UPDATE tblCardPointTrans
                                --      SET 
                                --          CardPointTrans_Remarks = @PaymentDetailaddonXml, 
                                --          CardPointTrans_MoneyIn = @MoneyIn, 
                                --          CardPointTrans_MoneyOut = @MoneyOut, 
                                --          CardPointTrans_Turnover = @Turnover, 
                                --          CardPointTrans_Won = @Won, 
                                --          CardPointTrans_GamePlayed = @GamePlayed, 
                                --          CardPointTrans_PointEarned = @PointEarned, 
                                --          CardPointTrans_HappyHourRate = @Happy_hour_rate, 
                                --          CardPointTrans_MemberCardTypeRate = @Member_card_type_rate, 
                                --          CardPointTrans_MachineRate = @Machine_rate, 
                                --          CardPointTrans_PlayerMultiplier = @Player_multiplier, 
                                --          CardPointTrans_BaseRate = @Base_rate
                                --    WHERE CardPointTrans_ID = @intCardTransID;
                                --    IF @dblAddPoint > 0
                                --        BEGIN
                                --            UPDATE tblCard
                                --              SET 
                                --                  Card_Point_Tier = Card_Point_Tier + @dblAddPoint
                                --            WHERE Card_SerialNo = @strCardNumber;
                                --        END;
                                --            --set @dblActualPointType = 2
                                --            --INSERT INTO tblCardPointTrans
                                --            --(CardPointTrans_Code, CardPointTrans_SerialNo, CardPointTrans_Type, CardPointTrans_Value, 
                                --            --CardPointTrans_PointValue, CardPointTrans_RefCode, CardPointTrans_Remarks, CardPointTrans_CreatedBy, 
                                --            --CardPointTrans_CreatedDate, CardPointTrans_CampaignCode, CardPointTrans_QRCodeText, 
                                --            --CardPointTrans_WalletAmt, CardPointTrans_Ratio,
                                --            --CardPointTrans_LocalTransID, CardPointTrans_BranchID, CardPointTrans_MachineID, CardPointTrans_PointType)
                                --            --VALUES (
                                --            --@strTransCode,@strCardNumber,@intPointTransType,@dblAddPoint,@dblAddPoint,
                                --            --@strTransCode,@strRemarks,@strPOSUserCode,GETDATE(),'',
                                --            --@strCardNumber,0,@dblDefaultPointRate,
                                --            --@intLocalTransID, @intBranchID, @intMachineID, @dblActualPointType)
                                --            --SELECT @intCardTransID = SCOPE_IDENTITY()
                                --            --UPDATE tblCardPointTrans SET 
                                --            --CardPointTrans_Remarks = @PaymentDetailaddonXml, CardPointTrans_MoneyIn = @MoneyIn, CardPointTrans_MoneyOut = @MoneyOut, 
                                --            --CardPointTrans_Turnover = @Turnover, CardPointTrans_Won = @Won, CardPointTrans_GamePlayed = @GamePlayed, CardPointTrans_PointEarned = @PointEarned, 
                                --            --CardPointTrans_HappyHourRate = @Happy_hour_rate, CardPointTrans_MemberCardTypeRate = @Member_card_type_rate, CardPointTrans_MachineRate = @Machine_rate, 
                                --            --CardPointTrans_PlayerMultiplier = @Player_multiplier, CardPointTrans_BaseRate = @Base_rate
                                --            --where CardPointTrans_ID = @intCardTransID
                                --            --if @dblAddPoint > 0
                                --            --BEGIN
                                --            --	Update tblCard set Card_Point_Hidden = Card_Point_Hidden + @dblAddPoint where Card_SerialNo = @strCardNumber 
                                --            --END
                                --END;
                                    BEGIN
                                        UPDATE tblCard
                                          SET 
                                              Card_Point = Card_Point + @dblAddPoint, 
                                              Card_PointAccumulate = Card_PointAccumulate + @dblAddPoint, 
                                              Card_Point_Tier = Card_Point_Tier + @dblAddPoint
                                        WHERE Card_SerialNo = @strCardNumber
                                              AND Card_CompanyCode = @strCompanyCode;
											  set @CardId=@strCardNumber
                                        DECLARE @dblActualPointType INT= 0;
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
                                         CardPointTrans_MachineID, 
                                         CardPointTrans_PointType, 
                                         CardPointTrans_RemarksInfo, 
                                         CardPointTrans_MoneyIn, 
                                         CardPointTrans_MoneyOut, 
                                         CardPointTrans_Turnover, 
                                         CardPointTrans_Won, 
                                         CardPointTrans_GamePlayed, 
                                         CardPointTrans_PointEarned, 
                                         CardPointTrans_HappyHourRate, 
                                         CardPointTrans_MemberCardTypeRate, 
                                         CardPointTrans_MachineRate, 
                                         CardPointTrans_PlayerMultiplier, 
                                         CardPointTrans_BaseRate, 
                                         CardPointTrans_Timespan,
										 CardPointTrans_ptmSessionId,
										 CardPointTrans_SessionId
                                        )
                                        VALUES
                                        (@strTransCode, 
                                         @strCardNumber, 
                                         @intPointTransType, 
                                         @dblAddPoint, 
                                         @dblAddPoint, 
                                         @strTransCode, 
                                         @strRemarks, 
                                         @strPOSUserCode, 
                                         @transDate, 
                                         '', 
                                         @strCardNumber, 
                                         0, 
                                         @dblDefaultPointRate, 
                                         @intLocalTransID, 
                                         @intBranchID, 
                                         @intMachineID, 
                                         @dblActualPointType, 
                                         @PaymentDetailaddonXml, 
                                         @MoneyIn, 
                                         @MoneyOut, 
                                         @Turnover, 
                                         @Won, 
                                         @GamePlayed, 
                                         @PointEarned, 
                                         @Happy_hour_rate, 
                                         @Member_card_type_rate, 
                                         @Machine_rate, 
                                         @Player_multiplier, 
                                         @Base_rate, 
                                         @strTransTimespan, 
                                         @ptmSessionId, 
                                         @clssessionId
                                        );
                                        SELECT @intCardTransID = SCOPE_IDENTITY();
                                        SET @dblActualPointType = 1;
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
                                         CardPointTrans_MachineID, 
                                         CardPointTrans_PointType
                                        )
                                        VALUES
                                        (@strTransCode + '-1', 
                                         @strCardNumber, 
                                         @intPointTransType, 
                                         @dblAddPoint, 
                                         @dblAddPoint, 
                                         @strTransCode, 
                                         @strRemarks, 
                                         @strPOSUserCode, 
                                         @transDate, 
                                         '', 
                                         @strCardNumber, 
                                         0, 
                                         @dblDefaultPointRate, 
                                         LTRIM(RTRIM(STR(@intLocalTransID))) + '-1', 
                                         @intBranchID, 
                                         @intMachineID, 
                                         @dblActualPointType
                                        );
                                        SELECT @intCardTransID = SCOPE_IDENTITY();
                                    END;
                                    ELSE
                                    BEGIN
                                        PRINT 'Record sync before';
                                        --UPDATE tblCardPointTrans
                                        --  SET 
                                        --      CardPointTrans_Value = CardPointTrans_Value + @dblAddPoint, 
                                        --      CardPointTrans_PointValue = CardPointTrans_PointValue + 1, 
                                        --      CardPointTrans_CreatedBy = @strPOSUserCode, 
                                        --      CardPointTrans_CreatedDate = @transDate, 
                                        --      CardPointTrans_Remarks = @PaymentDetailaddonXml, 
                                        --      CardPointTrans_MoneyIn = @MoneyIn, 
                                        --      CardPointTrans_MoneyOut = @MoneyOut, 
                                        --      CardPointTrans_Turnover = @Turnover, 
                                        --      CardPointTrans_Won = @Won, 
                                        --      CardPointTrans_GamePlayed = @GamePlayed, 
                                        --      CardPointTrans_PointEarned = @PointEarned, 
                                        --      CardPointTrans_HappyHourRate = @Happy_hour_rate, 
                                        --      CardPointTrans_MemberCardTypeRate = @Member_card_type_rate, 
                                        --      CardPointTrans_MachineRate = @Machine_rate, 
                                        --      CardPointTrans_PlayerMultiplier = @Player_multiplier, 
                                        --      CardPointTrans_BaseRate = @Base_rate
                                        --WHERE CardPointTrans_ID = @intCardPointTransID;
                                    END;
                            END;
                    END;
                IF @dblAddAmt_NonCashable <> 0
                    BEGIN
                        PRINT 103;
                        IF
                        (
                            SELECT COUNT(CardTrans_ID)
                            FROM tblCard_Trans ct(NOLOCK)
                            WHERE ct.CardTrans_Timespan = @strTransTimespan + '-2'
                                  AND ct.CardTrans_LocalID = LTRIM(RTRIM(STR(@intLocalTransID))) + '-2'
                        ) = 0
                            BEGIN

                                --Declare @intCardTransID_2 bigint = 0
                                SET @intWalletTransType = 20;
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
                                 CardTrans_Remarks, 
                                 CardTrans_Timespan, 
                                 CardTrans_LocalID
                                )
                                VALUES
                                (@strTransCode + '-2', 
                                 @strCardNumber, 
                                 @transDate, 
                                 @intWalletTransType, 
                                 @dblAddAmt_NonCashable, 
                                 @dblAddAmt_NonCashable, 
                                 @strTransCode, 
                                 @strCardNumber, 
                                 @transDate, 
                                 '', 
                                 @intPaymentType, 
                                 @strRemarks, 
                                 @strTransTimespan + '-2', 
                                 LTRIM(RTRIM(STR(@intLocalTransID))) + '-2'
                                );
                                SELECT @intCardTransID_2 = SCOPE_IDENTITY();
                                UPDATE tblCard
                                  SET 
                                      Card_Balance_Cashable_No = Card_Balance_Cashable_No + @dblAddAmt_NonCashable
                                WHERE Card_SerialNo = @strCardNumber;
								set @CardId=@strCardNumber
                            END;
                    END;
                IF @dblAddAmt_Cashable <> 0
                    BEGIN
                        PRINT 104;
                        --Declare @intCardTransID_3 bigint = 0
                        IF
                        (
                            SELECT COUNT(CardTrans_ID)
                            FROM tblCard_Trans ct(NOLOCK)
                            WHERE ct.CardTrans_Timespan = @strTransTimespan + '-3'
                                  AND ct.CardTrans_LocalID = LTRIM(RTRIM(STR(@intLocalTransID))) + '-3'
                        ) = 0
                            BEGIN
                                SET @intWalletTransType = 21;
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
                                 CardTrans_Remarks, 
                                 CardTrans_Timespan, 
                                 CardTrans_LocalID
                                )
                                VALUES
                                (@strTransCode + '-3', 
                                 @strCardNumber, 
                                 @transDate, 
                                 @intWalletTransType, 
                                 @dblAddAmt_Cashable, 
                                 @dblAddAmt_Cashable, 
                                 @strTransCode, 
                                 @strCardNumber, 
                                 @transDate, 
                                 '', 
                                 @intPaymentType, 
                                 @strRemarks, 
                                 @strTransTimespan + '-3', 
                                 LTRIM(RTRIM(STR(@intLocalTransID))) + '-3'
                                );
                                SELECT @intCardTransID_3 = SCOPE_IDENTITY();
                                UPDATE tblCard
                                  SET 
                                      Card_Balance_Cashable = Card_Balance_Cashable + @dblAddAmt_Cashable
                                WHERE Card_SerialNo = @strCardNumber;
								set @CardId=@strCardNumber
                            END;
                    END;
                SET @strClientUserCode = @strCardNumber;
                SET @strClientFullName = @strCardNumber;
                SELECT @strClientBalance = Card_Balance, 
                       @strClientPoint = Card_Point
                FROM tblCard
                WHERE Card_SerialNo = @strCardNumber
                      AND Card_CompanyCode = @strCompanyCode;
            END;

			BEGIN TRY
                EXEC sp_xml_removedocument 
                     @intDoc_Addon;
            END TRY
            BEGIN CATCH
                PRINT ERROR_MESSAGE();
            END CATCH;

        IF @@ERROR <> 0
            GOTO ErrorHandler;
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        PRINT 1111;
        ROLLBACK TRANSACTION;
        RETURN(@@ERROR);
    END;
