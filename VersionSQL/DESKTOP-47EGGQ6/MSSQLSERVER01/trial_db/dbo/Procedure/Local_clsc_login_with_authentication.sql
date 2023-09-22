/****** Object:  Procedure [dbo].[Local_clsc_login_with_authentication]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Local_clsc_login_with_authentication] @card_sn         NVARCHAR(50), 
                                                       @start           DATETIME, 
                                                       @end             DATETIME, 
                                                       @app_version     NVARCHAR(50), 
                                                       @setting_version NVARCHAR(50), 
                                                       @ip              NVARCHAR(50), 
                                                       @imei            NVARCHAR(50), 
                                                       @cardOwner_name  NVARCHAR(50), 
                                                       @companyCode     NVARCHAR(50), 
                                                       @password        NVARCHAR(MAX),
													     @CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            IF
            (
                SELECT COUNT(*)
                FROM tblCard
                WHERE Card_SerialNo = @card_sn
                      AND tblCard_pin = @password
            ) > 0
                BEGIN
                    UPDATE A
                      SET 
                    --CardOwner_Name = @cardOwner_name, 
                          CardOwner_clsc_allow_play = 0, 
                          CardOwner_clsc_allow_play_message = NULL
                    FROM tblCardOwner A
                         JOIN tblCard C ON A.CardOwner_ID = C.Card_CardOwner_ID
                    WHERE C.Card_SerialNo = @card_sn;
					set @CardId=@card_sn;
					set @CardOwnerId=@card_sn;

                    SELECT 1 AS RETURN_RESULT;
                END;
                ELSE
                BEGIN
                    SELECT-1 AS RETURN_RESULT, 
                          'Invalid Account Credential.' MSG;
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;
            DECLARE @expired_date AS DATETIME= DATEADD(day, 30, GETDATE());
            DECLARE @session_key AS NVARCHAR(1024);
            UPDATE [session]
              SET 
                  session_expired = 1
            WHERE session_id =
            (
                SELECT session_id
                FROM session_transaction
                WHERE card_serialNo = @card_sn
            );
            SET @session_key = CONVERT(VARCHAR(1000), RIGHT(NEWID(), 30)) + CONVERT(VARCHAR, DATEDIFF(s, '1970-01-01', GETUTCDATE()), 121) + CONVERT(VARCHAR(1000), RIGHT(NEWID(), 30)) + CONVERT(VARCHAR, DATEDIFF(s, '1970-01-01', GETUTCDATE()), 121) + CONVERT(VARCHAR(1000), RIGHT(NEWID(), 30)) + CONVERT(VARCHAR, DATEDIFF(s, '1970-01-01', GETUTCDATE()), 121);
            INSERT INTO session
            (session_key, 
             session_card_serial_no, 
             session_createdon, 
             session_expire_datetime, 
             session_imei, 
             session_ip, 
             session_setting_version, 
             session_app_version
            )
            VALUES
            (@session_key, 
             @card_sn, 
             GETDATE(), 
             @expired_date, 
             @imei, 
             @ip, 
             @setting_version, 
             @app_version
            );
            IF @@ROWCOUNT = 0
                BEGIN
                    SELECT-97 AS RETURN_RESULT;
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;
            PRINT 11111;
            SELECT @card_sn AS card_sn, 
                   0 AS 'user_id', 
                   tblCardOwner.CardOwner_Name AS 'user_name', 
                   tblCardOwner.CardOwner_MobileNumber AS 'mobile', 
                   tblCardOwner.CardOwner_clsc_allow_play, 
                   tblCardOwner.CardOwner_clsc_allow_play_message, 
                   tblCardOwner.CardOwner_clsc_new_message, 
                   tblCardOwner.CardOwner_clsc_new_notification, 
                   @expired_date AS expired_datetime, 
                   @session_key AS session_key, 
                   Card_Balance AS 'balance', 
                   tblCard.Card_Balance_Cashable AS restricted_promotional, 
                   tblCard.Card_Balance_Cashable_No AS non_restricted_promotional, 
                   Card_Point AS 'point', 
                   CONVERT(DECIMAL(18, 8), 0) AS rate, 
            (
                SELECT tblCardType.CardType_Rate
                FROM tblCardType
                     JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID
                WHERE tblCard.Card_SerialNo = @card_sn
            ) AS card_rate, 
            (
                SELECT tblCardType.CardType_Name
                FROM tblCardType
                     JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID
                WHERE tblCard.Card_SerialNo = @card_sn
            ) AS MemberCard_type, 
            (
                SELECT tblPlayerLevel.PlayerLevel_Name
                FROM tblCard
                     JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID
                     JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = Card_Level
                WHERE tblCard.Card_SerialNo = @card_sn
            ) AS Member_type, 
            (
                SELECT tblPlayerLevel.PlayerLevel_Rate
                FROM tblCard
                     JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID
                     JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = Card_Level
                WHERE tblCard.Card_SerialNo = @card_sn
            ) AS Member_rate
            FROM tblCardOwner
                 INNER JOIN tblCard ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID
            WHERE(tblCard.Card_SerialNo = @card_sn)
                 AND Card_Status = 0;
            COMMIT TRANSACTION;
            SET NOCOUNT OFF;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            SELECT '-98' AS 'RETURN_RESULT';
            SELECT ERROR_MESSAGE();
            SELECT ERROR_LINE();
        END CATCH;
    END;
