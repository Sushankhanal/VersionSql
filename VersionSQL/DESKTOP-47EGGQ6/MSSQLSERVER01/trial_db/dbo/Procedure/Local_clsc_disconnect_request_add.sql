/****** Object:  Procedure [dbo].[Local_clsc_disconnect_request_add]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Local_clsc_disconnect_request_add] @force_disconnect_request_timing   INT            = 30, 
                                                     @CardOwner_clsc_allow_play_message NVARCHAR(2048), 
                                                     @Card_SerialNo                     NVARCHAR(50), 
                                                     @machine_id                        BIGINT, 
                                                     @force_disconnect_request_by       BIGINT,
													 @force_disconnect_request_game_session_id	BIGINT,
													 @CardOwnerId        bigint = NULL OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
        BEGIN TRANSACTION;
        BEGIN TRY
            UPDATE A
              SET 
                  CardOwner_clsc_allow_play = @force_disconnect_request_timing, 
                  CardOwner_clsc_allow_play_message = @CardOwner_clsc_allow_play_message
            FROM tblCardOwner A
                 JOIN tblCard ON Card_CardOwner_ID = A.CardOwner_ID
            WHERE Card_SerialNo = @Card_SerialNo
                  AND CardOwner_clsc_allow_play = 0;
				  set @CardOwnerId=@Card_SerialNo
            IF @@ROWCOUNT > 0
                BEGIN
                    INSERT INTO force_disconnect_request
                    (force_disconnect_request_by, 
                     force_disconnect_request_datetime, 
                     force_disconnect_request_machine_id, 
                     force_disconnect_request_player_serial_no, 
                     force_disconnect_request_timing,
					 force_disconnect_request_game_session_id
                    )
                    VALUES
                    (@force_disconnect_request_by, 
                     GETDATE(), 
                     @machine_id, 
                     @Card_SerialNo, 
                     @force_disconnect_request_timing,
					 @force_disconnect_request_game_session_id
                    );
                    IF @@ROWCOUNT > 0
                        BEGIN
                            SELECT 1 AS RETURN_RESULT;
                            COMMIT TRANSACTION;
                            RETURN;
                        END;
                END;
            SELECT-1 AS RETURN_RESULT;
            ROLLBACK TRANSACTION;
        END TRY
        BEGIN CATCH
            SELECT 0 AS RETURN_RESULT;
            ROLLBACK TRANSACTION;
        END CATCH;
    END;
