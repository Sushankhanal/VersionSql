/****** Object:  Table [dbo].[tblPayment_Details]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPayment_Details](
	[PaymentD_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PaymentD_ReceiptNo] [nvarchar](50) NULL,
	[PaymentD_ItemCode] [varchar](50) NULL,
	[PaymentD_UOM] [nvarchar](50) NULL,
	[PaymentD_UnitPrice] [money] NULL,
	[PaymentD_DiscountPercent] [float] NULL,
	[PaymentD_DiscountAmt] [money] NULL,
	[PaymentD_NetAmount] [money] NULL,
	[PaymentD_TransDate] [datetime] NULL,
	[PaymentD_Qty] [int] NULL,
	[PaymentD_CreatedDate] [datetime] NULL,
	[PaymentD_UnitCost] [money] NOT NULL,
	[PaymentD_TaxCode] [nvarchar](50) NULL,
	[PaymentD_TaxRate] [money] NOT NULL,
	[PaymentD_TaxAmt] [money] NOT NULL,
	[PaymentD_RunNo] [int] NOT NULL,
	[PaymentD_DiscountMode] [smallint] NOT NULL,
	[PaymentD_ItemName] [nvarchar](255) NOT NULL,
	[PaymentD_ItemNameChi] [nvarchar](255) NOT NULL,
	[PaymentD_PrinterName] [nvarchar](50) NOT NULL,
	[PaymentD_DeviceCode] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblPayment_Details] PRIMARY KEY CLUSTERED 
(
	[PaymentD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPayment_Details] ADD  CONSTRAINT [DF_Table_1_UnitCost]  DEFAULT ((0)) FOR [PaymentD_UnitCost]
ALTER TABLE [dbo].[tblPayment_Details] ADD  CONSTRAINT [DF_Table_1_TaxRate_1]  DEFAULT ((0)) FOR [PaymentD_TaxRate]
ALTER TABLE [dbo].[tblPayment_Details] ADD  CONSTRAINT [DF_Table_1_TaxAmt]  DEFAULT ((0)) FOR [PaymentD_TaxAmt]
ALTER TABLE [dbo].[tblPayment_Details] ADD  CONSTRAINT [DF_tblPayment_Details_PaymentD_RunNo]  DEFAULT ((0)) FOR [PaymentD_RunNo]
ALTER TABLE [dbo].[tblPayment_Details] ADD  CONSTRAINT [DF_tblPayment_Details_PaymentD_DiscountMode]  DEFAULT ((0)) FOR [PaymentD_DiscountMode]
ALTER TABLE [dbo].[tblPayment_Details] ADD  CONSTRAINT [DF_tblPayment_Details_PaymentD_ItemName]  DEFAULT ('') FOR [PaymentD_ItemName]
ALTER TABLE [dbo].[tblPayment_Details] ADD  CONSTRAINT [DF_tblPayment_Details_PaymentD_ItemNameChi]  DEFAULT ('') FOR [PaymentD_ItemNameChi]
ALTER TABLE [dbo].[tblPayment_Details] ADD  CONSTRAINT [DF_tblPayment_Details_PaymentD_PrinterName]  DEFAULT ('') FOR [PaymentD_PrinterName]
ALTER TABLE [dbo].[tblPayment_Details] ADD  CONSTRAINT [DF_tblPayment_Details_PaymentD_DeviceCode]  DEFAULT ('') FOR [PaymentD_DeviceCode]
