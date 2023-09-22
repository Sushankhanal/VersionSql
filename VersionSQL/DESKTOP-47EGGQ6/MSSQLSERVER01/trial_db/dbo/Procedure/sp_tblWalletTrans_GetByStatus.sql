/****** Object:  Procedure [dbo].[sp_tblWalletTrans_GetByStatus]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblProductCategory_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblWalletTrans_GetByStatus] (
	@strCode	nvarchar(50),
	@strName	nvarchar(50),
	@strClientID	bigint,
	@strUserCode		nvarchar(50),
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT

) AS
BEGIN
	Declare @strCompanyCode nvarchar(50)
	Declare @strClientUserCode nvarchar(50)
	Declare @strClientFullname nvarchar(50)
	select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode
	select @strClientUserCode = mUser_Code, @strClientFullname = mUser_FullName  from tblUserMobile where mUser_ID = @strClientID
	
	

	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
					select ROW_NUMBER() OVER(ORDER BY WalletTrans_Code)  AS RowNo 
					from tblWalletTrans T
					inner join tblWalletTransType TT on TT.WTransType_ID = T.WalletTrans_Type
					where WalletTrans_UserCode = @strClientUserCode
			)tblA
	END
	ELSE
	BEGIN
		SELECT * FROM 
		(
			select ROW_NUMBER() OVER(ORDER BY WalletTrans_Code)  AS RowNo ,
			@strClientUserCode as mUser_Code, @strClientFullname as mUser_FullName,
			T.WalletTrans_ID, T.WalletTrans_Code, T.WalletTrans_CreatedDate, TT.WTransType_Name, T.WalletTrans_Value from tblWalletTrans T
			inner join tblWalletTransType TT on TT.WTransType_ID = T.WalletTrans_Type
			where WalletTrans_UserCode = @strClientUserCode
			--Order by T.WalletTrans_CreatedDate desc
		)tblA
		WHERE RowNo BETWEEN @StartRecord AND @EndRecord
		Order by WalletTrans_CreatedDate
	END
END
