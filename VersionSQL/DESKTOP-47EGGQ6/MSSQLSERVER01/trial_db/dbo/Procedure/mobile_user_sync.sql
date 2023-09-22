/****** Object:  Procedure [dbo].[mobile_user_sync]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_user_sync] @user_ids AS     BIGINT, 
                                         @user_session AS NVARCHAR(MAX)
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            IF
            (
                SELECT COUNT(*)
                FROM [session]
                WHERE [session].session_user_id = @user_ids
                      AND [session].session_key = @user_session
            ) > 0
            AND
            (
                SELECT COUNT(*)
                FROM tblUserMobile
                WHERE mUser_Status = 1
                      AND mUser_ID = @user_ids
            ) > 0
                BEGIN
                    DECLARE @mUser_MobileNo NVARCHAR(50);
                    SELECT @mUser_MobileNo = mUser_MobileNo
                    FROM tblUserMobile
                    WHERE tblUserMobile.mUser_ID = @user_ids;
                    IF
                    (
                        SELECT COUNT(*)
                        FROM tblWalletTrans
                        WHERE tblWalletTrans.WalletTrans_UserCode = (@mUser_MobileNo)
                    ) > 0
                        BEGIN
                            SELECT TOP 1 '1' AS 'RETURN_RESULT', 
                                         tblWalletTrans.WalletTrans_ID, 
                                         tblWalletTrans.WalletTrans_Type, 
                                         tblWalletTrans.WalletTrans_MoneyValue, 
                                         ISNULL(
                            (
                                SELECT TOP 1 PointTrans_PointValue
                                FROM tblPointTrans
                                WHERE PointTrans_Code = tblWalletTrans.WalletTrans_Code
                            ), 0) AS 'PointTrans_PointValue', 
                            (
                                SELECT tblUserMobile.mUser_TotalBalance
                                FROM tblUserMobile
                                WHERE tblUserMobile.mUser_ID = @user_ids
                            ) AS 'mUser_TotalBalance', 
                            (
                                SELECT tblUserMobile.mUser_TotalPoint
                                FROM tblUserMobile
                                WHERE tblUserMobile.mUser_ID = @user_ids
                            ) AS 'mUser_TotalPoint'
                            FROM tblWalletTrans
                            WHERE tblWalletTrans.WalletTrans_UserCode =
                            (
                                SELECT mUser_MobileNo
                                FROM tblUserMobile
                                WHERE tblUserMobile.mUser_ID = @user_ids
                            )
                            ORDER BY WalletTrans_ID DESC;
                            SELECT *
                            FROM email
                            WHERE email_deleted = 0
                                  AND email_user_id = @user_ids;
                            SELECT tblCard.Card_SerialNo, 
                                   tblCard.Card_Balance, 
                                   Card_Balance_Cashable, 
                                   Card_Balance_Cashable_No, 
                                   Card_Point, 
                                   Card_level_expired_time, 
                                   tblPlayerLevel.PlayerLevel_Name, 
                                   tblPlayerLevel.PlayerLevel_TierMinMaintainLevel, 
                                   tblPlayerLevel.PlayerLevel_Rate
                            FROM tblCard
                                 JOIN tblPlayerLevel ON tblCard.Card_Level = tblPlayerLevel.PlayerLevel_ID
                            WHERE Card_MobileUser = @mUser_MobileNo
                                  AND Card_Status = 0;
                        END;
                        ELSE
                        BEGIN
                            SELECT TOP 1 '1' AS 'RETURN_RESULT', 
                                         0 AS WalletTrans_ID, 
                                         0 AS WalletTrans_Type, 
                                         0 AS WalletTrans_MoneyValue, 
                                         0 AS 'PointTrans_PointValue', 
                            (
                                SELECT tblUserMobile.mUser_TotalBalance
                                FROM tblUserMobile
                                WHERE tblUserMobile.mUser_ID = @user_ids
                            ) AS 'mUser_TotalBalance', 
                            (
                                SELECT tblUserMobile.mUser_TotalPoint
                                FROM tblUserMobile
                                WHERE tblUserMobile.mUser_ID = @user_ids
                            ) AS 'mUser_TotalPoint';
                            SELECT *
                            FROM email
                            WHERE email_deleted = 0
                                  AND email_user_id = @user_ids;
                            SELECT tblCard.Card_SerialNo, 
                                   tblCard.Card_Balance, 
                                   Card_Balance_Cashable, 
                                   Card_Balance_Cashable_No, 
                                   Card_Point, 
                                   Card_level_expired_time, 
                                   tblPlayerLevel.PlayerLevel_Name, 
                                   tblPlayerLevel.PlayerLevel_TierMinMaintainLevel, 
                                   tblPlayerLevel.PlayerLevel_Rate
                            FROM tblCard
                                 JOIN tblPlayerLevel ON tblCard.Card_Level = tblPlayerLevel.PlayerLevel_ID
                            WHERE Card_MobileUser = @mUser_MobileNo
                                  AND Card_Status = 0;
                        END;
                END;
                ELSE
                BEGIN
                    SELECT '-500' AS 'RETURN_RESULT';
                END;
            COMMIT TRANSACTION;
            SET NOCOUNT OFF;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            SELECT '-98' AS 'RETURN_RESULT';
        END CATCH;
    END;
