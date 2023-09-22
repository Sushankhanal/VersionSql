/****** Object:  Procedure [dbo].[sp_tblUserGroupMaster_Add]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblUserGroupMaster_Add] (
@ID INT OUT,
@GroupName	nvarchar(50),
@GroupStatus	int,
@CreatedUserId NVARCHAR(100)
) AS

	BEGIN TRANSACTION

	SET NOCOUNT ON

	DECLARE @intCount INT
	
	SELECT @intCount = ISNULL(COUNT(UGroup_ID), 0) FROM tblUser_GroupMaster NOLOCK 
		WHERE UGroup_Name = @GroupName

		IF @intCount = 0 
		BEGIN
		
			INSERT INTO tblUser_GroupMaster
			(UGroup_Name, UGroup_Status, UGroup_CreatedBy, UGroup_CreatedDate)
			VALUES
			(@GroupName, @GroupStatus,@CreatedUserId, GETDATE())
		
			SELECT @ID = @@IDENTITY
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
