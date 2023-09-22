/****** Object:  Procedure [dbo].[Wapi_tblCountry_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

Create PROCEDURE [dbo].[Wapi_tblCountry_GetList] (
	@intCountryID	bigint = -1
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY Country_Sort)  AS RowNo, *
	from tblCountry P (NOLOCK)
	where (CASE WHEN @intCountryID = -1 THEN 1 ELSE CASE WHEN Country_ID = @intCountryID THEN 1 ELSE 0 END END) > 0
	Order by Country_Sort

END
