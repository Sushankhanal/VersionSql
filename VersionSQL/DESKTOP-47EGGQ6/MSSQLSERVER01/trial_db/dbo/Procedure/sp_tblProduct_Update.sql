/****** Object:  Procedure [dbo].[sp_tblProduct_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblProduct_Update]
	-- Add the parameters for the stored procedure here
	@ID		int,
	@strItemName	nvarchar(100),
	@strUOM			nvarchar(50),
	@dblUnitPrice	money,
	@intStatus			smallint,
	@dblUnitCost		money,
	@strCategoryCode	nvarchar(50),
	@strCounterCode		nvarchar(50) = '',
	@byteItemImg		image,
	@strUsercode		nvarchar(50),
	@intItemSign		smallint,
	@strAddonGroup		nvarchar(50),
	@strBranchCode		nvarchar(50),
	@strPrinterName  nvarchar(50), ------- Yusri 11/10/2019 -------
	@strItemChiName  nvarchar(100), --Yusri 20/10/2019
	@dblUnitPrice2 money,  --Yusri 20/10/2019
	@strItemImg		nvarchar(50),
	@dblTaxRate		money,
	@strFullUOMDesc		nvarchar(50),
	@strHalfUOMDesc		nvarchar(50),
	@strRemarks		nvarchar(50),
	@strRemarksChi		nvarchar(50),
	@strItemImgExtra		nvarchar(50),
	@intFoodOrBeverage		smallint
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @strItemCode nvarchar(50)
		SELECT @strItemCode = Product_ItemCode FROM tblProduct  
		WHERE Product_ID = @ID 

		Delete from tblProductCounter where ProductCounter_ProductCode = @strItemCode

		DECLARE @strCompanyCode nvarchar(50)
		select @strCompanyCode = Branch_CompanyCode from tblBranch where Branch_Code = @strBranchCode

		IF @byteItemImg is null  -- Yusri 21/10/2019 --
			begin
				Update tblProduct set
				Product_Desc = @strItemName, Product_UOM = @strUOM, Product_UnitPrice = @dblUnitPrice, Product_Status = @intStatus, 
				Product_UpdatedBy = @strUsercode, Product_UpdatedDate = GETDATE(), Product_Cost = @dblUnitCost, Product_CategoryCode = @strCategoryCode, 
				Product_CounterCode = @strCounterCode, Product_CompanyCode = @strCompanyCode, 
				Product_WalletsTransType = @intItemSign, Product_AddonGroup = @strAddonGroup, Product_BranchCode = @strBranchCode, Product_PrinterName = @strPrinterName, ----Yusri 11/10/2019 -------
				Product_ChiDesc = @strItemChiName, Product_UnitPrice2 = @dblUnitPrice2,  
				Product_Sync = 0, Product_TaxRate = @dblTaxRate,
				Product_FullDesc = @strFullUOMDesc, Product_HalfDesc = @strHalfUOMDesc, Product_Remarks = @strRemarks, 
				Product_RemarksChi = @strRemarksChi, Product_ImgExtra = @strItemImgExtra, Product_FinanceGroup = @intFoodOrBeverage
				WHERE Product_ID = @ID 
			end
		ELSE
			begin
				Update tblProduct set
				Product_Desc = @strItemName, Product_UOM = @strUOM, Product_UnitPrice = @dblUnitPrice, Product_Status = @intStatus, 
				Product_UpdatedBy = @strUsercode, Product_UpdatedDate = GETDATE(), Product_Cost = @dblUnitCost, Product_CategoryCode = @strCategoryCode, 
				Product_CounterCode = @strCounterCode, Product_CompanyCode = @strCompanyCode, Product_img = @byteItemImg, 
				Product_WalletsTransType = @intItemSign, Product_AddonGroup = @strAddonGroup, Product_BranchCode = @strBranchCode, Product_PrinterName = @strPrinterName, ----Yusri 11/10/2019 -------
				Product_ChiDesc = @strItemChiName, Product_UnitPrice2 = @dblUnitPrice2, 
				Product_Sync = 0, Product_TaxRate = @dblTaxRate, Product_ImgPath = @strItemImg,
				Product_FullDesc = @strFullUOMDesc, Product_HalfDesc = @strHalfUOMDesc, Product_Remarks = @strRemarks, 
				Product_RemarksChi = @strRemarksChi, Product_ImgExtra = @strItemImgExtra, Product_FinanceGroup = @intFoodOrBeverage
				WHERE Product_ID = @ID 
			end					-- End 21/10/2019 --							

		DECLARE @tblSummary TABLE
			(CounterID bigint,ISPROCCESS INT)

			insert into @tblSummary
			select [Name], 0 from  dbo.fnSplitstringToTable(@strCounterCode) 

			DECLARE @IS_PROCCESS AS INT
			Declare @intID int


			SET @IS_PROCCESS = 0
			WHILE @IS_PROCCESS = 0 
			BEGIN
				SELECT TOP 1 @intID = CounterID
				FROM @tblSummary WHERE ISPROCCESS = 0 
				IF @@ROWCOUNT = 0
					BEGIN
						SET @IS_PROCCESS = 1
					END
				ELSE
					BEGIN
						INSERT INTO tblProductCounter
						(ProductCounter_CounterID, ProductCounter_ProductCode)
						VALUES (@intID, @strItemCode)

						UPDATE @tblSummary SET ISPROCCESS = 1
						WHERE CounterID = @intID

					END

			END


	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
