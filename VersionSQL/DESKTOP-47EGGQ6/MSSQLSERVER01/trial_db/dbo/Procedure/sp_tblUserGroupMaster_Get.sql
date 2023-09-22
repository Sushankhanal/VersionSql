/****** Object:  Procedure [dbo].[sp_tblUserGroupMaster_Get]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[sp_tblUserGroupMaster_Get] (
@GroupName	nvarchar(50),
@StartRecord INT,
@EndRecord INT,
@IsCount INT
) 
AS
	--DECLARE @strFinanceDB VARCHAR(100), @strSql VARCHAR(1000)
	
BEGIN

	--SELECT @strFinanceDB = FinanceSysDB FROM WMS_Branch NOLOCK WHERE ID = @BranchId
	
IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
		(
			SELECT ROW_NUMBER() OVER(ORDER BY C.UGroup_ID DESC) AS RowNo
				FROM tblUser_GroupMaster C (NOLOCK) 
				WHERE UGroup_Name LIKE '%' + @GroupName + '%'
		)tblA
		--WHERE RowNo BETWEEN @StartRecord AND @EndRecord
	END
ELSE
	BEGIN
	
		SELECT * FROM 
		(
			SELECT ROW_NUMBER() OVER(ORDER BY UGroup_ID DESC) AS RowNo,
			M.*, (CASE WHEN UGroup_Status = 0 THEN 'Active' ELSE 'Inactive' END) as GroupStatus
			FROM tblUser_GroupMaster M (NOLOCK)
			WHERE UGroup_Name LIKE  '%' + @GroupName + '%' 
			
		)tblA
		WHERE RowNo BETWEEN @StartRecord AND @EndRecord
		Order by UGroup_Name
	END

END
