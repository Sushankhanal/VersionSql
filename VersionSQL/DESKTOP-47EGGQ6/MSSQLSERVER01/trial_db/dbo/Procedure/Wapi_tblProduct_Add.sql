/****** Object:  Procedure [dbo].[Wapi_tblProduct_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblProduct_Add]
	-- Add the parameters for the stored procedure here
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

		Declare @ID	bigint = 0
		Declare @strResultText nvarchar(255) = ''
		Declare @intResultCode int = 0

		DECLARE @intCount INT = 0
		SELECT @intCount = ISNULL(COUNT(Product_ID), 0) FROM tblProduct NOLOCK WHERE (Product_ItemCode = @strItemCode )
		
		Declare @strBranchCode nvarchar(50) = ''
		Declare @strCompanyCode nvarchar(50) = ''

		--insert into tblA (strValue,CreatedDate) values ('Code:' + @strItemCode,GETDATE())
		--insert into tblA (strValue,CreatedDate) values ('Name:' + @strItemName,GETDATE())
		--insert into tblA (strValue,CreatedDate) values ('FileName:' + @strImageFileName,GETDATE())

		--insert into tblA (strValue,CreatedDate) values ('UOM:' + @strUOM,GETDATE())
		--insert into tblA (strValue,CreatedDate) values ('category:' + @strCategory,GETDATE())

		select top 1 @strCompanyCode = Company_Code, @strBranchCode = Company_Code from tblCompany c (NOLOCK) Order by Company_ID


		IF @intCount = 0 
		BEGIN
			INSERT INTO tblProduct
			(Product_ItemCode, Product_Desc, Product_UOM, Product_UnitPrice, Product_Status, 
			Product_CreatedBy, Product_CreatedDate, Product_Cost, Product_CategoryCode, Product_TaxRate,Product_CompanyCode,
			Product_ImgPath,Product_BranchCode)
			VALUES (
			@strItemCode,@strItemName,@strUOM, @dblUnitPrice, @intStatus,
			@strUsercode,GETDATE(),@dblUnitCost, @strCategory, @dblTaxRate,@strCompanyCode,
			@strImageFileName,@strBranchCode)
			SELECT @ID = SCOPE_IDENTITY()
			--insert into tblA (strValue,CreatedDate) values ('ID:' + @ID,GETDATE())
			set @intResultCode = @ID
			set @strResultText = 'Success'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

		END
		ELSE
		BEGIN
			set @ID = -1
			set @strResultText = 'Item code already used, Please try another code.'
			select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

		END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
