/****** Object:  Procedure [dbo].[api_GetTableList]    Committed by VersionSQL https://www.versionsql.com ******/

--exec api_GetSoupCategory('')
--exec api_GetFoodCategory(''
-- exec api_GetTableList '','comp02',''
CREATE PROCEDURE [dbo].[api_GetTableList] (
	@strDeviceCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@strUserCode	nvarchar(50)
) AS
BEGIN
	
	Declare @strErrorText nvarchar(255) = ''
	Declare @intErrorCode int = 0

	--if @strUserCode <> ''
	--BEGIN
	--	if (select ISNULL(COUNT(POSUser_ID),0) from tblPOSUser where POSUser_CompanyCode = @strCompanyCode
	--	AND POSUser_Code = @strUserCode AND POSUser_Password = @strUserCode) = 0
	--	BEGIN
	--		set @intErrorCode = -1
	--		set @strErrorText = 'Error Code: ' + CONVERT(nvarchar(50),@intErrorCode) + 
	--		' - Invalid Access Code.'
	--		RAISERROR (@strErrorText,16,1);  
	--		ROLLBACK TRANSACTION
	--		SET NOCOUNT OFF
	--		Select @intErrorCode as ResultCode, @strErrorText as ResultText
	--		RETURN (@intErrorCode)
	--	END
		
	--END

	--Declare @strColor1 nvarchar(50) = 'green'
	--Declare @strColor2 nvarchar(50) = 'orange'
	--Declare @strColor3 nvarchar(50) = 'purple'

	--Declare @strCalling1 nvarchar(50) = 'Calling'
	--Declare @strCalling2 nvarchar(50) = 'Calling Bill'
	--Declare @strCalling3 nvarchar(50) = 'Calling Add Soup'

	update tblTable set Table_Status = 1
	where Table_Code in (
	select Payment_TableCode from tblPayment_Order  
	where Payment_CompanyCode = @strCompanyCode and Payment_Status = 0)

	SELECT Table_ID, Table_Code, Table_Name, 
	(CASE Table_isCalling WHEN 1 THEN 3 WHEN 2 THEN 4 WHEN 3 THEN 5 ELSE Table_Status END) as Table_Status,
	(CASE Table_isCalling WHEN 0 THEN ts.TableStatus_Name ELSE dbo.fnGetCallingName(Table_isCalling) END) as TableStatus_Name ,
	(CASE Table_isCalling WHEN 0 THEN ts.TableStatus_Color ELSE dbo.fnGetCallingColorName(Table_isCalling) END) as  TableStatus_Color,
	(CASE Table_isCalling WHEN 0 THEN ts.TableStatus_ColorCode ELSE dbo.fnGetCallingColorCode(Table_isCalling) END) as  TableStatus_ColorCode,
	ISNULL((CASE Table_Status WHEN 1 THEN 
	(Select top 1 ISNULL(Payment_ReceiptNo,'') from tblPayment_Order where Payment_TableCode = t.Table_Code and Payment_Status = 0) ELSE '' END),'') as OrderNumber,
	ISNULL((CASE Table_Status WHEN 1 THEN 
	(Select top 1  DATEDIFF(minute, Payment_CreatedDate, GETDATE()) from tblPayment_Order where Payment_TableCode = t.Table_Code and Payment_Status = 0) ELSE '' END),'') as OrderDurationInMinute
	FROM tblTable t  (NOLOCK) inner join tblTableStatus ts  (NOLOCK) on t.Table_Status = ts.TableStatus_ID
	WHERE (Table_CompanyCode = @strCompanyCode)
	Order by Table_Order, Table_Code 

	
END
