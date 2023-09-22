/****** Object:  Procedure [dbo].[sp_Sync_UserMobile]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_UserMobile]
	@strCompanyCode nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @intID = 0
	BEGIN
		Select mUser_ID, mUser_Code from tblUserMobile where mUser_Sync = 0
		AND mUser_CompanyCode = @strCompanyCode
		--AND Product_ItemCode = 'ITEM0002'
	END
	ELSE
	BEGIN
		Select mUser_ID, mUser_Code, mUser_LoginID, mUser_FullName, mUser_MobileNo, mUser_DOB, mUser_Gender, 
		mUser_Address1, mUser_Address2, mUser_City, mUser_Postcode, mUser_State, mUser_TotalBalance, 
		mUser_RegisterDate, mUser_Status, mUser_CompanyCode, mUser_Remarks, mUser_TotalPoint, mUser_randomCode
		from tblUserMobile where mUser_Sync = 0
		AND mUser_CompanyCode = @strCompanyCode
		AND mUser_ID = @intID
	END
    
END
