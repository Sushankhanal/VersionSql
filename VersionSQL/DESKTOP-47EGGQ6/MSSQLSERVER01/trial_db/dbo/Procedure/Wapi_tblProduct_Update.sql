/****** Object:  Procedure [dbo].[Wapi_tblProduct_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[Wapi_tblProduct_Update]
	-- Add the parameters for the stored procedure here
	@intID		int ,
	@strItemCode	nvarchar(50),
	@strItemName	nvarchar(100),
	@strUOM			nvarchar(50),
	@dblUnitPrice	money,
	@dblUnitCost	money,
	@strCategory	nvarchar(50),
	@intStatus		smallint,
	@dblTaxRate		money,
	@strImageFileName	nvarchar(100),
	@strUsercode	nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0
		Update tblProduct Set
		Product_ItemCode = @strItemCode, Product_Desc = @strItemName, Product_UOM = @strUOM, 
		Product_UnitPrice = @dblUnitPrice, Product_Status = @intStatus, 
		Product_UpdatedBy = @strUsercode, Product_UpdatedDate = GETDATE(), 
		Product_Cost = @dblUnitCost, Product_CategoryCode = @strCategory, 
		Product_TaxRate = @dblTaxRate
		Where Product_ID = @intID

		if @strImageFileName <> ''
		BEGIN
		Update tblProduct Set Product_ImgPath = @strImageFileName Where Product_ID = @intID
		END


	set @intResultCode = @intID
	set @strResultText = 'Success'
	select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
