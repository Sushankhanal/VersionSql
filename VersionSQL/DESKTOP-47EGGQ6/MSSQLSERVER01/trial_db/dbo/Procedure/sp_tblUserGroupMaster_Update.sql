/****** Object:  Procedure [dbo].[sp_tblUserGroupMaster_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec agsp_WMS_UserGroupMaster_Add 0,0,'aaa',0,'1','2019-12-08','1','2019-12-08'
CREATE PROCEDURE [dbo].[sp_tblUserGroupMaster_Update] (
@ID INT,
@GroupName	nvarchar(50),
@GroupStatus	int,
@CreatedUserId NVARCHAR(100)
) AS

	BEGIN TRANSACTION

	SET NOCOUNT ON

	DECLARE @intCount INT
	SELECT @intCount = ISNULL(COUNT(UGroup_ID), 0) FROM tblUser_GroupMaster NOLOCK 
		WHERE UGroup_Name = @GroupName and UGroup_ID <> @ID

		IF @intCount = 0 
		BEGIN
		
			Update tblUser_GroupMaster set UGroup_Name = @GroupName ,
			UGroup_ModifiedBy = @CreatedUserId, UGroup_ModifiedDate = GETDATE()
			where UGroup_ID = @ID

			delete from tblUser_GroupDetail where UGroupD_GroupID = @ID

			SELECT @ID = @ID
			--SELECT @ID = @@IDENTITY
		END
		ELSE
		BEGIN
			SELECT @ID = -1
		END

	
	

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
