/****** Object:  Procedure [dbo].[sp_tblCompany_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblCompany_GetByStatus] (
	@strCompanyCode     nvarchar(50)
) AS
BEGIN

	select * from tblCompany (NOLOCK)
	where Company_Code LIKE '%' + @strCompanyCode + '%' 
END
