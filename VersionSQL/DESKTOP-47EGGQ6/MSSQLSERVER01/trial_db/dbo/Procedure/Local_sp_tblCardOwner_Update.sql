/****** Object:  Procedure [dbo].[Local_sp_tblCardOwner_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Local_sp_tblCardOwner_Update]
	-- Add the parameters for the stored procedure here
	@intID		int ,
	@strFirstName		nvarchar(50), 
	@strMobileNumber	nvarchar(50), 
	@intGender			int, 
	@strMembership		nvarchar(50), 
	@strIC				nvarchar(50), 
	@strAddress			nvarchar(500),
	@strFamilyName		nvarchar(50), 
	@intCountry		int, 
	@intStatus			int, 
	@intLevel			int, 
	@dtDOB				nvarchar(50), 
	@strEmail			nvarchar(50), 
	@intIDType			int, 
	@strRemarks			nvarchar(500), 
	@intBarred			int, 
	@strBarredReason	nvarchar(255),
	@strCreatedBy		int,
	@strCardNumber		nvarchar(50) = '',
	@strCardPin			nvarchar(50)  = '' OUT,
	@strPic				nvarchar(max) ='',
	@CardOwnerId        bigint = NULL OUTPUT,
	@CardId             bigint = NULL OUTPUT

AS
BEGIN
	BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		Update tblCardOwner Set
		CardOwner_Name = @strFirstName, CardOwner_MobileNumber = @strMobileNumber, CardOwner_Gender = @intGender, 
		CardOwner_Membership = @strMembership, CardOwner_IC = @strIC, CardOwner_Address = @strAddress, 
		CardOwner_UpdatedBy = @strCreatedBy, CardOwner_UpdateDate = GETDATE(), 
		CardOwner_FamilyName = @strFamilyName, CardOwner_Country_ID = @intCountry, CardOwner_Status = @intStatus, CardOwner_Level = @intLevel, 
		CardOwner_Email = @strEmail, CardOwner_IDType = @intIDType, CardOwner_Remarks = @strRemarks, CardOwner_Barred = @intBarred, 
		CardOwner_BarredReason = @strBarredReason
		Where CardOwner_ID = @intID
		set @CardOwnerId=@intID
		
			if @dtDOB <> ''
			BEGIN
				update tblCardOwner set CardOwner_DOB = @dtDOB where CardOwner_ID = @intID
				set @CardId=@intID
			END

		if @strPic <> ''
			BEGIN
				update tblCardOwner set CardOwner_Pic = @strPic where CardOwner_ID = @intID
				set @CardId=@intID
			END

	If @@ERROR <> 0 GoTo ErrorHandler

	COMMIT TRANSACTION
	SET NOCOUNT OFF
	RETURN (0)

ErrorHandler:
	ROLLBACK TRANSACTION
	RETURN (@@ERROR)
END
