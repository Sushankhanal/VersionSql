/****** Object:  Procedure [dbo].[Wapi_tblCard_Trans_GetByNumber]    Committed by VersionSQL https://www.versionsql.com ******/

--exec sp_tblCard_GetByStatus '','',0,'',0,100,0
Create PROCEDURE [dbo].[Wapi_tblCard_Trans_GetByNumber] (
	@strSerialNumber	nvarchar(50),
	@strUserID			bigint,
	@intPointType		int
) AS
BEGIN
	
	SELECT  ROW_NUMBER() OVER(ORDER BY CardTrans_Date desc)  AS RowNo,
	CardTrans_ID, CardTrans_Code, CardTrans_Date, CardTrans_Type, CardTrans_Value, 
	CardTrans_Remarks, CardTrans_MoneyIn, CardTrans_MoneyOut, CardTrans_Turnover, CardTrans_Won, CardTrans_GamePlayed, CardTrans_PointEarned, 
	CardTrans_HappyHourRate, CardTrans_MemberCardTypeRate, CardTrans_MachineRate, CardTrans_PlayerMultiplier, CardTrans_BaseRate,
	WT.WTransType_Name, PM.PaymentMode_Name
	FROM tblCard_Trans CT (NOLOCK)
	inner join tblWalletTransType WT on CT.CardTrans_Type = WT.WTransType_ID
	inner join tblPaymentMode PM on PM.PaymentMode_ID = CT.CardTrans_PaymentMode
	WHERE (CardTrans_SerialNo = @strSerialNumber)

	SELECT  ROW_NUMBER() OVER(ORDER BY CardPointTrans_CreatedDate desc)  AS RowNo,
	CardPointTrans_ID, CardPointTrans_Code, CardPointTrans_CreatedDate, CardPointTrans_Type, CardPointTrans_Value, 
	CardPointTrans_Remarks, CardPointTrans_MoneyIn, CardPointTrans_MoneyOut, CardPointTrans_Turnover, CardPointTrans_Won, CardPointTrans_GamePlayed, CardPointTrans_PointEarned, 
	CardPointTrans_HappyHourRate, CardPointTrans_MemberCardTypeRate, CardPointTrans_MachineRate, CardPointTrans_PlayerMultiplier, CardPointTrans_BaseRate,
	WT.WTransType_Name
	FROM	tblCardPointTrans CT (NOLOCK)
	inner join tblWalletTransType WT on CT.CardPointTrans_Type = WT.WTransType_ID
	WHERE (CardPointTrans_SerialNo = @strSerialNumber)
	AND CT.CardPointTrans_PointType = @intPointType

END
