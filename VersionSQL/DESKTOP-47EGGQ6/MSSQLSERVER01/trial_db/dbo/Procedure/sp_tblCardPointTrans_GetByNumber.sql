/****** Object:  Procedure [dbo].[sp_tblCardPointTrans_GetByNumber]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
CREATE PROCEDURE [dbo].[sp_tblCardPointTrans_GetByNumber] (
	@strSerialNumber	nvarchar(50),
	@strUserCode		nvarchar(50),
	@intPointType		int,
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT

) AS
BEGIN
	
	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
				SELECT  ROW_NUMBER() OVER(ORDER BY CardPointTrans_CreatedDate desc)  AS RowNo
				FROM            tblCardPointTrans CT (NOLOCK)
				inner join tblWalletTransType WT on CT.CardPointTrans_Type = WT.WTransType_ID
				WHERE (CardPointTrans_SerialNo = @strSerialNumber)
				AND CT.CardPointTrans_PointType = @intPointType
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				SELECT  ROW_NUMBER() OVER(ORDER BY CardPointTrans_CreatedDate desc)  AS RowNo,
				CardPointTrans_ID, CardPointTrans_Code, CardPointTrans_CreatedDate, CardPointTrans_Type, CardPointTrans_Value, 
                         CardPointTrans_Remarks, CardPointTrans_MoneyIn, CardPointTrans_MoneyOut, CardPointTrans_Turnover, CardPointTrans_Won, CardPointTrans_GamePlayed, CardPointTrans_PointEarned, 
                         CardPointTrans_HappyHourRate, CardPointTrans_MemberCardTypeRate, CardPointTrans_MachineRate, CardPointTrans_PlayerMultiplier, CardPointTrans_BaseRate,
						 WT.WTransType_Name
				FROM            tblCardPointTrans CT (NOLOCK)
				inner join tblWalletTransType WT on CT.CardPointTrans_Type = WT.WTransType_ID
				WHERE (CardPointTrans_SerialNo = @strSerialNumber)
				AND CT.CardPointTrans_PointType = @intPointType
				
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by CardPointTrans_CreatedDate desc
	END

	select * from tblCard where Card_SerialNo = @strSerialNumber
END
