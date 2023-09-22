/****** Object:  Procedure [dbo].[sp_tblCardType_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblCardType_Add]
	-- Add the parameters for the stored procedure here
	@ID		int OUT,
	@strName	nvarchar(50),
	@intStatus	smallint,
	@dblRate	smallint,
	@strUsercode	nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		
		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT([CardType_ID]), 0) FROM tblCardType NOLOCK 
		WHERE (CardType_Name = @strName )
		
		--set @intCount = 0
		IF @intCount = 0 
		BEGIN
			
			Declare @strCompanyCode nvarchar(50)
			select @strCompanyCode = POSUser_CompanyCode from tblPOSUser where POSUser_Code = @strUserCode

			INSERT INTO tblCardType
			(CardType_Name, CardType_Rate, CardType_Status, CardType_CreatedBy, CardType_CreatedDate)
			VALUES (
			@strName,@dblRate,@intStatus,@strUsercode,GETDATE())

			SELECT @ID = SCOPE_IDENTITY()

		END
		ELSE
		BEGIN
			RAISERROR ('Error: card type name already registred, Please try another name.',16,1);  
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
