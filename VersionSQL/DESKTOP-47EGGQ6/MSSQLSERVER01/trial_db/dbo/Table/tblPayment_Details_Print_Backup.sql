/****** Object:  Table [dbo].[tblPayment_Details_Print_Backup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPayment_Details_Print_Backup](
	[PaymentD_ID] [bigint] NOT NULL,
	[PaymentD_ReceiptNo] [nvarchar](50) NULL,
	[PaymentD_ItemCode] [varchar](50) NULL,
	[PaymentD_UOM] [nvarchar](50) NULL,
	[PaymentD_TransDate] [datetime] NULL,
	[PaymentD_Qty] [int] NULL,
	[PaymentD_CreatedDate] [datetime] NULL,
	[PaymentD_RunNo] [int] NOT NULL,
	[PaymentD_Status] [nvarchar](50) NOT NULL,
	[PaymentD_PrintStatus] [smallint] NOT NULL,
	[PaymentD_Detail_ID] [bigint] NOT NULL,
	[PaymentD_CompanyCode] [nvarchar](50) NOT NULL,
	[PaymentD_ItemName] [nvarchar](255) NOT NULL,
	[PaymentD_ItemNameChi] [nvarchar](50) NOT NULL,
	[PaymentD_PrinterName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblPayment_Details_Print_Backup] PRIMARY KEY CLUSTERED 
(
	[PaymentD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPayment_Details_Print_Backup] ADD  CONSTRAINT [DF_tblPayment_Details_Print_Backup_PaymentD_RunNo]  DEFAULT ((0)) FOR [PaymentD_RunNo]
ALTER TABLE [dbo].[tblPayment_Details_Print_Backup] ADD  CONSTRAINT [DF_tblPayment_Details_Print_Backup_PaymentD_Status]  DEFAULT ('') FOR [PaymentD_Status]
ALTER TABLE [dbo].[tblPayment_Details_Print_Backup] ADD  CONSTRAINT [DF_tblPayment_Details_Print_Backup_PaymentD_PrintStatus]  DEFAULT ((0)) FOR [PaymentD_PrintStatus]
ALTER TABLE [dbo].[tblPayment_Details_Print_Backup] ADD  CONSTRAINT [DF_tblPayment_Details_Print_Backup_PaymentD_Detail_ID]  DEFAULT ((0)) FOR [PaymentD_Detail_ID]
ALTER TABLE [dbo].[tblPayment_Details_Print_Backup] ADD  CONSTRAINT [DF_tblPayment_Details_Print_Backup_PaymentD_CompanyCode]  DEFAULT ('') FOR [PaymentD_CompanyCode]
ALTER TABLE [dbo].[tblPayment_Details_Print_Backup] ADD  CONSTRAINT [DF_tblPayment_Details_Print_Backup_PaymentD_ItemName]  DEFAULT ('') FOR [PaymentD_ItemName]
ALTER TABLE [dbo].[tblPayment_Details_Print_Backup] ADD  CONSTRAINT [DF_tblPayment_Details_Print_Backup_PaymentD_ItemNameChi]  DEFAULT ('') FOR [PaymentD_ItemNameChi]
ALTER TABLE [dbo].[tblPayment_Details_Print_Backup] ADD  CONSTRAINT [DF_tblPayment_Details_Print_Backup_PaymentD_PrinterName]  DEFAULT ('') FOR [PaymentD_PrinterName]
