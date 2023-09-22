/****** Object:  Table [dbo].[tblPayment_Order]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPayment_Order](
	[Payment_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Payment_ReceiptNo] [varchar](50) NULL,
	[Payment_Date] [datetime] NULL,
	[Payment_GrossAmt] [money] NULL,
	[Payment_DiscountAmt] [float] NULL,
	[Payment_NetAmt] [money] NULL,
	[Payment_RoundUp] [money] NULL,
	[Payment_FinalAmt] [money] NULL,
	[Payment_CounterCode] [varchar](50) NULL,
	[Payment_Status] [int] NULL,
	[Payment_CreatedDate] [datetime] NULL,
	[Payment_UserCode] [nvarchar](50) NOT NULL,
	[Payment_TotalTaxAmt] [money] NOT NULL,
	[Payment_CreatedBy] [nvarchar](50) NULL,
	[Payment_Remarks] [nvarchar](50) NULL,
	[Payment_CollectionCode] [nvarchar](50) NULL,
	[Payment_TableCode] [nvarchar](50) NOT NULL,
	[Payment_Pax] [int] NOT NULL,
	[Payment_CompanyCode] [nvarchar](50) NOT NULL,
	[Payment_SST] [money] NOT NULL,
	[Payment_SC] [money] NOT NULL,
	[Payment_DiscountMode] [smallint] NOT NULL,
	[Payment_GlobalDiscount] [float] NOT NULL,
	[Payment_GlobalDiscountAmt] [money] NOT NULL,
 CONSTRAINT [PK_tblPayment_Order] PRIMARY KEY CLUSTERED 
(
	[Payment_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_Order_Payment_UserCode]  DEFAULT ((0)) FOR [Payment_UserCode]
ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_Order_Payment_TotalTaxAmt]  DEFAULT ((0)) FOR [Payment_TotalTaxAmt]
ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_Order_Payment_TableCode]  DEFAULT ('') FOR [Payment_TableCode]
ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_Order_Payment_Pax]  DEFAULT ((0)) FOR [Payment_Pax]
ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_Order_Payment_CompanyCode]  DEFAULT ('') FOR [Payment_CompanyCode]
ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_Order_Payment_SST]  DEFAULT ((0)) FOR [Payment_SST]
ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_Order_Payment_SC]  DEFAULT ((0)) FOR [Payment_SC]
ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_Order_Payment_DiscountMode]  DEFAULT ((0)) FOR [Payment_DiscountMode]
ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_OrderGlobalDiscount]  DEFAULT ((0)) FOR [Payment_GlobalDiscount]
ALTER TABLE [dbo].[tblPayment_Order] ADD  CONSTRAINT [DF_tblPayment_OrderGlobalDiscountAmt]  DEFAULT ((0)) FOR [Payment_GlobalDiscountAmt]
