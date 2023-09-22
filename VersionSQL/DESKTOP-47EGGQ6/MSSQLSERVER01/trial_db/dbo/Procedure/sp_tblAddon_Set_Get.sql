/****** Object:  Procedure [dbo].[sp_tblAddon_Set_Get]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblAddon_Set_Get] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50),
	@ItemCode		nvarchar(50)
) AS
BEGIN

	select  I.Addon_ItemCode, I.Addon_Desc, Addon_UnitPrice from tblProduct P
	inner join tblAddon_Set S on P.Product_AddonGroup = S.AddOnSet_GroupCode
	inner join tblAddon_Item I on S.AddOnSet_ItemCode = I.Addon_ItemCode
	where Product_ItemCode = @ItemCode
	AND I.Addon_CompanyCode = @CompanyCode
	
END
