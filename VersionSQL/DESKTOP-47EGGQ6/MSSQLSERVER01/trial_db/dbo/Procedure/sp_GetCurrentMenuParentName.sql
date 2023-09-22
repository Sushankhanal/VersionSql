/****** Object:  Procedure [dbo].[sp_GetCurrentMenuParentName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_GetCurrentMenuParentName]
(@PageUrl VARCHAR(200))
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @intParentPageId INT
	
	SELECT @intParentPageId = ParentPageId FROM tblMenu NOLOCK WHERE PageUrl LIKE '' + @PageUrl + '%'
	--LIKE '%' + @PageUrl + '%'
	
	IF @intParentPageId > 0
		SELECT PageName FROM tblMenu NOLOCK WHERE ID = @intParentPageId
	ELSE
		SELECT PageName FROM tblMenu NOLOCK WHERE PageUrl = @PageUrl
	
	SET NOCOUNT OFF
END
