/****** Object:  Procedure [dbo].[Local_sp_GiveBonusCreditPoint_Campaign]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Local_sp_GiveBonusCreditPoint_Campaign] @intUserID         BIGINT, 
                                                         @strCardNumber     NVARCHAR(50), 
                                                         @dblAddPoint       DECIMAL(38, 10), 
                                                         @strRemarks        NVARCHAR(500), 
                                                         @strPOSUserCode    NVARCHAR(50), 
                                                         @strCompanyCode    NVARCHAR(50), 
                                                         @strClientFullName NVARCHAR(50) OUT, 
                                                         @strClientBalance  MONEY OUT, 
                                                         @strClientPoint    DECIMAL(38, 10) OUT, 
                                                         @intLocalTransID   INT, 
                                                         @intBranchID       INT, 
                                                         @intMachineID      INT, 
                                                         @intCampaignID     BIGINT, 
                                                         @strTransTimespan  NVARCHAR(50), 
                                                         @intPointTransType INT             = 0,
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

        SET @strCardNumber = RTRIM(LTRIM(@strCardNumber));
        DECLARE @strClientUserCode NVARCHAR(50);
        SET @strClientUserCode = '';
        SET @strClientFullName = '';
        SET @strClientBalance = 0;
        SET @strClientPoint = 0;
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

        --- Start Insert
        DECLARE @strTransCode NVARCHAR(50);
        --Declare @intWalletTransType int = 25
        --Declare @intPaymentType int = 10

        DECLARE @PrefixType VARCHAR(50), @intRowCount INT;
        SET @PrefixType = 'ManualTrans';
        EXEC sp_tblPrefixNumber_GetNextRunNumber 
             'ManualTrans', 
             @PrefixType, 
             0, 
             @strTransCode OUTPUT;

        --Declare @dblDefaultPointRate money = 0
        --select @dblDefaultPointRate = WTransType_DefaultPointRate from tblWalletTransType where WTransType_ID = @intWalletTransType

        DECLARE @intCampaignID_Type INT= 0;
        SELECT @intCampaignID_Type = P.Campaign_Type_ID
        FROM tblCampaign_Point P(NOLOCK)
        WHERE P.Campaign_ID = @intCampaignID;

        --if @strClientUserCode <> '' -- Mean is mobile user
        DECLARE @strMachineName NVARCHAR(100)= '';
        IF @intUserID <> 0 AND 1 = 0 -- Mean is mobile user
            BEGIN
                IF @intCampaignID_Type = 2 -- Mean Lucky Ticket
                    BEGIN
                        IF
                        (
                            SELECT COUNT(Ticket_ID)
                            FROM tblTicket_Bonus tb(NOLOCK)
                            WHERE tb.Ticket_Timespan = @strTransTimespan
                        ) = 0
                            BEGIN
                                SELECT @strMachineName = M.CampaignM_MachineName
                                FROM tblCampaign_Machine M(NOLOCK)
                                WHERE M.CampaignM_Campaign_ID = @intCampaignID
                                      AND M.CampaignM_Machine_ID = @intMachineID;
                                INSERT INTO tblTicket_Bonus
                                (Ticket_Code, 
                                 Ticket_UserCode, 
                                 Ticket_SerialNumber, 
                                 Ticket_CampaignID, 
                                 Ticket_TransDate, 
                                 Ticket_MachineID, 
                                 Ticket_MachineName, 
                                 Ticket_Status, 
                                 Ticket_CreatedBy, 
                                 Ticket_CreatedDate, 
                                 Ticket_UpdatedBy, 
                                 Ticket_UpdatedDate, 
                                 Ticket_LocalID, 
                                 Ticket_Timespan
                                )
                                VALUES
                                (@strTransCode, 
                                 @strClientUserCode, 
                                 @strCardNumber, 
                                 @intCampaignID, 
                                 @transDate, 
                                 @intMachineID, 
                                 @strMachineName, 
                                 0, 
                                 @strPOSUserCode, 
                                 @transDate, 
                                 @strPOSUserCode, 
                                 @transDate, 
                                 @intLocalTransID, 
                                 @strTransTimespan
                                );
                            END;
                    END;
                IF @intCampaignID_Type = 3 -- Mean Bonus Point
                    BEGIN
                        IF @dblAddPoint <> 0
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
                                        DECLARE @dblDefaultPointRate MONEY= 1;
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
                                                 CardPointTrans_Campaign_ID
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
                                                 @intCampaignID
                                                );
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
                                                      CardPointTrans_CreatedDate = @transDate
                                                WHERE CardPointTrans_ID = @intCardPointTransID_;
                                            END;
                                        UPDATE tblCard
                                          SET 
                                              Card_Point = Card_Point + @dblAddPoint
                                        WHERE Card_SerialNo = @strCardNumber
                                              AND Card_CompanyCode = @strCompanyCode;
											  set @CardId=@strCardNumber
                                        UPDATE tblUserMobile
                                          SET 
                                              mUser_TotalPoint = mUser_TotalPoint + @dblAddPoint
                                        WHERE mUser_Code = @strClientUserCode;
                                    END;
                            END;
                    END;
                SELECT @strClientFullName = mUser_FullName, 
                       @strClientBalance = mUser_TotalBalance, 
                       @strClientPoint = mUser_TotalPoint
                FROM tblUserMobile
                WHERE mUser_Code = @strClientUserCode;
            END;
            ELSE -- Mean is card only
            BEGIN
                DECLARE @intCardTransID BIGINT= 0;
                IF @intCampaignID_Type = 2 -- Mean Lucky Ticket
                    BEGIN
                        IF
                        (
                            SELECT COUNT(Ticket_ID)
                            FROM tblTicket_Bonus tb(NOLOCK)
                            WHERE tb.Ticket_Timespan = @strTransTimespan
                        ) = 0
                            BEGIN
                                SELECT @strMachineName = M.CampaignM_MachineName
                                FROM tblCampaign_Machine M(NOLOCK)
                                WHERE M.CampaignM_Campaign_ID = @intCampaignID
                                      AND M.CampaignM_Machine_ID = @intMachineID;
                                INSERT INTO tblTicket_Bonus
                                (Ticket_Code, 
                                 Ticket_UserCode, 
                                 Ticket_SerialNumber, 
                                 Ticket_CampaignID, 
                                 Ticket_TransDate, 
                                 Ticket_MachineID, 
                                 Ticket_MachineName, 
                                 Ticket_Status, 
                                 Ticket_CreatedBy, 
                                 Ticket_CreatedDate, 
                                 Ticket_UpdatedBy, 
                                 Ticket_UpdatedDate, 
                                 Ticket_LocalID, 
                                 Ticket_Timespan
                                )
                                VALUES
                                (@strTransCode, 
                                 '', 
                                 @strCardNumber, 
                                 @intCampaignID, 
                                 @transDate, 
                                 @intMachineID, 
                                 @strMachineName, 
                                 0, 
                                 @strPOSUserCode, 
                                 @transDate, 
                                 @strPOSUserCode, 
                                 @transDate, 
                                 @intLocalTransID, 
                                 @strTransTimespan
                                );
                            END;
                    END;
                IF @intCampaignID_Type = 3 -- Mean Bonus Point
                    BEGIN
                        IF @dblAddPoint <> 0
                            BEGIN
                                IF
                                (
                                    SELECT COUNT(CardPointTrans_ID)
                                    FROM tblCardPointTrans Pt(NOLOCK)
                                    WHERE Pt.CardPointTrans_Timespan = @strTransTimespan
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
                                                 CardPointTrans_Campaign_ID
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
                                                 @intCampaignID
                                                );
                                                SELECT @intCardTransID = SCOPE_IDENTITY();
                                                IF @dblAddPoint > 0
                                                    BEGIN
                                                        UPDATE tblCard
                                                          SET 
                                                              Card_PointAccumulate = Card_PointAccumulate + @dblAddPoint
                                                        WHERE Card_SerialNo = @strCardNumber;
														set @CardId=@strCardNumber
                                                    END;
                                            END;
                                            ELSE
                                            BEGIN
                                                UPDATE tblCardPointTrans
                                                  SET 
                                                      CardPointTrans_Value = CardPointTrans_Value + @dblAddPoint, 
                                                      CardPointTrans_PointValue = CardPointTrans_PointValue + 1, 
                                                      CardPointTrans_CreatedBy = @strPOSUserCode, 
                                                      CardPointTrans_CreatedDate = @transDate
                                                WHERE CardPointTrans_ID = @intCardPointTransID;
                                            END;
                                        UPDATE tblCard
                                          SET 
                                              Card_Point = Card_Point + @dblAddPoint
                                        WHERE Card_SerialNo = @strCardNumber
                                              AND Card_CompanyCode = @strCompanyCode;
											  set @CardId=@strCardNumber
                                    END;
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
        IF @@ERROR <> 0
            GOTO ErrorHandler;
        COMMIT TRANSACTION;
        SET NOCOUNT OFF;
        RETURN(0);
        ErrorHandler:
        ROLLBACK TRANSACTION;
        RETURN(@@ERROR);
    END;
