/****** Object:  Procedure [dbo].[sp_GetCreatePlayerDropDownItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec sp_tblProduct_get 'COUNTER1','Hallaway01',''
CREATE PROCEDURE [dbo].[sp_GetCreatePlayerDropDownItem] (
	@strCompanyCode		nvarchar(50)
) AS
BEGIN
	select * from tblCountry Order by Country_Sort

	select * from tblPlayerLevel order by PlayerLevel_Sort

	select * from tblPlayerIDType Order by PlayerIDType_Sort

	select * from tblCardType 

END
