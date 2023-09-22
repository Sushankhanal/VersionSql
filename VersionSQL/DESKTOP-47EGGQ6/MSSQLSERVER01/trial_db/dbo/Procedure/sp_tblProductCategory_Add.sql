/****** Object:  Procedure [dbo].[sp_tblProductCategory_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblProductCategory_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strCategoryCode	nvarchar(50),
	@strCategoryName	nvarchar(50),
	@intCategoryStatus	smallint,
	@byteCategoryImg	image,
	@strUsercode		nvarchar(50),
	@strOrderNumber		nvarchar(50),  -- Yusri 13/10/2019 --
	@strCategoryChineseName nvarchar(50),   -- Yusri 20/10/2019 --
	@intProductGroup smallint,   -- Yusri 20/10/2019 --
	@strCategoryImg nvarchar(50),   -- Ricky 14/11/2019 --
	@strRemarks		nvarchar(500)   -- Ricky 09/01/2020 --
AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @PrefixType VARCHAR(50), @intRowCount INT
		set @PrefixType = 'Category'
		EXEC sp_tblPrefixNumber_GetNextRunNumber 'Category', @PrefixType, 0, @strCategoryCode OUTPUT

		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(ProCategory_ID), 0) FROM tblProductCategory NOLOCK 
		WHERE (ProCategory_Code = @strCategoryCode )
		
		
		IF @intCount = 0 
		BEGIN
			
			Declare @strCompanyCode nvarchar(50)
			select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

			INSERT INTO tblProductCategory
			(ProCategory_Code, ProCategory_Name, ProCategory_Status, ProCategory_CounterCode, ProCategory_CreatedBy, 
			ProCategory_CreatedDate, ProCategory_Img, ProCategory_CompanyCode,ProCategory_Order,ProCategory_ChiName ,ProCategory_Group,
			ProCategory_ImgPath, ProCategory_Desc)   -- Yusri 13&20/10/2019 --
			VALUES (
			@strCategoryCode,@strCategoryName,@intCategoryStatus,'',@strUsercode,GETDATE(),@byteCategoryImg, @strCompanyCode,
			@strOrderNumber,@strCategoryChineseName,@intProductGroup, @strCategoryImg, @strRemarks)  -- Yusri 13&20/10/2019 --
			-- Ricky 14/11/2019 --
			SELECT @ID = SCOPE_IDENTITY()
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
