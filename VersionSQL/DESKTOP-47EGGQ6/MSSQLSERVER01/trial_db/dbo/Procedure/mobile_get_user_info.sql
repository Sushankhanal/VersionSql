/****** Object:  Procedure [dbo].[mobile_get_user_info]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[mobile_get_user_info]


	@card_sn nvarchar(50),
	@machine_id BIGINT

AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY  

		IF(SELECT COUNT(*) FROM tblUserMobile JOIN tblCard ON Card_MobileUser = mUser_Code WHERE Card_SerialNo = @card_sn) > 0
		BEGIN
		PRINT 'asdasdsa'
			SELECT        
			@card_sn as card_sn,
			tblUserMobile.mUser_ID as 'user_id', 
			tblUserMobile.mUser_FullName as 'user_name', 
			tblUserMobile.mUser_TotalBalance as 'balance', 
			tblUserMobile.mUser_TotalPoint as 'point' ,
			tblUserMobile.mUser_mobileNo as 'mobile',
			CONVERT(decimal(18,8),0) as rate,
			(SELECT tblCardType.CardType_Rate FROM tblCardType JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID WHERE tblCard.Card_SerialNo = @card_sn) AS card_rate,
			(SELECT tblCardType.CardType_Name FROM tblCardType JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID WHERE tblCard.Card_SerialNo = @card_sn) AS  MemberCard_type,
			(SELECT tblPlayerLevel.PlayerLevel_Name FROM tblCard JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = CardOwner_Level WHERE tblCard.Card_SerialNo = @card_sn) AS Member_type,
			(SELECT tblPlayerLevel.PlayerLevel_Rate FROM tblCard JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = CardOwner_Level WHERE tblCard.Card_SerialNo = @card_sn) AS Member_rate,
			ISNULL((SELECT top 1 Campaign_Rate FROM tblCampaign_Point WHERE tblCampaign_Point.Campaign_MachineID = @machine_id),1) as happy_hour_rate,
			ISNULL((SELECT top 1 Campaign_StartDate FROM tblCampaign_Point WHERE tblCampaign_Point.Campaign_MachineID = @machine_id),'1990-01-01 00:00:00') as happy_hour_start,
			ISNULL((SELECT top 1 Campaign_EndDate FROM tblCampaign_Point WHERE tblCampaign_Point.Campaign_MachineID = @machine_id),'1990-01-01 00:00:00') as happy_hour_end,
			(SELECT tblCard.Card_Balance_Cashable  FROM tblCardType JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID WHERE tblCard.Card_SerialNo = @card_sn) AS non_restricted_promotional,
			(SELECT tblCard.Card_Balance_Cashable_No FROM tblCardType JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID WHERE tblCard.Card_SerialNo = @card_sn) AS  restricted_promotional
		
			FROM  tblUserMobile INNER JOIN
			tblCard ON tblCard.Card_MobileUser = tblUserMobile.mUser_Code
			WHERE (tblCard.Card_SerialNo = @card_sn)
		END
		ELSE
		BEGIN
			SELECT      
			@card_sn as card_sn, 
			0 as 'user_id', 
			tblCardOwner.CardOwner_Name as 'user_name', 
			tblCardOwner.CardOwner_MobileNumber as 'mobile',
			Card_Balance  as 'balance',
			Card_Point as 'point',
			CONVERT(decimal(18,8),0) as rate,
			(SELECT tblCardType.CardType_Rate FROM tblCardType JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID WHERE tblCard.Card_SerialNo = @card_sn) AS card_rate,
			(SELECT tblCardType.CardType_Name FROM tblCardType JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID WHERE tblCard.Card_SerialNo = @card_sn) AS  MemberCard_type,
			(SELECT tblPlayerLevel.PlayerLevel_Name FROM tblCard JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = CardOwner_Level WHERE tblCard.Card_SerialNo = @card_sn) AS Member_type,
			(SELECT tblPlayerLevel.PlayerLevel_Rate FROM tblCard JOIN tblCardOwner ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID JOIN tblPlayerLevel ON tblPlayerLevel.PlayerLevel_ID = CardOwner_Level WHERE tblCard.Card_SerialNo = @card_sn) AS Member_rate,
			ISNULL((SELECT top 1 Campaign_Rate FROM tblCampaign_Point WHERE tblCampaign_Point.Campaign_MachineID = @machine_id),1) as happy_hour_rate,
			ISNULL((SELECT top 1 Campaign_StartDate FROM tblCampaign_Point WHERE tblCampaign_Point.Campaign_MachineID = @machine_id),'1990-01-01 00:00:00') as happy_hour_start,
			ISNULL((SELECT top 1 Campaign_EndDate FROM tblCampaign_Point WHERE tblCampaign_Point.Campaign_MachineID = @machine_id),'1990-01-01 00:00:00') as happy_hour_end,
			(SELECT tblCard.Card_Balance_Cashable  FROM tblCardType JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID WHERE tblCard.Card_SerialNo = @card_sn) AS non_restricted_promotional,
			(SELECT tblCard.Card_Balance_Cashable_No FROM tblCardType JOIN tblCard ON tblCard.Card_Type = tblCardType.CardType_ID WHERE tblCard.Card_SerialNo = @card_sn) AS  restricted_promotional
		
			FROM tblCardOwner 
			INNER JOIN tblCard ON tblCard.Card_CardOwner_ID = tblCardOwner.CardOwner_ID
			WHERE  (tblCard.Card_SerialNo = @card_sn)
		END
		
		COMMIT TRANSACTION
		SET NOCOUNT OFF
	END TRY  

	BEGIN CATCH  
		ROLLBACK TRANSACTION
		SELECT '-98' AS 'RETURN_RESULT'
	END CATCH

END
