/****** Object:  Procedure [dbo].[sp_tblProduct_DeleteByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_tblProduct_DeleteByID]
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
	SELECT @strItemCode = Product_ItemCode FROM tblProduct WHERE Product_ID = @ID 

	DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(PaymentD_ID), 0) FROM tblPayment_Details NOLOCK 
		WHERE (PaymentD_ItemCode = @strItemCode )

		IF @intCount = 0 
		BEGIN
			Delete from tblProduct WHERE Product_ID = @ID
			delete from tblProductCounter WHERE ProductCounter_ProductCode = @strItemCode
		END
		ELSE
		BEGIN
			RAISERROR ('Item Code in used with another record(s)',16,1);  
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
