/****** Object:  Procedure [dbo].[mobile_transaction_load]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_transaction_load]


	@mobileNo as nvarchar(50),
	@transId as BIGINT,
	@user_id as bigint,
	@session_key as nvarchar(2048)

AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  

	IF @transId <> 0
	BEGIN

		SELECT 
		TOP (20) 
		(CASE 
		WHEN tblWalletTransType.WTransType_Sign > 0 THEN '+' ELSE '-' END) AS 'Sign',
		tblWalletTrans.WalletTrans_ID, 
		tblWalletTrans.WalletTrans_Code, 
		tblWalletTrans.WalletTrans_UserCode, 
		tblWalletTrans.WalletTrans_WalletCode, 
		tblWalletTrans.WalletTrans_Type, 
        tblWalletTrans.WalletTrans_Value, 
		tblWalletTrans.WalletTrans_MoneyValue, 
		CASE WHEN tblWalletTrans.WalletTrans_RefCode IS NULL THEN '' ELSE tblWalletTrans.WalletTrans_RefCode END AS WalletTrans_RefCode, 
		tblWalletTrans.WalletTrans_Remarks,
		tblWalletTrans.WalletTrans_CreatedBy, 
		convert(varchar, tblWalletTrans.WalletTrans_CreatedDate, 120)
                         as WalletTrans_CreatedDate, 
						 tblWalletTrans.WalletTrans_CampaignCode, tblWalletTrans.WalletTrans_PaymentMode, tblWalletTransType.WTransType_Name, tblWalletTransType.WTransType_Sign, 
                         tblUserMobile.mUser_ID, tblUserMobile.mUser_Code, tblUserMobile.mUser_FullName, tblUserMobile.mUser_MobileNo, tblUserMobile.mUser_Gender
		
		
		FROM tblWalletTrans 
		JOIN tblWalletTransType ON WalletTrans_Type = WTransType_ID 
		JOIN tblUserMobile ON mUser_Code = WalletTrans_UserCode AND mUser_ID = @user_id
		WHERE WalletTrans_UserCode = @mobileNo
		AND @transId > WalletTrans_ID 
		AND
		(SELECT COUNT(*) FROM [session] WHERE session_key = @session_key AND session_user_id = @user_id) > 0
		ORDER BY WalletTrans_ID DESC 

	END
	ELSE
	BEGIN

		SELECT 
		TOP (20) 
		CASE
		WHEN tblWalletTransType.WTransType_Sign > 0 THEN '+' ELSE '-' END AS 'Sign',
		tblWalletTrans.WalletTrans_ID, 
		tblWalletTrans.WalletTrans_Code, 
		tblWalletTrans.WalletTrans_UserCode, 
		tblWalletTrans.WalletTrans_WalletCode, 
		tblWalletTrans.WalletTrans_Type, 
        tblWalletTrans.WalletTrans_Value, 
		tblWalletTrans.WalletTrans_MoneyValue, 
			CASE WHEN tblWalletTrans.WalletTrans_RefCode IS NULL THEN '' ELSE tblWalletTrans.WalletTrans_RefCode END AS WalletTrans_RefCode, 
	
		tblWalletTrans.WalletTrans_Remarks,
		tblWalletTrans.WalletTrans_CreatedBy, 
                         convert(varchar, tblWalletTrans.WalletTrans_CreatedDate, 120)
                         as WalletTrans_CreatedDate, 
						 tblWalletTrans.WalletTrans_CampaignCode, tblWalletTrans.WalletTrans_PaymentMode, tblWalletTransType.WTransType_Name, tblWalletTransType.WTransType_Sign, 
                         tblUserMobile.mUser_ID, tblUserMobile.mUser_Code, tblUserMobile.mUser_FullName, tblUserMobile.mUser_MobileNo, tblUserMobile.mUser_Gender
		
		
		FROM tblWalletTrans 
		JOIN tblWalletTransType ON WalletTrans_Type = WTransType_ID 
		JOIN tblUserMobile ON mUser_Code = WalletTrans_UserCode AND mUser_ID = @user_id
		WHERE WalletTrans_UserCode = @mobileNo
		AND
		(SELECT COUNT(*) FROM [session] WHERE session_key = @session_key AND session_user_id = @user_id) > 0
		ORDER BY WalletTrans_ID DESC 
	END
		
		COMMIT TRANSACTION
		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
