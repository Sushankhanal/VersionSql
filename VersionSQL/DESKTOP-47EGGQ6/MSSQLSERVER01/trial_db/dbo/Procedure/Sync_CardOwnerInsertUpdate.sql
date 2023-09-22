/****** Object:  Procedure [dbo].[Sync_CardOwnerInsertUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[Sync_CardOwnerInsertUpdate]
    @CardOwnerId bigint   

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CardOwnerExists INT;

    -- Check if the card owner record exists in the target table
    SELECT @CardOwnerExists = COUNT(*)
    FROM [CloudServer].POSv3.dbo.tblCardOwner
    WHERE CardOwner_ID = @CardOwnerId;

    IF @CardOwnerExists > 0
    BEGIN
        -- Update the existing record in the target table
        UPDATE [CloudServer].POSv3.dbo.tblCardOwner
        SET
		CardOwner_ID=source.[CardOwner_ID],
		[CardOwner_CardSerialNo] = source.[CardOwner_CardSerialNo],
            [CardOwner_Name] = source.[CardOwner_Name],
            [CardOwner_MobileNumber] = source.[CardOwner_MobileNumber],
            [CardOwner_Gender] = source.[CardOwner_Gender],
            [CardOwner_Membership] = source.[CardOwner_Membership],
            [CardOwner_IC] = source.[CardOwner_IC],
            [CardOwner_Address] = source.[CardOwner_Address],
            [CardOwner_CreatedBy] = source.[CardOwner_CreatedBy],
            [CardOwner_CreatedDate] = source.[CardOwner_CreatedDate],
            [CardOwner_UpdatedBy] = source.[CardOwner_UpdatedBy],
            [CardOwner_UpdateDate] = source.[CardOwner_UpdateDate],
            [CardOwner_FamilyName] = source.[CardOwner_FamilyName],
            [CardOwner_Country_ID] = source.[CardOwner_Country_ID],
            [CardOwner_Status] = source.[CardOwner_Status],
            [CardOwner_Level] = source.[CardOwner_Level],
            [CardOwner_DOB] = source.[CardOwner_DOB],
            [CardOwner_Email] = source.[CardOwner_Email],
            [CardOwner_IDType] = source.[CardOwner_IDType],
            [CardOwner_Remarks] = source.[CardOwner_Remarks],
            [CardOwner_Barred] = source.[CardOwner_Barred],
            [CardOwner_BarredReason] = source.[CardOwner_BarredReason],
            [CardOwner_Pic] = source.[CardOwner_Pic],
            [CardOwner_clsc_new_notification] = source.[CardOwner_clsc_new_notification],
            [CardOwner_clsc_new_message] = source.[CardOwner_clsc_new_message],
            [CardOwner_clsc_allow_play] = source.[CardOwner_clsc_allow_play],
            [CardOwner_clsc_allow_play_message] = source.[CardOwner_clsc_allow_play_message],
            [CardOwner_clsc_sync] = source.[CardOwner_clsc_sync],
            [CardOwner_clsc_checksum] = source.[CardOwner_clsc_checksum],
            [CardOwner_clsc_suffix] = source.[CardOwner_clsc_suffix]
        FROM dbo.tblCardOwner AS source
        WHERE source.CardOwner_ID = @CardOwnerId;
    END
    ELSE
    BEGIN
        -- Insert a new record into the target table
        INSERT INTO [CloudServer].POSv3.dbo.tblCardOwner (
		[CardOwner_ID],
            [CardOwner_CardSerialNo],
            [CardOwner_Name],
            [CardOwner_MobileNumber],
            [CardOwner_Gender],
            [CardOwner_Membership],
            [CardOwner_IC],
            [CardOwner_Address],
            [CardOwner_CreatedBy],
            [CardOwner_CreatedDate],
            [CardOwner_UpdatedBy],
            [CardOwner_UpdateDate],
            [CardOwner_FamilyName],
            [CardOwner_Country_ID],
            [CardOwner_Status],
            [CardOwner_Level],
            [CardOwner_DOB],
            [CardOwner_Email],
            [CardOwner_IDType],
            [CardOwner_Remarks],
            [CardOwner_Barred],
            [CardOwner_BarredReason],
            [CardOwner_Pic],
            [CardOwner_clsc_new_notification],
            [CardOwner_clsc_new_message],
            [CardOwner_clsc_allow_play],
            [CardOwner_clsc_allow_play_message],
            [CardOwner_clsc_sync],
            [CardOwner_clsc_checksum],
            [CardOwner_clsc_suffix]
        )
        SELECT
		[CardOwner_ID],
            [CardOwner_CardSerialNo],
            [CardOwner_Name],
            [CardOwner_MobileNumber],
            [CardOwner_Gender],
            [CardOwner_Membership],
            [CardOwner_IC],
            [CardOwner_Address],
            [CardOwner_CreatedBy],
            [CardOwner_CreatedDate],
            [CardOwner_UpdatedBy],
            [CardOwner_UpdateDate],
            [CardOwner_FamilyName],
            [CardOwner_Country_ID],
            [CardOwner_Status],
            [CardOwner_Level],
            [CardOwner_DOB],
            [CardOwner_Email],
            [CardOwner_IDType],
            [CardOwner_Remarks],
            [CardOwner_Barred],
            [CardOwner_BarredReason],
            [CardOwner_Pic],
            [CardOwner_clsc_new_notification],
            [CardOwner_clsc_new_message],
            [CardOwner_clsc_allow_play],
            [CardOwner_clsc_allow_play_message],
            [CardOwner_clsc_sync],
            [CardOwner_clsc_checksum],
            [CardOwner_clsc_suffix]
        FROM dbo.tblCardOwner AS source
        WHERE source.CardOwner_ID = @CardOwnerId;
    END


END
