/****** Object:  Table [dbo].[tblAddon_Set]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblAddon_Set](
	[AddOnSet_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[AddOnSet_GroupCode] [nvarchar](50) NULL,
	[AddOnSet_ItemCode] [nvarchar](50) NULL,
	[AddOnSet_CreatedBy] [nvarchar](50) NULL,
	[AddOnSet_CreatedDate] [datetime] NULL,
	[AddOnSet_CompanyCode] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblAddon_Set] PRIMARY KEY CLUSTERED 
(
	[AddOnSet_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblAddon_Set] ADD  CONSTRAINT [DF_tblAddon_Set_AddOnSet_CompanyCode]  DEFAULT ('') FOR [AddOnSet_CompanyCode]
