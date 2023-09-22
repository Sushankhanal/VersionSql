/****** Object:  Procedure [dbo].[sp_Sync_Product_insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_Product_insert]
	@ID		int OUT,
	@Xml XML,
	@strItemCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@intID			bigint,
	@byteItemImg		image
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION

	DECLARE @objXml XML, @intDoc INT
	
	SELECT @objXml = @Xml
	--print convert(nvarchar(max),@objXml)
	EXEC sp_xml_preparedocument @intDoc OUTPUT, @objXml

	DECLARE @intCount INT
	select @intCount = ISNULL(COUNT(Product_ID), 0) from tblProduct 
	where Product_ItemCode = @strItemCode
	--AND Product_CompanyCode = @strCompanyCode 
	AND Product_ID = @intID

	IF @intCount > 0 
	BEGIN
		Delete from tblProduct 
		where Product_ItemCode = @strItemCode
		--AND Product_CompanyCode = @strCompanyCode
		AND Product_ID = @intID
	END
	
	SET IDENTITY_INSERT [dbo].[tblProduct] ON 
	INSERT INTO tblProduct
	(Product_ID, Product_ItemCode, Product_Desc, Product_UOM, Product_UnitPrice, Product_Bal, Product_Status, 
	Product_CreatedBy, Product_CreatedDate, Product_Discount, Product_Cost, Product_CategoryCode, 
	Product_MemberPrice, Product_SupplierID, Product_TaxCode, Product_TaxRate, Product_CounterCode, 
	Product_CompanyCode, Product_img, Product_WalletsTransType, Product_AddonGroup, Product_BranchCode, 
	Product_UpdatedBy, Product_UpdatedDate,Product_PrinterName, Product_ImgPath, Product_Desc2, Product_ChiDesc2,
	Product_FullDesc, Product_HalfDesc, Product_Remarks, Product_RemarksChi, Product_ImgExtra, Product_ChiDesc, Product_UnitPrice2)
	Select Product_ID, Product_ItemCode, Product_Desc, Product_UOM, Product_UnitPrice, Product_Bal, Product_Status, 
	Product_CreatedBy, Product_CreatedDate, Product_Discount, Product_Cost, Product_CategoryCode, 
	Product_MemberPrice, Product_SupplierID, Product_TaxCode, Product_TaxRate, Product_CounterCode, 
	Product_CompanyCode, @byteItemImg, Product_WalletsTransType, Product_AddonGroup, Product_BranchCode, 
	Product_UpdatedBy, GETDATE(), Product_PrinterName, Product_ImgPath, Product_Desc2, Product_ChiDesc2,
	Product_FullDesc, Product_HalfDesc, Product_Remarks, Product_RemarksChi, Product_ImgExtra, Product_ChiDesc, Product_UnitPrice2
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table', 2)
	WITH (Product_ID bigint, Product_ItemCode nvarchar(50), Product_Desc nvarchar(255), Product_UOM nvarchar(50), 
	Product_UnitPrice money, Product_Bal int, Product_Status smallint, 
	Product_CreatedBy nvarchar(50), Product_CreatedDate datetime, Product_Discount float, Product_Cost money, Product_CategoryCode  nvarchar(50), 
	Product_MemberPrice money, Product_SupplierID bigint, Product_TaxCode nvarchar(50), Product_TaxRate money, Product_CounterCode  nvarchar(50), 
	Product_CompanyCode nvarchar(50), Product_WalletsTransType int, Product_AddonGroup nvarchar(50), Product_BranchCode nvarchar(50), 
	Product_UpdatedBy  nvarchar(50), Product_UpdatedDate datetime,Product_PrinterName nvarchar(50),
	Product_ImgPath nvarchar(50), Product_Desc2 nvarchar(50), Product_ChiDesc2 nvarchar(50),
	Product_FullDesc nvarchar(50), Product_HalfDesc nvarchar(50), Product_Remarks nvarchar(100), 
	Product_RemarksChi  nvarchar(100), Product_ImgExtra  nvarchar(50), Product_ChiDesc nvarchar(50), Product_UnitPrice2 money)

	SET IDENTITY_INSERT [dbo].[tblProduct] OFF

	set @ID = @intID

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
