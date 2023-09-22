/****** Object:  Procedure [dbo].[sp_Sync_ProductCategory_insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_ProductCategory_insert]
	@ID		int OUT,
	@Xml XML,
	@strCode	nvarchar(50),
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
	select @intCount = ISNULL(COUNT(ProCategory_ID), 0) from tblProductCategory where ProCategory_Code = @strCode
	AND ProCategory_CompanyCode = @strCompanyCode AND ProCategory_ID = @intID

	IF @intCount > 0 
	BEGIN
		Delete from tblProductCategory where ProCategory_Code = @strCode
		AND ProCategory_CompanyCode = @strCompanyCode
		AND ProCategory_ID = @intID
	END
	
	SET IDENTITY_INSERT tblProductCategory ON 

	INSERT INTO tblProductCategory
	(ProCategory_ID, ProCategory_Code, ProCategory_Name, ProCategory_Status, ProCategory_CounterCode, ProCategory_CreatedBy, ProCategory_CreatedDate, 
	ProCategory_Img, ProCategory_CompanyCode,ProCategory_Order, ProCategory_ChiName, ProCategory_Group, ProCategory_ImgPath, ProCategory_Desc)
	Select ProCategory_ID, ProCategory_Code, ProCategory_Name, ProCategory_Status, ProCategory_CounterCode, ProCategory_CreatedBy, ProCategory_CreatedDate, 
	@byteItemImg, ProCategory_CompanyCode, ProCategory_Order, ProCategory_ChiName, ProCategory_Group, ProCategory_ImgPath, ProCategory_Desc
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table', 2)
	WITH (ProCategory_ID bigint, ProCategory_Code nvarchar(50), ProCategory_Name nvarchar(255), ProCategory_Status smallint, 
	ProCategory_CounterCode nvarchar(50), ProCategory_CreatedBy  nvarchar(50), 
	ProCategory_CreatedDate datetime, ProCategory_CompanyCode  nvarchar(50), ProCategory_Order int,
	ProCategory_ChiName nvarchar(50), ProCategory_Group int, ProCategory_ImgPath nvarchar(50), ProCategory_Desc nvarchar(500))

	SET IDENTITY_INSERT tblProductCategory OFF

	set @ID = @intID

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
