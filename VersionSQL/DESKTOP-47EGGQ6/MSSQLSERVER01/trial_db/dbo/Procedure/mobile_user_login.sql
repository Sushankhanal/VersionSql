/****** Object:  Procedure [dbo].[mobile_user_login]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_user_login] @mobileNo AS NVARCHAR(50), 
                                          @password AS NVARCHAR(MAX)
AS
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            DECLARE @mobile_user_id BIGINT= 0, @session_key NVARCHAR(MAX);
            SELECT @mobile_user_id = mUser_ID
            FROM tblUserMobile
            WHERE mUser_MobileNo = @mobileNo
                  AND PWDCOMPARE(@password, mUser_Password) = 1
                  AND mUser_Status = 1;
            IF @mobile_user_id <> 0
                BEGIN
                    SET @session_key = CONVERT(VARCHAR(1000), RIGHT(NEWID(), 30)) + CONVERT(VARCHAR, DATEDIFF(s, '1970-01-01', GETUTCDATE()), 121) + CONVERT(VARCHAR(1000), RIGHT(NEWID(), 30)) + CONVERT(VARCHAR, DATEDIFF(s, '1970-01-01', GETUTCDATE()), 121) + CONVERT(VARCHAR(1000), RIGHT(NEWID(), 30)) + CONVERT(VARCHAR, DATEDIFF(s, '1970-01-01', GETUTCDATE()), 121);
                    PRINT @session_key;
                    INSERT INTO session
                    (session_key, 
                     session_user_id, 
                     session_createdon, 
                     session_card_serial_no
                    )
                           SELECT @session_key, 
                                  @mobile_user_id, 
                                  GETDATE(), 
                                  tblCard.Card_SerialNo
                           FROM tblCard
                                JOIN tblPlayerLevel ON tblCard.Card_Level = tblPlayerLevel.PlayerLevel_ID
                           WHERE Card_MobileUser = @mobileNo
                                 AND Card_Status = 0;
                    IF @@ROWCOUNT > 0
                        BEGIN
                            SELECT
                            (
                                SELECT TOP 1 WalletTrans_ID
                                FROM tblWalletTrans
                                WHERE tblWalletTrans.WalletTrans_UserCode = mUser_MobileNo
                                ORDER BY tblWalletTrans.WalletTrans_ID DESC
                            ) AS 'WalletTrans_ID', 
                            mUser_ID, 
                            mUser_Code, 
                            mUser_LoginID, 
                            mUser_Password, 
                            mUser_FullName, 
                            mUser_MobileNo, 
                            0 AS enableCurrency, 
                            'RM' AS currency, 
                            CONVERT(VARCHAR, mUser_DOB, 106) AS mUser_DOB, 
                            mUser_Gender, 
                            mUser_Address1, 
                            mUser_Address2, 
                            mUser_City, 
                            mUser_Postcode, 
                            mUser_State, 
                            mUser_TotalBalance, 
                            mUser_RegisterDate, 
                            mUser_Status, 
                            mUser_CompanyCode, 
                            mUser_Remarks, 
                            mUser_TotalPoint, 
                            @session_key AS 'session_key', 
                            '1' AS 'RETURN_RESULT'
                            FROM tblUserMobile
                            WHERE(mUser_MobileNo = @mobileNo)
                                 AND (PWDCOMPARE(@password, mUser_Password) = 1)
                                 AND (mUser_Status = 1);
                            SELECT *
                            FROM email
                            WHERE email_deleted = 0
                                  AND email_user_id = @mobile_user_id;
                            SELECT tblCard.Card_SerialNo, 
                                   tblCard.Card_Balance, 
                                   tblCard.Card_CreatedDate AS member_date, 
                                   Card_Balance_Cashable, 
                                   Card_Balance_Cashable_No, 
                                   Card_Point, 
                                   Card_level_expired_time, 
                                   tblPlayerLevel.PlayerLevel_Name, 
                                   tblPlayerLevel.PlayerLevel_TierMinMaintainLevel, 
                                   tblPlayerLevel.PlayerLevel_Rate
                            FROM tblCard
                                 JOIN tblPlayerLevel ON tblCard.Card_Level = tblPlayerLevel.PlayerLevel_ID
                            WHERE Card_MobileUser = @mobileNo
                                  AND Card_Status = 0;
                        END;
                        ELSE
                        BEGIN
                            SELECT '-1' AS 'RETURN_RESULT';
                        END;
                END;
                ELSE
                BEGIN
                    SELECT '-2' AS 'RETURN_RESULT';
                END;
            COMMIT TRANSACTION;
            SET NOCOUNT OFF;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            SELECT '-98' AS 'RETURN_RESULT';
        END CATCH;
    END;
