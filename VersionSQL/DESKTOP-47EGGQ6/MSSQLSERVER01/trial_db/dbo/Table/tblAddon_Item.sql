/****** Object:  Table [dbo].[tblAddon_Item]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblAddon_Item](
	[Addon_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Addon_ItemCode] [varchar](50) NULL,
	[Addon_Desc] [nvarchar](255) NULL,
	[Addon_UnitPrice] [money] NULL,
	[Addon_Status] [smallint] NOT NULL,
	[Addon_CreatedBy] [nvarchar](50) NULL,
	[Addon_CreatedDate] [datetime] NULL,
	[Addon_Cost] [money] NOT NULL,
	[Addon_CompanyCode] [nvarchar](50) NOT NULL,
	[Addon_Sync] [smallint] NOT NULL,
	[Addon_SyncDate] [datetime] NULL,
 CONSTRAINT [PK_tblAddon_Item] PRIMARY KEY CLUSTERED 
(
	[Addon_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblAddon_Item] ADD  CONSTRAINT [DF_tblAddon_Item_Product_Status]  DEFAULT ((0)) FOR [Addon_Status]
ALTER TABLE [dbo].[tblAddon_Item] ADD  CONSTRAINT [DF_tblAddon_Item_Product_Cost]  DEFAULT ((0)) FOR [Addon_Cost]
ALTER TABLE [dbo].[tblAddon_Item] ADD  CONSTRAINT [DF_tblAddon_Item_Addon_CompanyCode]  DEFAULT ('') FOR [Addon_CompanyCode]
ALTER TABLE [dbo].[tblAddon_Item] ADD  CONSTRAINT [DF_tblAddon_Item_Addon_Sync]  DEFAULT ((0)) FOR [Addon_Sync]
