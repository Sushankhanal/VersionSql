/****** Object:  Procedure [dbo].[sp_tblUserGroupMaster_DeleteById]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblUserGroupMaster_DeleteById] (
@ID INT
) AS

	BEGIN TRANSACTION

	SET NOCOUNT ON
	
	Declare @intCount int = 0
	SELECT @intCount = ISNULL(COUNT(POSUser_ID), 0) FROM tblPOSUser NOLOCK WHERE POSUser_UserGroupID = @ID

	IF @intCount = 0 
	BEGIN
		Delete from tblUser_GroupMaster where UGroup_ID = @ID
		Delete from tblUser_GroupDetail where UGroupD_GroupID = @ID
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN (-2)
	END

	
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
