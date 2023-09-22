﻿/****** Object:  Procedure [dbo].[tblCard_selectchanges_b601511a-482f-45e3-8471-65787917ef61]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[tblCard_selectchanges_b601511a-482f-45e3-8471-65787917ef61]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@sync_scope_restore_count Int,
	@sync_update_peer_key Int
AS
BEGIN
SELECT [side].[Card_ID], [base].[Card_SerialNo], [base].[Card_Status], [base].[Card_MobileUser], [base].[Card_Balance], [base].[Card_CreatedBy], [base].[Card_CreatedDate], [base].[Card_Point], [base].[Card_CompanyCode], [base].[Card_CardOwner_ID], [base].[Card_Sync], [base].[Card_SyncDate], [base].[Card_Type], [base].[tblCard_pin], [base].[Card_Balance_Cashable_No], [base].[Card_Balance_Cashable], [base].[Card_PointAccumulate], [base].[Card_isPinReset], [base].[Card_Point_Tier], [base].[Card_Point_Hidden], [base].[Card_isAbleToUpgrade], [base].[Card_Level], [base].[Card_last_up_gradetime], [base].[Card_tier_last_reset_time], [base].[Card_level_expired_time], [base].[Card_last_down_gradetime], [base].[Card_img], [base].[Card_PrintDate], [base].[Card_Expiry_Cashable_No], [base].[Card_Expiry_Cashable], [base].[Card_balance_Edit_DateTime], [base].[Card_without_sync], [side].[sync_row_is_tombstone], [side].[local_update_peer_timestamp] as sync_row_timestamp, case when ([side].[update_scope_local_id] is null or [side].[update_scope_local_id] <> @sync_scope_local_id) then COALESCE([side].[restore_timestamp], [side].[local_update_peer_timestamp]) else [side].[scope_update_peer_timestamp] end as sync_update_peer_timestamp, case when ([side].[update_scope_local_id] is null or [side].[update_scope_local_id] <> @sync_scope_local_id) then case when ([side].[local_update_peer_key] > @sync_scope_restore_count) then @sync_scope_restore_count else [side].[local_update_peer_key] end else [side].[scope_update_peer_key] end as sync_update_peer_key, case when ([side].[create_scope_local_id] is null or [side].[create_scope_local_id] <> @sync_scope_local_id) then [side].[local_create_peer_timestamp] else [side].[scope_create_peer_timestamp] end as sync_create_peer_timestamp, case when ([side].[create_scope_local_id] is null or [side].[create_scope_local_id] <> @sync_scope_local_id) then case when ([side].[local_create_peer_key] > @sync_scope_restore_count) then @sync_scope_restore_count else [side].[local_create_peer_key] end else [side].[scope_create_peer_key] end as sync_create_peer_key FROM [tblCard] [base] RIGHT JOIN [tblCard_tracking] [side] ON [base].[Card_ID] = [side].[Card_ID] WHERE  ([side].[update_scope_local_id] IS NULL OR [side].[update_scope_local_id] <> @sync_scope_local_id OR ([side].[update_scope_local_id] = @sync_scope_local_id AND [side].[scope_update_peer_key] <> @sync_update_peer_key)) AND [side].[local_update_peer_timestamp] > @sync_min_timestamp
END