/****** Object:  Procedure [dbo].[sp_GetMenu_ByUserGroup_ALL]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec sp_GetMenu_ByUserGroup_ALL 30,2
CREATE PROCEDURE [dbo].[sp_GetMenu_ByUserGroup_ALL]
(
	@ParentMenuId INT,
	@UserGroupId BIGINT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @intPageId INT, @strPageName VARCHAR(200), @strPageUrl VARCHAR(200), @strPageDesc VARCHAR(1000)
	DECLARE @intPageOrder INT, @intParentPageId INT, @strPageIcon VARCHAR(500), @blnHasSub BIT
	
	DECLARE @tblHeader TABLE
	(
		PageId INT,
		PageName varchar(200),
		PageUrl varchar(200),
		PageDescription varchar(1000),
		PageIcon varchar(500) NOT NULL,
		PageOrder INT,
		ParentPageId INT,
		HasSub BIT,
		IsProcess INT,
		IsChecked	int
	)
	
	DECLARE @tblMenu TABLE
	(
		PageId INT,
		PageName varchar(200),
		PageUrl varchar(200),
		PageDescription varchar(1000),
		PageIcon varchar(500),
		PageOrder INT,
		ParentPageId INT,
		HasSub BIT,
		IsChecked int
	)
	
	/* Select Header Only */
	INSERT INTO @tblHeader
	SELECT Id, PageName, PageUrl, PageDescription, PageIcon, PageOrder, ParentPageId, HasSub, 0,
	(select COUNT(UGroupD_ID) from tblUser_GroupDetail where UGroupD_GroupID = @UserGroupId AND UGroupD_MenuID = H.ID) 
		FROM tblMenu H (NOLOCK)
		WHERE IsHeader = 1 AND IsActive = 1
	
	
	SELECT TOP 1 @intPageId = PageId, @strPageName = PageName, @strPageUrl = PageUrl, @strPageDesc = PageDescription,
					@strPageIcon = PageIcon, @intPageOrder = PageOrder, @intParentPageId = ParentPageId, @blnHasSub = HasSub 
			FROM @tblHeader WHERE IsProcess = 0 ORDER BY PageOrder
	WHILE @@ROWCOUNT <>0
	BEGIN
		
		INSERT INTO @tblMenu
		SELECT @intPageId, @strPageName, @strPageUrl, @strPageDesc, @strPageIcon, @intPageOrder, @intParentPageId, @blnHasSub,
		(select COUNT(UGroupD_ID) from tblUser_GroupDetail where UGroupD_GroupID = @UserGroupId AND UGroupD_MenuID = @intPageId) 
		
		IF @blnHasSub = 1 
		BEGIN
			INSERT INTO @tblMenu
			SELECT Id, PageName, PageUrl, PageDescription, PageIcon, PageOrder, ParentPageId, HasSub,
			(select COUNT(UGroupD_ID) from tblUser_GroupDetail where UGroupD_GroupID = @UserGroupId AND UGroupD_MenuID = H.ID)  
			FROM tblMenu H (NOLOCK)
				WHERE ParentPageId = @intPageId AND IsActive = 1
				ORDER BY ChildPageOrder
		END
		
		UPDATE @tblHeader SET IsProcess = 1 WHERE PageId = @intPageId
		
		SELECT TOP 1 @intPageId = PageId, @strPageName = PageName, @strPageUrl = PageUrl, @strPageDesc = PageDescription,
					@strPageIcon = PageIcon, @intPageOrder = PageOrder, @blnHasSub = HasSub 
			FROM @tblHeader WHERE IsProcess = 0 ORDER BY PageOrder
	END
	
	SET NOCOUNT OFF
	
	SELECT * FROM @tblMenu WHERE ParentPageId = @ParentMenuId

	select *, UGroup_Name as GroupName from tblUser_GroupMaster where UGroup_ID = @UserGroupId
END
