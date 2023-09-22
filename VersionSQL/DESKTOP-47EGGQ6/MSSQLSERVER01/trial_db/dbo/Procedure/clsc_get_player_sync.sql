/****** Object:  Procedure [dbo].[clsc_get_player_sync]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[clsc_get_player_sync]
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT tblCard.Card_SerialNo, 
               tblCardOwner.CardOwner_Name, 
               tblCardOwner.CardOwner_clsc_allow_play, 
               tblCardOwner.CardOwner_clsc_allow_play_message, 
               tblCardOwner.CardOwner_clsc_new_message, 
               tblCardOwner.CardOwner_clsc_new_notification, 
               tblCard.Card_Balance, 
               tblCard.Card_Balance_Cashable, 
               tblCard.Card_Balance_Cashable_No, 
               tblCard.Card_Point, 
               tblCardOwner.CardOwner_clsc_checksum,
			   CardOwner_ID
        FROM tblCard
             INNER JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID
		WHERE CardOwner_clsc_sync = 0
    END;
