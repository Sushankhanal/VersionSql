/****** Object:  Table [dbo].[tblProductCategory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblProductCategory](
	[ProCategory_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProCategory_Code] [nvarchar](50) NULL,
	[ProCategory_Name] [nvarchar](255) NULL,
	[ProCategory_Status] [smallint] NULL,
	[ProCategory_CounterCode] [nvarchar](50) NULL,
	[ProCategory_CreatedBy] [nvarchar](50) NULL,
	[ProCategory_CreatedDate] [datetime] NULL,
	[ProCategory_Img] [image] NULL,
	[ProCategory_CompanyCode] [nvarchar](50) NOT NULL,
	[ProCategory_Sync] [smallint] NOT NULL,
	[ProCategory_SyncDate] [datetime] NULL,
	[ProCategory_Order] [int] NOT NULL,
	[ProCategory_Group] [int] NOT NULL,
	[ProCategory_ImgPath] [nvarchar](50) NOT NULL,
	[ProCategory_Desc] [nvarchar](500) NOT NULL,
	[ProCategory_ChiName] [nvarchar](255) NULL,
 CONSTRAINT [PK_tblProductCategory] PRIMARY KEY CLUSTERED 
(
	[ProCategory_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[tblProductCategory] ADD  CONSTRAINT [DF_tblProductCategory_ProCategory_Status]  DEFAULT ((0)) FOR [ProCategory_Status]
ALTER TABLE [dbo].[tblProductCategory] ADD  CONSTRAINT [DF_tblProductCategory_ProCategory_CompanyCode]  DEFAULT ('') FOR [ProCategory_CompanyCode]
ALTER TABLE [dbo].[tblProductCategory] ADD  CONSTRAINT [DF_tblProductCategory_ProCategory_Sync]  DEFAULT ((0)) FOR [ProCategory_Sync]
ALTER TABLE [dbo].[tblProductCategory] ADD  CONSTRAINT [DF_tblProductCategory_ProCategory_Order]  DEFAULT ((0)) FOR [ProCategory_Order]
ALTER TABLE [dbo].[tblProductCategory] ADD  CONSTRAINT [DF_tblProductCategory_ProCategoryGroup]  DEFAULT ((0)) FOR [ProCategory_Group]
ALTER TABLE [dbo].[tblProductCategory] ADD  CONSTRAINT [DF_tblProductCategory_ProCategory_ImgPath]  DEFAULT ('') FOR [ProCategory_ImgPath]
ALTER TABLE [dbo].[tblProductCategory] ADD  CONSTRAINT [DF_tblProductCategory_ProCategory_Desc]  DEFAULT ('') FOR [ProCategory_Desc]
ALTER TABLE [dbo].[tblProductCategory] ADD  CONSTRAINT [DF_tblProductCategory_ProCategory_ChiName]  DEFAULT ('') FOR [ProCategory_ChiName]
