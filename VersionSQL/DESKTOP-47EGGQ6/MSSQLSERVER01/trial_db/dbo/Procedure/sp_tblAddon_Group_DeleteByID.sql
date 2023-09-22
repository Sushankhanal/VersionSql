/****** Object:  Procedure [dbo].[sp_tblAddon_Group_DeleteByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblAddon_Group_DeleteByID]
	-- Add the parameters for the stored procedure here
	@ID		bigint,
	@strUsercode		nvarchar(50)

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @strItemCode nvarchar(50)
	SELECT @strItemCode = AddonGroup_Code FROM tblAddon_Group WHERE AddonGroup_ID = @ID 

	DECLARE @intCount INT
		--SELECT @intCount = ISNULL(COUNT(PaymentEx_ID), 0) FROM tblPayment_Extra NOLOCK 
		--WHERE (PaymentEx_ItemCode = @strItemCode )
		set @intCount = 0
		IF @intCount = 0 
		BEGIN
			Delete from tblAddon_Group WHERE AddonGroup_ID = @ID
		END
		ELSE
		BEGIN
			RAISERROR ('Add OnItem Group in used with another record(s)',16,1);  
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
