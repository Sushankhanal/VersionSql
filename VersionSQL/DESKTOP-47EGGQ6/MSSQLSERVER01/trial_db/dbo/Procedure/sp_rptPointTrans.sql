/****** Object:  Procedure [dbo].[sp_rptPointTrans]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_rptPointTrans '2019-01-01','2019-12-31',''
CREATE PROCEDURE [dbo].[sp_rptPointTrans] (
	@strDateFrom	datetime,
	@strDateTo		datetime,
	@strUserCode	nvarchar(50)

) AS
BEGIN
	set @strDateTo = DATEADD(day,1,@strDateTo)
	set @strDateTo = DATEADD(second,-1,@strDateTo)

	select ROW_NUMBER() OVER(ORDER BY PointTrans_Code)  AS RowNo ,
	M.mUser_Code, M.mUser_FullName,
	T.PointTrans_ID, T.PointTrans_Code, T.PointTrans_CreatedDate, TT.WTransType_Name, T.PointTrans_Value,
	@strDateFrom as dtDateFrom, @strDateTo as dtDateTo
	from tblPointTrans T
	inner join tblWalletTransType TT on TT.WTransType_ID = T.PointTrans_Type
	inner join tblUserMobile M on T.PointTrans_UserCode = M.mUser_Code
	where T.PointTrans_CreatedDate Between @strDateFrom and @strDateTo
	AND mUser_Code LIKE '%' + @strUserCode + '%'
	Order by PointTrans_CreatedDate, mUser_Code

END
