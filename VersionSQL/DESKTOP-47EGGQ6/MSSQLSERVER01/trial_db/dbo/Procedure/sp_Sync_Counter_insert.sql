/****** Object:  Procedure [dbo].[sp_Sync_Counter_insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Sync_Counter_insert]
	@ID		int OUT,
	@Xml XML,
	@strCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@intID			bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION

	DECLARE @objXml XML, @intDoc INT
	
	SELECT @objXml = @Xml
	EXEC sp_xml_preparedocument @intDoc OUTPUT, @objXml

	DECLARE @intCount INT
	select @intCount = ISNULL(COUNT(Counter_ID), 0) from tblCounter where Counter_Code = @strCode
	--AND Counter_CompanyCode = @strCompanyCode 
	AND Counter_ID = @intID

	IF @intCount > 0 
	BEGIN
		Delete from tblCounter where Counter_Code = @strCode
		--AND Counter_CompanyCode = @strCompanyCode
		AND Counter_ID = @intID

		delete from tblProductCounter where ProductCounter_CounterID = @intID
	END
	
	SET IDENTITY_INSERT tblCounter ON 

	INSERT INTO tblCounter
	(Counter_ID, Counter_Code, Counter_BranchCode, Counter_Name, Counter_Cashless, Counter_Status, Counter_CompanyCode, 
	Counter_ReceiptPrinterName, Counter_KitchenPrinterName)
	Select Counter_ID, Counter_Code, Counter_BranchCode, Counter_Name, Counter_Cashless, Counter_Status, Counter_CompanyCode, 
	Counter_ReceiptPrinterName, Counter_KitchenPrinterName
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table', 2)
	WITH (Counter_ID bigint, Counter_Code nvarchar(50), Counter_BranchCode nvarchar(50), Counter_Name nvarchar(50), 
	Counter_Cashless smallint, Counter_Status smallint, 
	Counter_CompanyCode nvarchar(50), Counter_ReceiptPrinterName nvarchar(50), Counter_KitchenPrinterName  nvarchar(50))

	SET IDENTITY_INSERT tblCounter OFF

	SET IDENTITY_INSERT tblProductCounter ON 
	delete from tblProductCounter
	where ProductCounter_ID in (
	Select ProductCounter_ID
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table1', 2)
	WITH (ProductCounter_ID bigint)
	)

	INSERT INTO tblProductCounter
	(ProductCounter_ID, ProductCounter_CounterID, ProductCounter_ProductCode)
	Select ProductCounter_ID, ProductCounter_CounterID, ProductCounter_ProductCode
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table1', 2)
	WITH (ProductCounter_ID bigint, ProductCounter_CounterID bigint, ProductCounter_ProductCode nvarchar(50))
	SET IDENTITY_INSERT tblProductCounter OFF


	

	set @ID = @intID

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
