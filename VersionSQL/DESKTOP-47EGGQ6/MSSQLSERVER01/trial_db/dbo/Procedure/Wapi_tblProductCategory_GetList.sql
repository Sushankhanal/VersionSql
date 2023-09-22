/****** Object:  Procedure [dbo].[Wapi_tblProductCategory_GetList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
Create PROCEDURE [dbo].[Wapi_tblProductCategory_GetList] (
	@intCategoryID	bigint = -1
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY ProCategory_Code)  AS RowNo,
				*, 
				(CASE ProCategory_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as ProCategory_StatusText
				from tblProductCategory (NOLOCK)
				where (CASE WHEN @intCategoryID = -1 THEN 1 ELSE CASE WHEN ProCategory_ID = @intCategoryID THEN 1 ELSE 0 END END) > 0

END
