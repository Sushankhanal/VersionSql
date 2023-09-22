/****** Object:  Table [dbo].[tblTable]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblTable](
	[Table_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Table_Code] [nvarchar](50) NULL,
	[Table_Name] [nvarchar](50) NULL,
	[Table_CreatedDate] [datetime] NULL,
	[Table_CreatedBy] [nvarchar](50) NULL,
	[Table_CompanyCode] [nvarchar](50) NULL,
	[Table_Sync] [smallint] NOT NULL,
	[Table_SyncDate] [datetime] NULL,
	[Table_Status] [smallint] NOT NULL,
	[Table_isCalling] [smallint] NOT NULL,
	[Table_Order] [int] NOT NULL,
 CONSTRAINT [PK_tblTable] PRIMARY KEY CLUSTERED 
(
	[Table_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblTable] ADD  CONSTRAINT [DF_tblTable_Table_Sync]  DEFAULT ((0)) FOR [Table_Sync]
ALTER TABLE [dbo].[tblTable] ADD  CONSTRAINT [DF_tblTable_Table_Status]  DEFAULT ((0)) FOR [Table_Status]
ALTER TABLE [dbo].[tblTable] ADD  CONSTRAINT [DF_tblTable_Table_isCalling]  DEFAULT ((0)) FOR [Table_isCalling]
ALTER TABLE [dbo].[tblTable] ADD  CONSTRAINT [DF_tblTable_Table_Order]  DEFAULT ((0)) FOR [Table_Order]
