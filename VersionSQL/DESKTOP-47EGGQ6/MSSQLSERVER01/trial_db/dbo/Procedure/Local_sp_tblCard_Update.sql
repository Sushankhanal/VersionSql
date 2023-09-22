/****** Object:  Procedure [dbo].[Local_sp_tblCard_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec sp_tblCard_Update 0,'00112233445566',1,0,'','',0,''
CREATE PROCEDURE [dbo].[Local_sp_tblCard_Update]
	-- Add the parameters for the stored procedure here
	@ID		int ,
	@strSerialNo	nvarchar(50),
	@intType	smallint,
	@intStatus	smallint,
	@strOwnerName	nvarchar(50),
	@strOwnerMobile	nvarchar(50),
	@intOwnerGender	smallint,
	@strUsercode	nvarchar(50),
	@CardId             bigint = NULL OUTPUT

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Update tblCard Set
		Card_SerialNo = @strSerialNo, Card_Sync = 0, Card_Type = @intType,Card_Level = @intType
		Where Card_ID = @ID
		set @CardId=@ID

		DECLARE @intCount INT
		SELECT @intCount = ISNULL(COUNT(CardOwner_ID), 0) FROM tblCardOwner NOLOCK 
		WHERE (CardOwner_CardSerialNo = @strSerialNo )
		
		--set @intCount = 0
		--IF @intCount = 0 
		--BEGIN
		--	INSERT INTO tblCardOwner
		--	(CardOwner_CardSerialNo, CardOwner_Name, CardOwner_MobileNumber, CardOwner_Gender)
		--	VALUES (@strSerialNo,@strOwnerName,@strOwnerMobile,@intOwnerGender)
		--END
		--ELSE
		--BEGIN
		--	Update tblCardOwner
		--	SET CardOwner_Name = @strOwnerName, CardOwner_MobileNumber = @strOwnerMobile, CardOwner_Gender = @intOwnerGender
		--	where CardOwner_CardSerialNo = @strSerialNo

		--END

		
	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
