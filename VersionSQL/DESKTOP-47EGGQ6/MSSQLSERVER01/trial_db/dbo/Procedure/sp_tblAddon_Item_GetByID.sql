/****** Object:  Procedure [dbo].[sp_tblAddon_Item_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblAddon_Item_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY Addon_ItemCode)  AS RowNo,
				*, 
				(CASE Addon_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Addon_StatusText
				from tblAddon_Item (NOLOCK)
				where Addon_ID  = @intID
END
