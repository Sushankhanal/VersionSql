/****** Object:  Procedure [dbo].[Local_sp_Sync_Card_insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Local_sp_Sync_Card_insert]
	@ID		int OUT,
	@Xml XML,
	@strCode	nvarchar(50),
	@strCompanyCode	nvarchar(50),
	@intID			bigint,
	@CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT
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
	select @intCount = ISNULL(COUNT(Card_ID), 0) from tblCard where Card_SerialNo = @strCode
	AND Card_CompanyCode = @strCompanyCode AND Card_ID = @intID

	IF @intCount > 0 
	BEGIN
		Delete from tblCard where Card_SerialNo = @strCode
		AND Card_CompanyCode = @strCompanyCode AND Card_ID = @intID
	END
	
	SET IDENTITY_INSERT tblCard ON 
	INSERT INTO tblCard
	(Card_ID, Card_SerialNo, Card_Status, Card_MobileUser, Card_CreatedBy, Card_CreatedDate, Card_Balance, Card_Point, Card_CompanyCode)
	Select Card_ID, Card_SerialNo, Card_Status, Card_MobileUser, Card_CreatedBy, Card_CreatedDate, Card_Balance, Card_Point, Card_CompanyCode
	FROM OPENXML (@intDoc,  N'/NewDataSet/Table', 2)
	WITH (Card_ID bigint, Card_SerialNo nvarchar(50), Card_Status smallint, 
	Card_MobileUser nvarchar(50), Card_CreatedBy nvarchar(50), Card_CreatedDate datetime, Card_Balance money,
	Card_Point decimal(38, 10), Card_CompanyCode nvarchar(50))
	SET IDENTITY_INSERT tblCard OFF

	set @ID = @intID
	set @CardId=@intID

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
