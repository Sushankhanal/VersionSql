/****** Object:  Procedure [dbo].[sp_tblCardOwner_GetCreditPoint]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec sp_tblProduct_get 'COUNTER1','Hallaway01',''
CREATE PROCEDURE [dbo].[sp_tblCardOwner_GetCreditPoint] (
	@strCardNumber	nvarchar(50),
	@intUserID		int,
	@strCardPin		nvarchar(50)
) AS
BEGIN
	--0:invalid
	--1:Valid
	
	Declare @intIsPinValid int = 0
	select @intIsPinValid = COUNT(C.Card_ID) from tblCard C (NOLOCK) where C.Card_SerialNo = @strCardNumber and tblCard_pin = @strCardPin

	select C.Card_SerialNo, CO.CardOwner_Name, Card_Balance, 
	Card_Balance_Cashable_No, Card_Balance_Cashable, Card_Point, CO.CardOwner_Pic, 
	C.Card_Point_Tier, C.Card_Point_Hidden, C.Card_PointAccumulate,
	@intIsPinValid as isPinValid
	from tblCard C  (NOLOCK)
	inner join tblCardOwner CO  (NOLOCK) on C.Card_CardOwner_ID = CO.CardOwner_ID
	where C.Card_SerialNo = @strCardNumber
END
