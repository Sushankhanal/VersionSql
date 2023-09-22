/****** Object:  Procedure [dbo].[Wapi_rptPlayerPointRedemptioneReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptDailySales '2019-02-01','2019-02-28',-1
CREATE PROCEDURE [dbo].[Wapi_rptPlayerPointRedemptioneReport]
	-- Add the parameters for the stored procedure here
	@strDateFrom	datetime,
	@strDateTo		datetime,
	@strLocationID	int = -1 -- -1: all, 0: EGM, 1: POS Counter
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--Player name, card no, redemption point, redemption item, redemption item extra info, redemption datetime, redemption location(machine (machine name), pos) 

	--select ROW_NUMBER() OVER(ORDER BY CO.CardOwner_Name)  AS RowNo,
	--CO.CardOwner_Name as PlayerName, C.Card_SerialNo as CardNumber, 
	--C.Card_Balance as RedeemPoint, '' as RedeemItem,
	--'' as RedeemExtraInfo, GETDATE() as RedeemDate, '' as RedeemLocation
	--from  tblCard C (NOLOCK)
	--inner join tblCardOwner CO (NOLOCK) on C.Card_CardOwner_ID = CO.CardOwner_ID
	--inner join tblCardType CT (NOLOCK) on CT.CardType_ID = C.Card_Type
	--where CO.CardOwner_Name <> ''
	--AND (CASE WHEN @intCardTypeID = -1 THEN 1 ELSE CASE WHEN CT.CardType_ID = @intCardTypeID THEN 1 ELSE 0 END END) > 0

	if @strLocationID = -1
	BEGIN
		select 0 AS RowNo, CO.CardOwner_Name as PlayerName, C.Card_SerialNo as CardNumber,
		CT.CardPointTrans_PointValue as RedeemPoint, 
		P.Product_Desc as RedeemItem, '' as RedeemExtraInfo,
		H.Payment_CreatedDate as RedeemDate, CR.Counter_Name as RedeemLocation
		from tblPayment_Header H (NOLOCK) 
		inner join tblCard C (NOLOCK) on H.Payment_UserCode = C.Card_SerialNo
		inner join tblCardPointTrans CT (NOLOCK) on CT.CardPointTrans_Code = H.Payment_ReceiptNo
		inner join tblPayment_Details D (NOLOCK) on D.PaymentD_ReceiptNo = H.Payment_ReceiptNo
		inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = C.Card_CardOwner_ID
		inner join tblProduct P (NOLOCK) on P.Product_ItemCode = D.PaymentD_ItemCode
		inner join tblCounter CR (NOLOCK) on CR.Counter_Code = H.Payment_CounterCode
		where H.Payment_CreatedDate between @strDateFrom and @strDateTo
		AND H.Payment_PaymentType = 2
		AND H.Payment_TableCode = '' 
		UNION
		select 0 AS RowNo, CO.CardOwner_Name as PlayerName, C.Card_SerialNo as CardNumber,
		CT.CardPointTrans_PointValue as RedeemPoint, 
		P.Product_Desc as RedeemItem, H.Payment_Remarks as RedeemExtraInfo,
		H.Payment_CreatedDate as RedeemDate, H.Payment_TableCode as RedeemLocation
		from tblPayment_Header H (NOLOCK) 
		inner join tblCard C (NOLOCK) on H.Payment_UserCode = C.Card_SerialNo
		inner join tblCardPointTrans CT (NOLOCK) on CT.CardPointTrans_Code = H.Payment_ReceiptNo
		inner join tblPayment_Details D (NOLOCK) on D.PaymentD_ReceiptNo = H.Payment_ReceiptNo
		inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = C.Card_CardOwner_ID
		inner join tblProduct P (NOLOCK) on P.Product_ItemCode = D.PaymentD_ItemCode
		where H.Payment_CreatedDate between @strDateFrom and @strDateTo
		AND H.Payment_PaymentType = 2
		AND H.Payment_TableCode <> '' 
		Order by Payment_CreatedDate desc
	END
	ELSE if @strLocationID = 0
	BEGIN
		select ROW_NUMBER() OVER(ORDER BY H.Payment_CreatedDate desc)  AS RowNo, 
		CO.CardOwner_Name as PlayerName, C.Card_SerialNo as CardNumber,
		CT.CardPointTrans_PointValue as RedeemPoint, 
		P.Product_Desc as RedeemItem, H.Payment_Remarks as RedeemExtraInfo,
		H.Payment_CreatedDate as RedeemDate, H.Payment_TableCode as RedeemLocation
		from tblPayment_Header H (NOLOCK) 
		inner join tblCard C (NOLOCK) on H.Payment_UserCode = C.Card_SerialNo
		inner join tblCardPointTrans CT (NOLOCK) on CT.CardPointTrans_Code = H.Payment_ReceiptNo
		inner join tblPayment_Details D (NOLOCK) on D.PaymentD_ReceiptNo = H.Payment_ReceiptNo
		inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = C.Card_CardOwner_ID
		inner join tblProduct P (NOLOCK) on P.Product_ItemCode = D.PaymentD_ItemCode
		where H.Payment_CreatedDate between @strDateFrom and @strDateTo
		AND H.Payment_PaymentType = 2
		AND H.Payment_TableCode <> '' 
		Order by H.Payment_CreatedDate desc
	END
	ELSE if @strLocationID = 1
	BEGIN
		select ROW_NUMBER() OVER(ORDER BY H.Payment_CreatedDate desc)  AS RowNo, 
		CO.CardOwner_Name as PlayerName, C.Card_SerialNo as CardNumber,
		CT.CardPointTrans_PointValue as RedeemPoint, 
		P.Product_Desc as RedeemItem, '' as RedeemExtraInfo,
		H.Payment_CreatedDate as RedeemDate, CR.Counter_Name as RedeemLocation
		from tblPayment_Header H (NOLOCK) 
		inner join tblCard C (NOLOCK) on H.Payment_UserCode = C.Card_SerialNo
		inner join tblCardPointTrans CT (NOLOCK) on CT.CardPointTrans_Code = H.Payment_ReceiptNo
		inner join tblPayment_Details D (NOLOCK) on D.PaymentD_ReceiptNo = H.Payment_ReceiptNo
		inner join tblCardOwner CO (NOLOCK) on CO.CardOwner_ID = C.Card_CardOwner_ID
		inner join tblProduct P (NOLOCK) on P.Product_ItemCode = D.PaymentD_ItemCode
		inner join tblCounter CR (NOLOCK) on CR.Counter_Code = H.Payment_CounterCode
		where H.Payment_CreatedDate between @strDateFrom and @strDateTo
		AND H.Payment_PaymentType = 2
		AND H.Payment_TableCode = '' 
		Order by H.Payment_CreatedDate desc
	END

END
