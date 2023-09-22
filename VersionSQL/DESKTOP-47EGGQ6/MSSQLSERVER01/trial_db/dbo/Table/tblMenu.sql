/****** Object:  Table [dbo].[tblMenu]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblMenu](
	[ID] [int] NOT NULL,
	[PageName] [varchar](200) NOT NULL,
	[PageUrl] [varchar](200) NOT NULL,
	[PageDescription] [varchar](1000) NOT NULL,
	[PageIcon] [varchar](500) NOT NULL,
	[PageOrder] [int] NOT NULL,
	[ChildPageOrder] [int] NOT NULL,
	[ParentPageId] [int] NOT NULL,
	[IsHeader] [bit] NOT NULL,
	[HasSub] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreateBy] [varchar](200) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateBy] [varchar](200) NOT NULL,
	[UpdateOn] [datetime] NOT NULL,
 CONSTRAINT [PK_tblMenu] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_PageName]  DEFAULT ('') FOR [PageName]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_PageUrl]  DEFAULT ('') FOR [PageUrl]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_PageDescription]  DEFAULT ('') FOR [PageDescription]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_PageIcon]  DEFAULT ('') FOR [PageIcon]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_PageOrder]  DEFAULT ((0)) FOR [PageOrder]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_ChildPageOrder]  DEFAULT ((0)) FOR [ChildPageOrder]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_ParentPageId]  DEFAULT ((0)) FOR [ParentPageId]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_IsHeader]  DEFAULT ((0)) FOR [IsHeader]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_HasSub]  DEFAULT ((0)) FOR [HasSub]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_IsActive]  DEFAULT ((0)) FOR [IsActive]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_CreateBy]  DEFAULT ((0)) FOR [CreateBy]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_CreateDate]  DEFAULT (((1900)/(1))/(1)) FOR [CreateDate]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_UpdateBy]  DEFAULT ((0)) FOR [UpdateBy]
ALTER TABLE [dbo].[tblMenu] ADD  CONSTRAINT [DF_tblMenu_UpdateOn]  DEFAULT (((1900)/(1))/(1)) FOR [UpdateOn]
