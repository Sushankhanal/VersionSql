/****** Object:  Table [dbo].[tblAddon_Group]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblAddon_Group](
	[AddonGroup_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[AddonGroup_Code] [varchar](50) NULL,
	[AddonGroup_Desc] [nvarchar](255) NULL,
	[AddonGroup_Status] [smallint] NOT NULL,
	[AddonGroup_CreatedBy] [nvarchar](50) NULL,
	[AddonGroup_CreatedDate] [datetime] NULL,
	[AddonGroup_CompanyCode] [nvarchar](50) NOT NULL,
	[AddonGroup_Sync] [smallint] NOT NULL,
	[AddonGroup_SyncDate] [datetime] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[tblAddon_Group] ADD  CONSTRAINT [DF_Table_1_Addon_Status]  DEFAULT ((0)) FOR [AddonGroup_Status]
ALTER TABLE [dbo].[tblAddon_Group] ADD  CONSTRAINT [DF_tblAddon_Group_AddonGroup_CompanyCode]  DEFAULT ('') FOR [AddonGroup_CompanyCode]
ALTER TABLE [dbo].[tblAddon_Group] ADD  CONSTRAINT [DF_tblAddon_Group_AddonGroup_Sync]  DEFAULT ((0)) FOR [AddonGroup_Sync]
