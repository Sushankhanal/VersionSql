/****** Object:  Procedure [dbo].[sp_tblPOSUser_Login]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblPOSUser_Login] (
@UserLogin nvarchar(50),
@UserPassword nvarchar(50),
@UserType		smallint
) AS

	SET NOCOUNT ON

	select P.*, C.Company_Name, C.Company_Img, C.Company_Theme  from tblPOSUser P
	inner join tblCompany C on P.POSUser_CompanyCode = C.Company_Code
	where POSUser_LoginID = @UserLogin and POSUser_Password = @UserPassword
	and POSUser_UserType = @UserType


	SET NOCOUNT OFF
