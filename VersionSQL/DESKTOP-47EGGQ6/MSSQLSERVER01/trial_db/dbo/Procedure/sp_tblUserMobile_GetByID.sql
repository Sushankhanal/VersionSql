/****** Object:  Procedure [dbo].[sp_tblUserMobile_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblUserMobile_GetByID] (
	@intID	bigint,
	@strUserCode		nvarchar(50)

) AS
BEGIN
	Declare @strCompanyCode nvarchar(50)
	select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

	select m.*,
	(CASE mUser_Gender WHEN 0 THEN 'Male' ELSE 'Female' END) as mUser_GenderText
	from tblUserMobile m
	where mUser_ID = @intID
END
