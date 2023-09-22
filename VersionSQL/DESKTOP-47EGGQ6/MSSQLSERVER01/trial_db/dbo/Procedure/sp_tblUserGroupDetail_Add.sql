/****** Object:  Procedure [dbo].[sp_tblUserGroupDetail_Add]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblUserGroupDetail_Add] (
@ID INT OUT,
@GroupID bigint,
@MenuID	int
) AS

	BEGIN TRANSACTION

	SET NOCOUNT ON

	INSERT INTO [dbo].[tblUser_GroupDetail]
    (UGroupD_GroupID, UGroupD_MenuID)
	VALUES     
	(@GroupID, @MenuID)
	SELECT @ID = @@IDENTITY
	
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
