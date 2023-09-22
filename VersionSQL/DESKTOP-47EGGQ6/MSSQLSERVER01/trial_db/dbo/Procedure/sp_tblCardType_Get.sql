/****** Object:  Procedure [dbo].[sp_tblCardType_Get]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec sp_tblProduct_get 'COUNTER1','Hallaway01',''
Create PROCEDURE [dbo].[sp_tblCardType_Get] (
	@strCompanyCode	nvarchar(50),
	@intOption		int = 0
) AS
BEGIN
	if @intOption = 0
	BEGIN
		SELECT CardType_ID, CardType_Name, CardType_Rate
		FROM tblCardType
	END
	else if @intOption = 1
	BEGIN
		SELECT CardType_ID, CardType_Name, CardType_Rate, 1 as CardType_Sort
		FROM tblCardType
		UNION
		SELECT -1, 'ALL', 0, 0 as CardType_Sort
		order by CardType_Sort
	END 
	
	
END
