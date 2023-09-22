/****** Object:  Procedure [dbo].[sp_tblTable_Get]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblTable_Get] (
	@CounterCode	nvarchar(50),
	@CompanyCode	nvarchar(50)
) AS
BEGIN

	select  * from tblTable T
	where Table_CompanyCode = @CompanyCode
	
END
