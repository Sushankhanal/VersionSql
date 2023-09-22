/****** Object:  Procedure [dbo].[Sync_CardInsertUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[Sync_CardInsertUpdate]
    @CardId bigint
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CardExists INT;

    -- Check if the card record exists in the target table
    SELECT @CardExists = COUNT(*)
    FROM [CloudServer].POSv3.dbo.tblCard
    WHERE Card_ID = @CardId;

    IF @CardExists > 0
    BEGIN
        -- Update the existing record in the target table
        UPDATE [CloudServer].POSv3.dbo.tblCard
        SET 
		[Card_ID]=source.[Card_ID],
		[Card_SerialNo] = source.[Card_SerialNo],
            [Card_Status] = source.[Card_Status],
            [Card_MobileUser] = source.[Card_MobileUser],
            [Card_Balance] = source.[Card_Balance],
            [Card_CreatedBy] = source.[Card_CreatedBy],
            [Card_CreatedDate] = source.[Card_CreatedDate],
            [Card_Point] = source.[Card_Point],
            [Card_CompanyCode] = source.[Card_CompanyCode],
            [Card_Sync] = source.[Card_Sync],
            [Card_SyncDate] = source.[Card_SyncDate],
            [Card_Type] = source.[Card_Type],
            [tblCard_pin] = source.[tblCard_pin],
            [Card_Balance_Cashable_No] = source.[Card_Balance_Cashable_No],
            [Card_Balance_Cashable] = source.[Card_Balance_Cashable],
            [Card_PointAccumulate] = source.[Card_PointAccumulate],
            [Card_isPinReset] = source.[Card_isPinReset],
            [Card_Point_Tier] = source.[Card_Point_Tier],
            [Card_Point_Hidden] = source.[Card_Point_Hidden],
            [Card_isAbleToUpgrade] = source.[Card_isAbleToUpgrade],
            [Card_Level] = source.[Card_Level],
            [Card_last_up_gradetime] = source.[Card_last_up_gradetime],
            [Card_tier_last_reset_time] = source.[Card_tier_last_reset_time],
            [Card_level_expired_time] = source.[Card_level_expired_time],
            [Card_last_down_gradetime] = source.[Card_last_down_gradetime],
            [Card_img] = source.[Card_img],
            [Card_PrintDate] = source.[Card_PrintDate],
            [Card_Expiry_Cashable_No] = source.[Card_Expiry_Cashable_No],
            [Card_Expiry_Cashable] = source.[Card_Expiry_Cashable],
            [Card_balance_Edit_DateTime] = source.[Card_balance_Edit_DateTime],
            [Card_without_sync] = source.[Card_without_sync]
        FROM dbo.tblCard AS source
        WHERE source.Card_ID = @CardId;
    END
    ELSE
    BEGIN
        -- Insert a new record into the target table
        INSERT INTO [CloudServer].POSv3.dbo.tblCard (
		[Card_ID],
            [Card_SerialNo],
            [Card_Status],
            [Card_MobileUser],
            [Card_Balance],
            [Card_CreatedBy],
            [Card_CreatedDate],
            [Card_Point],
            [Card_CompanyCode],
            [Card_CardOwner_ID],
            [Card_Sync],
            [Card_SyncDate],
            [Card_Type],
            [tblCard_pin],
            [Card_Balance_Cashable_No],
            [Card_Balance_Cashable],
            [Card_PointAccumulate],
            [Card_isPinReset],
            [Card_Point_Tier],
            [Card_Point_Hidden],
            [Card_isAbleToUpgrade],
            [Card_Level],
            [Card_last_up_gradetime],
            [Card_tier_last_reset_time],
            [Card_level_expired_time],
            [Card_last_down_gradetime],
            [Card_img],
            [Card_PrintDate],
            [Card_Expiry_Cashable_No],
            [Card_Expiry_Cashable],
            [Card_balance_Edit_DateTime],
            [Card_without_sync]
        )
        SELECT
		[Card_ID],
            [Card_SerialNo],
            [Card_Status],
            [Card_MobileUser],
            [Card_Balance],
            [Card_CreatedBy],
            [Card_CreatedDate],
            [Card_Point],
            [Card_CompanyCode],
            [Card_CardOwner_ID],
            [Card_Sync],
            [Card_SyncDate],
            [Card_Type],
            [tblCard_pin],
            [Card_Balance_Cashable_No],
            [Card_Balance_Cashable],
            [Card_PointAccumulate],
            [Card_isPinReset],
            [Card_Point_Tier],
            [Card_Point_Hidden],
            [Card_isAbleToUpgrade],
            [Card_Level],
            [Card_last_up_gradetime],
            [Card_tier_last_reset_time],
            [Card_level_expired_time],
            [Card_last_down_gradetime],
            [Card_img],
            [Card_PrintDate],
            [Card_Expiry_Cashable_No],
            [Card_Expiry_Cashable],
            [Card_balance_Edit_DateTime],
            [Card_without_sync]
        FROM dbo.tblCard AS source
        WHERE source.Card_ID = @CardId;
    END
END
