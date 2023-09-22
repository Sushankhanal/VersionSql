/****** Object:  Procedure [dbo].[sp_tblSettlement_Get]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[sp_tblSettlement_Get]
	-- Add the parameters for the stored procedure here
	--@intID			nvarchar(50) OUT,
	@strPOSUserCode		nvarchar(50),
	@strCounterCode		nvarchar(50),
	@strCompanyCode		nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select Settlement_InitialCash as InitialCash,
	Settlement_GrossAmt as TotalGrossAmt,
	Settlement_GlobalDiscountAmt as TotalGlobalDiscountAmt,
	Settlement_ItemDiscountAmt as TotalItemDiscountAmt,
	Settlement_TotalTaxAmt as TotalTaxAmt,
	Settlement_RoundUp as TotalRoundUp,
	Settlement_FinalAmt as TotalNetAmt,
	Settlement_RefundAmt as TotalRefundAmt,
	Settlement_Code, Settlement_Date, Settlement_CashierCash
	From tblSettlement
	where Settlement_CounterCode = @strCounterCode
	Order by Settlement_Date desc

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
