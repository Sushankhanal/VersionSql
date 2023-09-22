/****** Object:  Procedure [dbo].[sp_tblProduct_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblProduct_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strItemCode	nvarchar(50),
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
	@strPrinterName  nvarchar(50), --Yusri 10/10/2019
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
	-- SET NOCOUNT ON addedto prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--@strFullUOMDesc,@strHalfUOMDesc,@strRemarks,@strRemarksChi,@strItemImgExtra
	--Product_FullDesc, Product_HalfDesc, Product_Remarks, Product_RemarksChi, Product_ImgExtra
		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(Product_ID), 0) FROM tblProduct NOLOCK 
		WHERE (Product_ItemCode = @strItemCode )

		IF @intCount = 0 
		BEGIN
			DECLARE @PrefixType VARCHAR(50), @intRowCount INT
			set @PrefixType = 'Item'
			EXEC sp_tblPrefixNumber_GetNextRunNumber 'Item', @PrefixType, 0, @strItemCode OUTPUT

			DECLARE @strCompanyCode nvarchar(50)
			select @strCompanyCode = Branch_CompanyCode from tblBranch where Branch_Code = @strBranchCode

			INSERT INTO tblProduct
			(Product_ItemCode, Product_Desc, Product_UOM, Product_UnitPrice, Product_Bal, Product_Status, 
			Product_CreatedBy, Product_CreatedDate, Product_Discount, Product_Cost, Product_CategoryCode, 
			Product_MemberPrice, Product_SupplierID, Product_TaxCode, Product_TaxRate, Product_CounterCode, 
			Product_CompanyCode, Product_img, Product_WalletsTransType, Product_AddonGroup, Product_BranchCode, Product_PrinterName,  -- Yusri 10/10/2019 Product_PrinterName --
			Product_ChiDesc,Product_UnitPrice2, Product_ImgPath,
			Product_FullDesc, Product_HalfDesc, Product_Remarks, Product_RemarksChi, Product_ImgExtra, Product_FinanceGroup)  -- Yusri 20/10/2019 --
			VALUES (
			@strItemCode,@strItemName,@strUOM,@dblUnitPrice,0,@intStatus,
			@strUsercode,GETDATE(),0,@dblUnitCost,@strCategoryCode,
			0,0,'',@dblTaxRate,@strCounterCode,
			@strCompanyCode,@byteItemImg,@intItemSign, @strAddonGroup, @strBranchCode,@strPrinterName,@strItemChiName,@dblUnitPrice2,
			@strItemImg,@strFullUOMDesc,@strHalfUOMDesc,@strRemarks,@strRemarksChi,@strItemImgExtra, @intFoodOrBeverage)  -- Yusri 10&20/10/2019 --
			SELECT @ID = SCOPE_IDENTITY()

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

		END
		ELSE
		BEGIN
			RAISERROR ('Error',16,1);  
			COMMIT TRANSACTION
			SET NOCOUNT OFF
			RETURN (-1)
		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
