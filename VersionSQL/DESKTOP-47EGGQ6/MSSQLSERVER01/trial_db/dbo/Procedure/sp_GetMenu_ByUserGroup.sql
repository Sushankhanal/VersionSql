/****** Object:  Procedure [dbo].[sp_GetMenu_ByUserGroup]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec sp_GetMenu_ByUserGroup 0,1
CREATE PROCEDURE [dbo].[sp_GetMenu_ByUserGroup]
(
	@ParentMenuId INT,
	@UserGroupId BIGINT
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
		IsProcess INT
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
		HasSub BIT
	)
	
	/* Select Header Only */
	if @UserGroupId = 0
	BEGIN
		INSERT INTO @tblHeader
		SELECT Id, PageName, PageUrl, PageDescription, PageIcon, PageOrder, ParentPageId, HasSub, 0
			FROM tblMenu NOLOCK
			WHERE IsHeader = 1 AND IsActive = 1
	END
	ELSE
	BEGIN
		INSERT INTO @tblHeader
		SELECT Id, PageName, PageUrl, PageDescription, PageIcon, PageOrder, ParentPageId, HasSub, 0
			FROM tblMenu NOLOCK
			WHERE IsHeader = 1 AND IsActive = 1
			AND Id in
			(select ParentPageId from tblUser_GroupDetail d
			inner join tblMenu m on d.UGroupD_MenuID = m.ID
			where UGroupD_GroupID = @UserGroupId
			Group by ParentPageId
			UNION
			select m.ID as MenuID from tblUser_GroupDetail d
			inner join tblMenu m on d.UGroupD_MenuID = m.ID
			where UGroupD_GroupID = 1
			Group by m.ID
			)
	END
	--select * from @tblHeader

	SELECT TOP 1 @intPageId = PageId, @strPageName = PageName, @strPageUrl = PageUrl, @strPageDesc = PageDescription,
					@strPageIcon = PageIcon, @intPageOrder = PageOrder, @intParentPageId = ParentPageId, @blnHasSub = HasSub 
			FROM @tblHeader WHERE IsProcess = 0 ORDER BY PageOrder
	WHILE @@ROWCOUNT <>0
	BEGIN
		
		INSERT INTO @tblMenu
		SELECT @intPageId, @strPageName, @strPageUrl, @strPageDesc, @strPageIcon, @intPageOrder, @intParentPageId, @blnHasSub
		
		IF @blnHasSub = 1 
		BEGIN
			if @UserGroupId = 0
			BEGIN
				INSERT INTO @tblMenu
				select m.Id, m.PageName, m.PageUrl, m.PageDescription, m.PageIcon, m.ChildPageOrder, m.ParentPageId, m.HasSub
				from tblMenu m WHERE
				m.ParentPageId = @intPageId AND m.IsActive = 1
				ORDER BY m.ChildPageOrder
			END
			ELSE
			BEGIN
				INSERT INTO @tblMenu
				select m.Id, m.PageName, m.PageUrl, m.PageDescription, m.PageIcon, m.ChildPageOrder, m.ParentPageId, m.HasSub
				from tblUser_GroupDetail d
				inner join tblMenu m on d.UGroupD_MenuID = m.ID
				where d.UGroupD_GroupID = @UserGroupId and 
				m.ParentPageId = @intPageId AND m.IsActive = 1
				ORDER BY m.ChildPageOrder
			END
			

			

		END
		

		UPDATE @tblHeader SET IsProcess = 1 WHERE PageId = @intPageId
		
		SELECT TOP 1 @intPageId = PageId, @strPageName = PageName, @strPageUrl = PageUrl, @strPageDesc = PageDescription,
					@strPageIcon = PageIcon, @intPageOrder = PageOrder, @blnHasSub = HasSub 
			FROM @tblHeader WHERE IsProcess = 0 ORDER BY PageOrder
	END
	
	SET NOCOUNT OFF
	
	SELECT * FROM @tblMenu WHERE ParentPageId = @ParentMenuId 
	Order by PageOrder
END
