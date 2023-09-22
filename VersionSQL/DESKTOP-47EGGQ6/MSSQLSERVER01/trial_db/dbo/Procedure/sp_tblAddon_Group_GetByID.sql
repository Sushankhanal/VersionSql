/****** Object:  Procedure [dbo].[sp_tblAddon_Group_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblAddon_Group_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN
	Declare @strAddOnGroupCode nvarchar(50)
	select @strAddOnGroupCode = AddonGroup_Code from tblAddon_Group where AddonGroup_ID  = @intID

	select ROW_NUMBER() OVER(ORDER BY AddonGroup_Code)  AS RowNo,
	*, 
	(CASE AddonGroup_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as AddonGroup_StatusText
	from tblAddon_Group (NOLOCK)
	where AddonGroup_ID  = @intID

	select S.*, I.Addon_ID as AddOnSet_ItemID from tblAddon_Set S
	inner join tblAddon_Item I on S.AddOnSet_ItemCode = I.Addon_ItemCode
	where AddOnSet_GroupCode = @strAddOnGroupCode
END
