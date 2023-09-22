/****** Object:  Procedure [dbo].[Local_clsc_update_player_sync]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Local_clsc_update_player_sync] @checksum     BIGINT, 
                                                 @cardOwner_id BIGINT,
												   @CardOwnerId        bigint = NULL OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE tblCardOwner
          SET 
              CardOwner_clsc_sync = 1
        WHERE @checksum = CardOwner_clsc_checksum
              AND @cardOwner_id = CardOwner_ID;
			  set @CardOwnerId=@cardOwner_id
    END;
