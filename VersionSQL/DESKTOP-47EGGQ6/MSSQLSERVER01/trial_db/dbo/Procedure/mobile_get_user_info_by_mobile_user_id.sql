/****** Object:  Procedure [dbo].[mobile_get_user_info_by_mobile_user_id]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_get_user_info_by_mobile_user_id]


	@mobile_user_id nvarchar(50),
	@machine_id BIGINT

AS
BEGIN
	--BEGIN TRANSACTION
	BEGIN TRY  

		SELECT        
			0 as card_sn,
			tblUserMobile.mUser_ID as 'user_id', 
			tblUserMobile.mUser_FullName as 'user_name', 
			tblUserMobile.mUser_TotalBalance as 'balance', 
			tblUserMobile.mUser_TotalPoint as 'point' ,
			tblUserMobile.mUser_mobileNo as 'mobile',
			CONVERT(decimal(18,8),0) as rate,
			1 AS card_rate,
			'Gold' AS  MemberCard_type,
			1 AS Member_type,
			'Gold' AS Member_rate,
			0 as happy_hour_rate,
			'1990-01-01 00:00:00' as happy_hour_start,
			'1990-01-01 00:00:00' as happy_hour_end,
			0 AS non_restricted_promotional,
			0 AS  restricted_promotional
		
			FROM  tblUserMobile 
			WHERE (tblUserMobile.mUser_ID = @mobile_user_id)
		
		--COMMIT TRANSACTION
		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		--ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
