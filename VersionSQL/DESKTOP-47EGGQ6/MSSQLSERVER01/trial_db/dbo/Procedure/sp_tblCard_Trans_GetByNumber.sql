/****** Object:  Procedure [dbo].[sp_tblCard_Trans_GetByNumber]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
Create PROCEDURE [dbo].[sp_tblCard_Trans_GetByNumber] (
	@strSerialNumber	nvarchar(50),
	@strUserCode		nvarchar(50),
	@StartRecord INT,
	@EndRecord INT,
	@IsCount INT

) AS
BEGIN
	
	IF @IsCount = 1 
	BEGIN
		SELECT COUNT(RowNo) AS intRowCount FROM
			(
				SELECT  ROW_NUMBER() OVER(ORDER BY CardTrans_Date desc)  AS RowNo
				FROM            tblCard_Trans CT (NOLOCK)
				inner join tblWalletTransType WT on CT.CardTrans_Type = WT.WTransType_ID
				inner join tblPaymentMode PM on PM.PaymentMode_ID = CT.CardTrans_PaymentMode
				WHERE (CardTrans_SerialNo = @strSerialNumber)
			)tblA
	END
ELSE
	BEGIN
		SELECT * FROM 
			(
				SELECT  ROW_NUMBER() OVER(ORDER BY CardTrans_Date desc)  AS RowNo,
				CardTrans_ID, CardTrans_Code, CardTrans_Date, CardTrans_Type, CardTrans_Value, 
                         CardTrans_Remarks, CardTrans_MoneyIn, CardTrans_MoneyOut, CardTrans_Turnover, CardTrans_Won, CardTrans_GamePlayed, CardTrans_PointEarned, 
                         CardTrans_HappyHourRate, CardTrans_MemberCardTypeRate, CardTrans_MachineRate, CardTrans_PlayerMultiplier, CardTrans_BaseRate,
						 WT.WTransType_Name, PM.PaymentMode_Name
				FROM            tblCard_Trans CT (NOLOCK)
				inner join tblWalletTransType WT on CT.CardTrans_Type = WT.WTransType_ID
				inner join tblPaymentMode PM on PM.PaymentMode_ID = CT.CardTrans_PaymentMode
				WHERE (CardTrans_SerialNo = @strSerialNumber)
				
			)tblA
			WHERE RowNo BETWEEN @StartRecord AND @EndRecord
			Order by CardTrans_Date desc
	END

	select * from tblCard where Card_SerialNo = @strSerialNumber
END
