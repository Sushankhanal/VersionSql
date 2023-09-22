/****** Object:  Procedure [dbo].[Wapi_tblProductCategory_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Wapi_tblProductCategory_Add]
	-- Add the parameters for the stored procedure here
	@strCategoryCode	nvarchar(50),
	@strCategoryName	nvarchar(50),
	@intCategoryStatus	smallint,
	@strUsercode		nvarchar(50),
	@strOrderNumber		nvarchar(50),  -- Yusri 13/10/2019 --
	@strRemarks		nvarchar(500)   -- Ricky 09/01/2020 --
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @ID	bigint = 0
	Declare @strResultText nvarchar(255) = ''
	Declare @intResultCode int = 0


	DECLARE @PrefixType VARCHAR(50), @intRowCount INT
	set @PrefixType = 'Category'
	EXEC sp_tblPrefixNumber_GetNextRunNumber 'Category', @PrefixType, 0, @strCategoryCode OUTPUT

	DECLARE @intCount INT
	SELECT @intCount = ISNULL(COUNT(ProCategory_ID), 0) FROM tblProductCategory NOLOCK 
	WHERE (ProCategory_Code = @strCategoryCode )
		
		
	IF @intCount = 0 
	BEGIN
			
		Declare @strCompanyCode nvarchar(50) = ''
		--select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode
		select top 1 @strCompanyCode = Company_Code from tblCompany c (NOLOCK) Order by Company_ID

		INSERT INTO tblProductCategory
		(ProCategory_Code, ProCategory_Name, ProCategory_Status, ProCategory_CounterCode, ProCategory_CreatedBy, 
		ProCategory_CreatedDate, ProCategory_Img, ProCategory_CompanyCode,ProCategory_Order,ProCategory_ChiName ,ProCategory_Group,
		ProCategory_ImgPath, ProCategory_Desc)   
		VALUES (
		@strCategoryCode,@strCategoryName,@intCategoryStatus,'',@strUsercode,GETDATE(),null, @strCompanyCode,
		@strOrderNumber,'',0, '', @strRemarks) 
		
		SELECT @ID = SCOPE_IDENTITY()

		set @intResultCode = @ID
		set @strResultText = 'Success'
		select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT

	END
	ELSE
	BEGIN
		set @intResultCode = -1
		set @strResultText = 'Category Code already used, Please try another Category Code.'
		ROLLBACK TRANSACTION
		SET NOCOUNT OFF
		select @intResultCode as RETURN_RESULT, @strResultText as RETURN_RESULT_TEXT
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
