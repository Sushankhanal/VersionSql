/****** Object:  Table [dbo].[tblCounter]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCounter](
	[Counter_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Counter_Code] [nvarchar](50) NULL,
	[Counter_BranchCode] [nvarchar](50) NULL,
	[Counter_Name] [nvarchar](50) NULL,
	[Counter_Cashless] [smallint] NOT NULL,
	[Counter_Status] [smallint] NOT NULL,
	[Counter_CompanyCode] [nvarchar](50) NULL,
	[Counter_ReceiptPrinterName] [nvarchar](50) NULL,
	[Counter_KitchenPrinterName] [nvarchar](50) NULL,
	[Counter_Sync] [smallint] NOT NULL,
	[Counter_SyncDate] [datetime] NULL,
	[Counter_SST] [money] NOT NULL,
	[Counter_SC] [money] NOT NULL,
	[Counter_Machine_ID] [bigint] NOT NULL,
	[Counter_Machine_Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblCounter] PRIMARY KEY CLUSTERED 
(
	[Counter_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblCounter] ADD  CONSTRAINT [DF_tblCounter_Counter_Cashless]  DEFAULT ((0)) FOR [Counter_Cashless]
ALTER TABLE [dbo].[tblCounter] ADD  CONSTRAINT [DF_tblCounter_Counter_Status]  DEFAULT ((0)) FOR [Counter_Status]
ALTER TABLE [dbo].[tblCounter] ADD  CONSTRAINT [DF_tblCounter_Counter_Sync]  DEFAULT ((0)) FOR [Counter_Sync]
ALTER TABLE [dbo].[tblCounter] ADD  CONSTRAINT [DF_tblCounter_Counter_SST]  DEFAULT ((0)) FOR [Counter_SST]
ALTER TABLE [dbo].[tblCounter] ADD  CONSTRAINT [DF_tblCounter_Counter_SC]  DEFAULT ((0)) FOR [Counter_SC]
ALTER TABLE [dbo].[tblCounter] ADD  CONSTRAINT [DF_tblCounter_Counter_Machine_ID]  DEFAULT ((0)) FOR [Counter_Machine_ID]
ALTER TABLE [dbo].[tblCounter] ADD  CONSTRAINT [DF_tblCounter_Counter_Machine_Name]  DEFAULT ('') FOR [Counter_Machine_Name]
