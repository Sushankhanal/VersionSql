/****** Object:  Procedure [dbo].[mobile_get_user_info_gaming_day]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_get_user_info_gaming_day] @card_sn    NVARCHAR(50), 
                                                        @machine_id BIGINT, 
                                                        @start      DATETIME, 
                                                        @end        DATETIME
AS
    BEGIN

        --
        DECLARE @day INT= 1;
        DECLARE @card_type INT;
        DECLARE @player_level INT;
        DECLARE @happy_hour_start DATETIME;
        DECLARE @happy_hour_end DATETIME;
        DECLARE @happy_hour_rate DECIMAL(18, 10);
        SELECT @day = CASE
                          WHEN DATENAME(dw, GETDATE()) = 'Sunday'
                          THEN 7
                          WHEN DATENAME(dw, GETDATE()) = 'Saturday'
                          THEN 6
                          WHEN DATENAME(dw, GETDATE()) = 'Friday'
                          THEN 5
                          WHEN DATENAME(dw, GETDATE()) = 'Thursday'
                          THEN 4
                          WHEN DATENAME(dw, GETDATE()) = 'Wednesday'
                          THEN 3
                          WHEN DATENAME(dw, GETDATE()) = 'Tuesday'
                          THEN 2
                          WHEN DATENAME(dw, GETDATE()) = 'Monday'
                          THEN 1
                      END;
        --

        BEGIN TRANSACTION;
        BEGIN TRY
            IF
            (
                SELECT COUNT(*)
                FROM tblCard
                WHERE Card_SerialNo = @card_sn
            ) > 0
                BEGIN
                    SELECT 1 AS RETURN_RESULT;
                END;
                ELSE
                BEGIN
                    SELECT-1 AS RETURN_RESULT;
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;
            DECLARE @expired_date AS DATETIME= DATEADD(day, 30, GETDATE());
            DECLARE @session_key AS NVARCHAR(1024);
            UPDATE [session]
              SET 
                  session_expired = 1
            WHERE session_card_serial_no = @card_sn;
            SET @session_key = CONVERT(VARCHAR(1000), RIGHT(NEWID(), 30)) + CONVERT(VARCHAR, DATEDIFF(s, '1970-01-01', GETUTCDATE()), 121) + CONVERT(VARCHAR(1000), RIGHT(NEWID(), 30)) + CONVERT(VARCHAR, DATEDIFF(s, '1970-01-01', GETUTCDATE()), 121) + CONVERT(VARCHAR(1000), RIGHT(NEWID(), 30)) + CONVERT(VARCHAR, DATEDIFF(s, '1970-01-01', GETUTCDATE()), 121);
            INSERT INTO session
            (session_key, 
             session_card_serial_no, 
             session_createdon, 
             session_expire_datetime
            )
            VALUES
            (@session_key, 
             @card_sn, 
             GETDATE(), 
             @expired_date
            );
            IF @@ROWCOUNT = 0
                BEGIN
                    SELECT-97 AS RETURN_RESULT;
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;
            IF
            (
                SELECT COUNT(*)
                FROM tblUserMobile
                     JOIN tblCard ON Card_MobileUser = mUser_Code
                WHERE Card_SerialNo = @card_sn
            ) > 0
                BEGIN

                    ---

                    SELECT @card_type = tblCard.Card_Type, 
                           @player_level = tblCardOwner.CardOwner_Level
                    FROM tblCard
                         JOIN tblCardOwner ON Card_CardOwner_ID = CardOwner_ID
                    WHERE Card_SerialNo = @card_sn;
                    SELECT TOP 1 @happy_hour_rate = tblCampaign_Point.Campaign_Rate, 
                                 @happy_hour_start = Campaign_StartDate, 
                                 @happy_hour_end = DATEADD(second, 86399, Campaign_EndDate)
                    FROM tblCampaign_Point
                         JOIN tblCampaign_Machine ON CampaignM_Campaign_ID = tblCampaign_Point.Campaign_ID
                    WHERE(CONVERT(DATE, GETDATE()) BETWEEN CONVERT(DATE, tblCampaign_Point.Campaign_StartDate) AND CONVERT(DATE, tblCampaign_Point.Campaign_EndDate))
                         AND tblCampaign_Machine.CampaignM_Machine_ID IN(@machine_id)
                         AND CONVERT(TIME, GETDATE()) BETWEEN tblCampaign_Point.Campaign_StartTime AND Campaign_EndTime
                         AND @card_type IN
                    (
                        SELECT CAST(Item AS INT)
                        FROM dbo.Split(tblCampaign_Point.Campaign_CardType, ',')
                    )
                    AND @player_level IN
                    (
                        SELECT CAST(Item AS INT)
                        FROM dbo.Split(tblCampaign_Point.Campaign_PlayerLevel, ',')
                    )
                    AND @day IN
                    (
                        SELECT CAST(Item AS INT)
                        FROM dbo.Split(tblCampaign_Point.Campaign_Day, ',')
                    )
                    ORDER BY Campaign_Rate DESC;

                    ---

                    SELECT @card_sn AS card_sn, 
                           '' AS suffix, 
                           tblCard.Card_isPinReset, 
                           tblUserMobile.mUser_ID AS 'user_id', 
                           tblUserMobile.mUser_FullName AS 'user_name', 
                           tblUserMobile.mUser_TotalBalance AS 'balance', 
                           tblUserMobile.mUser_TotalPoint AS 'point', 
                           tblUserMobile.mUser_mobileNo AS 'mobile', 
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
                             JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = CardOwner_Level
                        WHERE tblCard.Card_SerialNo = @card_sn
                    ) AS Member_type, 
                    (
                        SELECT tblPlayerLevel.PlayerLevel_Rate
                        FROM tblCard
                             JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID
                             JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = CardOwner_Level
                        WHERE tblCard.Card_SerialNo = @card_sn
                    ) AS Member_rate, 
                           ISNULL((@happy_hour_rate), 1) AS happy_hour_rate, 
                           ISNULL((@happy_hour_start), '1990-01-01 00:00:00') AS happy_hour_start, 
                           ISNULL((@happy_hour_end), '1990-01-01 00:00:00') AS happy_hour_end,

                           --old data

                           ISNULL(
                    (
                        SELECT TOP 1 Campaign_Rate
                        FROM tblCampaign_Point
                        WHERE tblCampaign_Point.Campaign_MachineID = @machine_id
                    ), 1) AS happy_hour_rate_old, 
                           ISNULL(
                    (
                        SELECT TOP 1 Campaign_StartDate
                        FROM tblCampaign_Point
                        WHERE tblCampaign_Point.Campaign_MachineID = @machine_id
                    ), '1990-01-01 00:00:00') AS happy_hour_start_old, 
                           ISNULL(
                    (
                        SELECT TOP 1 Campaign_EndDate
                        FROM tblCampaign_Point
                        WHERE tblCampaign_Point.Campaign_MachineID = @machine_id
                    ), '1990-01-01 00:00:00') AS happy_hour_end_old, 
                           --old data
                    (
                        SELECT tblCard.Card_Balance_Cashable
                        FROM tblCardType
                             JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID
                        WHERE tblCard.Card_SerialNo = @card_sn
                    ) AS non_restricted_promotional, 
                    (
                        SELECT tblCard.Card_Balance_Cashable_No
                        FROM tblCardType
                             JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID
                        WHERE tblCard.Card_SerialNo = @card_sn
                    ) AS restricted_promotional
                    FROM tblUserMobile
                         INNER JOIN tblCard ON tblCard.Card_MobileUser = tblUserMobile.mUser_Code
                    WHERE(tblCard.Card_SerialNo = @card_sn)
                         AND Card_Status = 0;
                    SELECT ISNULL(SUM(MoneyIn), 0) AS MoneyIn, 
                           ISNULL(SUM(MoneyOut), 0) AS MoneyOut, 
                           ISNULL(SUM(Turnover), 0) AS Turnover, 
                           ISNULL(SUM(Won), 0) AS Won, 
                           ISNULL(SUM(GamePlayed), 0) AS GamePlayed, 
                           ISNULL(SUM(PointEarned), 0) AS PointEarned, 
                    (
                        SELECT WTransType_PointRateConvertion
                        FROM tblWalletTransType
                        WHERE WTransType_ID = 14
                    ) AS point_rate, 
                    (
                        SELECT WTransType_PointRateConvertion
                        FROM tblWalletTransType
                        WHERE WTransType_ID = 16
                    ) AS point_rate_restrict, 
                    (
                        SELECT WTransType_PointRateConvertion
                        FROM tblWalletTransType
                        WHERE WTransType_ID = 17
                    ) AS point_rate_non_restrict
                    FROM
                    (
                        SELECT ISNULL([CardPointTrans_MoneyIn], 0) AS MoneyIn, 
                               ISNULL([CardPointTrans_MoneyOut], 0) AS MoneyOut, 
                               ISNULL([CardPointTrans_Turnover], 0) AS Turnover, 
                               ISNULL([CardPointTrans_Won], 0) AS Won, 
                               ISNULL([CardPointTrans_GamePlayed], 0) AS GamePlayed, 
                               ISNULL(CardPointTrans_Value, 0) AS PointEarned
                        FROM tblCardPointTrans
                        WHERE CardPointTrans_SerialNo = @card_sn
                              AND CardPointTrans_CreatedDate BETWEEN @start AND @end
                              AND CardPointTrans_PointType = 0
                              AND CardPointTrans_Type = 12
                    --UNION ALL
                    --SELECT ISNULL([CardTrans_MoneyIn], 0) AS MoneyIn, 
                    --       ISNULL([CardTrans_MoneyOut], 0) AS MoneyOut, 
                    --       ISNULL([CardTrans_Turnover], 0) AS Turnover, 
                    --       ISNULL([CardTrans_Won], 0) AS Won, 
                    --       ISNULL([CardTrans_GamePlayed], 0) AS GamePlayed, 
                    --       ISNULL([CardTrans_PointEarned], 0) AS PointEarned
                    --FROM tblCard_Trans
                    --WHERE CardTrans_SerialNo = @card_sn
                    --      AND CardTrans_CreatedDate BETWEEN @start AND @end
                    ) AS A;
                END;
                ELSE
                BEGIN

                    ---

                    SELECT @card_type = tblCard.Card_Type, 
                           @player_level = tblCardOwner.CardOwner_Level
                    FROM tblCard
                         JOIN tblCardOwner ON Card_CardOwner_ID = CardOwner_ID
                    WHERE Card_SerialNo = @card_sn;
                    SELECT TOP 1 @happy_hour_rate = tblCampaign_Point.Campaign_Rate, 
                                 @happy_hour_start = Campaign_StartDate, 
                                 @happy_hour_end = DATEADD(second, 86399, Campaign_EndDate)
                    FROM tblCampaign_Point
                         JOIN tblCampaign_Machine ON CampaignM_Campaign_ID = tblCampaign_Point.Campaign_ID
                    WHERE(CONVERT(DATE, GETDATE()) BETWEEN CONVERT(DATE, tblCampaign_Point.Campaign_StartDate) AND CONVERT(DATE, tblCampaign_Point.Campaign_EndDate))
                         AND tblCampaign_Machine.CampaignM_Machine_ID IN(@machine_id)
                         AND CONVERT(TIME, GETDATE()) BETWEEN tblCampaign_Point.Campaign_StartTime AND Campaign_EndTime
                         AND @card_type IN
                    (
                        SELECT CAST(Item AS INT)
                        FROM dbo.Split(tblCampaign_Point.Campaign_CardType, ',')
                    )
                    AND @player_level IN
                    (
                        SELECT CAST(Item AS INT)
                        FROM dbo.Split(tblCampaign_Point.Campaign_PlayerLevel, ',')
                    )
                    AND @day IN
                    (
                        SELECT CAST(Item AS INT)
                        FROM dbo.Split(tblCampaign_Point.Campaign_Day, ',')
                    )
                    ORDER BY Campaign_Rate DESC;

                    ---

                    SELECT @card_sn AS card_sn, 
                           0 AS 'user_id', 
                           tblCard.Card_isPinReset, 
                           tblCardOwner.CardOwner_clsc_suffix AS suffix, 
                           tblCardOwner.CardOwner_Name AS 'user_name', 
                           tblCardOwner.CardOwner_MobileNumber AS 'mobile', 
                           tblCardOwner.CardOwner_clsc_allow_play, 
                           tblCardOwner.CardOwner_clsc_allow_play_message, 
                           tblCardOwner.CardOwner_clsc_new_message, 
                           tblCardOwner.CardOwner_clsc_new_notification, 
                           @expired_date AS expired_datetime, 
                           @session_key AS session_key, 
                           Card_Balance AS 'balance', 
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
                             JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = CardOwner_Level
                        WHERE tblCard.Card_SerialNo = @card_sn
                    ) AS Member_type, 
                    (
                        SELECT tblPlayerLevel.PlayerLevel_Rate
                        FROM tblCard
                             JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID
                             JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = CardOwner_Level
                        WHERE tblCard.Card_SerialNo = @card_sn
                    ) AS Member_rate, 
                           ISNULL((@happy_hour_rate), 1) AS happy_hour_rate, 
                           ISNULL((@happy_hour_start), '1990-01-01 00:00:00') AS happy_hour_start, 
                           ISNULL((@happy_hour_end), '1990-01-01 00:00:00') AS happy_hour_end,

                           --old data

                           ISNULL(
                    (
                        SELECT TOP 1 Campaign_Rate
                        FROM tblCampaign_Point
                        WHERE tblCampaign_Point.Campaign_MachineID = @machine_id
                    ), 1) AS happy_hour_rate_old, 
                           ISNULL(
                    (
                        SELECT TOP 1 Campaign_StartDate
                        FROM tblCampaign_Point
                        WHERE tblCampaign_Point.Campaign_MachineID = @machine_id
                    ), '1990-01-01 00:00:00') AS happy_hour_start_old, 
                           ISNULL(
                    (
                        SELECT TOP 1 Campaign_EndDate
                        FROM tblCampaign_Point
                        WHERE tblCampaign_Point.Campaign_MachineID = @machine_id
                    ), '1990-01-01 00:00:00') AS happy_hour_end_old, 
                           --old data
                    (
                        SELECT tblCard.Card_Balance_Cashable
                        FROM tblCardType
                             JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID
                        WHERE tblCard.Card_SerialNo = @card_sn
                    ) AS non_restricted_promotional, 
                    (
                        SELECT tblCard.Card_Balance_Cashable_No
                        FROM tblCardType
                             JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID
                        WHERE tblCard.Card_SerialNo = @card_sn
                    ) AS restricted_promotional
                    FROM tblCardOwner
                         INNER JOIN tblCard ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID
                    WHERE(tblCard.Card_SerialNo = @card_sn)
                         AND Card_Status = 0;
                    SELECT ISNULL(SUM(MoneyIn), 0) AS MoneyIn, 
                           ISNULL(SUM(MoneyOut), 0) AS MoneyOut, 
                           ISNULL(SUM(Turnover), 0) AS Turnover, 
                           ISNULL(SUM(Won), 0) AS Won, 
                           ISNULL(SUM(GamePlayed), 0) AS GamePlayed, 
                           ISNULL(SUM(PointEarned), 0) AS PointEarned, 
                    (
                        SELECT WTransType_PointRateConvertion
                        FROM tblWalletTransType
                        WHERE WTransType_ID = 14
                    ) AS point_rate, 
                    (
                        SELECT WTransType_PointRateConvertion
                        FROM tblWalletTransType
                        WHERE WTransType_ID = 16
                    ) AS point_rate_restrict, 
                    (
                        SELECT WTransType_PointRateConvertion
                        FROM tblWalletTransType
                        WHERE WTransType_ID = 17
                    ) AS point_rate_non_restrict
                    FROM
                    (
                        SELECT ISNULL([CardPointTrans_MoneyIn], 0) AS MoneyIn, 
                               ISNULL([CardPointTrans_MoneyOut], 0) AS MoneyOut, 
                               ISNULL([CardPointTrans_Turnover], 0) AS Turnover, 
                               ISNULL([CardPointTrans_Won], 0) AS Won, 
                               ISNULL([CardPointTrans_GamePlayed], 0) AS GamePlayed, 
                               ISNULL(CardPointTrans_Value, 0) AS PointEarned
                        FROM tblCardPointTrans
                        WHERE CardPointTrans_SerialNo = @card_sn
                              AND CardPointTrans_CreatedDate BETWEEN @start AND @end
                              AND CardPointTrans_PointType = 0
                              AND CardPointTrans_Type = 12
                    --UNION ALL
                    --SELECT ISNULL([CardTrans_MoneyIn], 0) AS MoneyIn, 
                    --       ISNULL([CardTrans_MoneyOut], 0) AS MoneyOut, 
                    --       ISNULL([CardTrans_Turnover], 0) AS Turnover, 
                    --       ISNULL([CardTrans_Won], 0) AS Won, 
                    --       ISNULL([CardTrans_GamePlayed], 0) AS GamePlayed, 
                    --       ISNULL([CardTrans_PointEarned], 0) AS PointEarned
                    --FROM tblCard_Trans
                    --WHERE CardTrans_SerialNo = @card_sn
                    --      AND CardTrans_CreatedDate BETWEEN @start AND @end
                    ) AS A;
                END;


            COMMIT TRANSACTION;
            SET NOCOUNT OFF;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            SELECT '-98' AS 'RETURN_RESULT';
        END CATCH;
    END;
