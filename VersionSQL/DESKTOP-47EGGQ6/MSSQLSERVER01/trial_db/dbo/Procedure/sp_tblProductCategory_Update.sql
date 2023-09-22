/****** Object:  Procedure [dbo].[sp_tblProductCategory_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblProductCategory_Update]
	-- Add the parameters for the stored procedure here
	@ID		bigint,
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

	IF @byteCategoryImg is null   -- Yusri 21/10/2019 --
		BEGIN
		Update tblProductCategory set
			ProCategory_Name = @strCategoryName, ProCategory_Status = @intCategoryStatus, ProCategory_Order = @strOrderNumber, -- Yusri 13/10/2019 --
			ProCategory_ChiName=@strCategoryChineseName  ,ProCategory_Group=@intProductGroup, 
			ProCategory_Sync = 0, ProCategory_Desc = @strRemarks
			WHERE ProCategory_ID = @ID
		END
	ELSE
		BEGIN
			Update tblProductCategory set
			ProCategory_Name = @strCategoryName, ProCategory_Status = @intCategoryStatus, ProCategory_Order = @strOrderNumber, -- Yusri 13/10/2019 --
			ProCategory_ChiName=@strCategoryChineseName  ,ProCategory_Group=@intProductGroup, 
			ProCategory_Img = @byteCategoryImg, ProCategory_Sync = 0,
			ProCategory_ImgPath = @strCategoryImg, ProCategory_Desc = @strRemarks
			WHERE ProCategory_ID = @ID
		END						-- END 21/10/2019 --

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
