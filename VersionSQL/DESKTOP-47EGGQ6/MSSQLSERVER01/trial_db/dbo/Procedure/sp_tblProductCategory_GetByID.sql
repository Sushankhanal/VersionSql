/****** Object:  Procedure [dbo].[sp_tblProductCategory_GetByID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblProductCategory_GetByID] (
	@intID	bigint,
	@strUserCode	nvarchar(50)
) AS
BEGIN
	select ROW_NUMBER() OVER(ORDER BY ProCategory_Code)  AS RowNo,
				*, 
				(CASE ProCategory_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as ProCategory_StatusText
				from tblProductCategory (NOLOCK)
				where ProCategory_ID  = @intID
END
