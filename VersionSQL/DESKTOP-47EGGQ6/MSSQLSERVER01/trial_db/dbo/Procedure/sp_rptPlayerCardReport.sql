/****** Object:  Procedure [dbo].[sp_rptPlayerCardReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec sp_rptDailySales '2019-02-01','2019-02-28',0
CREATE PROCEDURE [dbo].[sp_rptPlayerCardReport]
	-- Add the parameters for the stored procedure here
	@intStatus			smallint,
	@strUserCode		nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    select C.Card_ID, C.Card_SerialNo, Card_Balance, Card_Balance_Cashable_No, Card_Balance_Cashable, C.Card_Point,
	ISNULL(co.CardOwner_Name,'') as CardOwner_Name, ISNULL(co.CardOwner_IC,'') as CardOwner_IC,
	(CASE Card_Status WHEN 0 THEN 'Active' ELSE 'Inactive' END) as Card_StatusText from tblCard C
	left outer join tblCardOwner CO on C.Card_CardOwner_ID = CO.CardOwner_ID
	where Card_Status = @intStatus
	Order by C.Card_SerialNo
END
