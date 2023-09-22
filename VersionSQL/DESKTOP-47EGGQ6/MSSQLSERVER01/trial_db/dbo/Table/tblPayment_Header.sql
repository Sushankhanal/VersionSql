/****** Object:  Table [dbo].[tblPayment_Header]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPayment_Header](
	[Payment_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Payment_ReceiptNo] [varchar](50) NULL,
	[Payment_Date] [datetime] NULL,
	[Payment_GrossAmt] [money] NULL,
	[Payment_DiscountAmt] [float] NULL,
	[Payment_NetAmt] [money] NULL,
	[Payment_RoundUp] [money] NULL,
	[Payment_FinalAmt] [money] NULL,
	[Payment_CounterCode] [varchar](50) NULL,
	[Payment_PaymentType] [int] NULL,
	[Payment_PayAmt] [money] NULL,
	[Payment_ReturnAmt] [money] NULL,
	[Payment_Status] [int] NULL,
	[Payment_CreatedDate] [datetime] NULL,
	[Payment_CardNumber] [varchar](50) NULL,
	[Payment_CardType] [varchar](50) NULL,
	[Payment_RefundCode] [nvarchar](50) NOT NULL,
	[Payment_UserCode] [nvarchar](50) NOT NULL,
	[Payment_GlobalDiscount] [float] NOT NULL,
	[Payment_GlobalDiscountAmt] [money] NOT NULL,
	[Payment_AdjustmentAmt] [money] NOT NULL,
	[Payment_IsSettlement] [bigint] NOT NULL,
	[Payment_TotalTaxAmt] [money] NOT NULL,
	[Payment_IsRefund] [smallint] NOT NULL,
	[Payment_CreatedBy] [nvarchar](50) NULL,
	[Payment_Remarks] [nvarchar](50) NULL,
	[Payment_RedeemAmt] [money] NOT NULL,
	[Payment_RedeemPoint] [money] NOT NULL,
	[Payment_DiscountMode] [smallint] NOT NULL,
	[Payment_CollectionCode] [nvarchar](50) NOT NULL,
	[Payment_SettleCode] [nvarchar](50) NULL,
	[Payment_Sync] [smallint] NOT NULL,
	[Payment_SyncDate] [datetime] NULL,
	[Payment_TableCode] [nvarchar](50) NOT NULL,
	[Payment_Pax] [int] NOT NULL,
	[Payment_CompanyCode] [nvarchar](50) NOT NULL,
	[Payment_SST] [money] NOT NULL,
	[Payment_SC] [money] NOT NULL,
	[Payment_OrderNumber] [nvarchar](50) NOT NULL,
	[Payment_SyncLocalID] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tblPayment_header] PRIMARY KEY CLUSTERED 
(
	[Payment_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_Table_1_RefundID]  DEFAULT ((0)) FOR [Payment_RefundCode]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_Table_1_UserID]  DEFAULT ((0)) FOR [Payment_UserCode]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_Table_1_GlobalDiscount]  DEFAULT ((0)) FOR [Payment_GlobalDiscount]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_Table_1_GlobalDiscountAmt]  DEFAULT ((0)) FOR [Payment_GlobalDiscountAmt]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_Table_1_AdjustmentAmt]  DEFAULT ((0)) FOR [Payment_AdjustmentAmt]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_Table_1_IsSettlement]  DEFAULT ((0)) FOR [Payment_IsSettlement]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_Table_1_TotalTaxAmt]  DEFAULT ((0)) FOR [Payment_TotalTaxAmt]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_IsRefund]  DEFAULT ((0)) FOR [Payment_IsRefund]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_RedeemAmt]  DEFAULT ((0)) FOR [Payment_RedeemAmt]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_RedeemPoint]  DEFAULT ((0)) FOR [Payment_RedeemPoint]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_DiscountMode]  DEFAULT ((0)) FOR [Payment_DiscountMode]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_CollectionCode]  DEFAULT ('') FOR [Payment_CollectionCode]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_Sync]  DEFAULT ((0)) FOR [Payment_Sync]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_TableCode]  DEFAULT ('') FOR [Payment_TableCode]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_PaxINT]  DEFAULT ((0)) FOR [Payment_Pax]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_CompanyCode]  DEFAULT ('') FOR [Payment_CompanyCode]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_SST]  DEFAULT ((0)) FOR [Payment_SST]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_SC]  DEFAULT ((0)) FOR [Payment_SC]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_OrderNumber]  DEFAULT ('') FOR [Payment_OrderNumber]
ALTER TABLE [dbo].[tblPayment_Header] ADD  CONSTRAINT [DF_tblPayment_Header_Payment_SyncLocalID]  DEFAULT ('RESERVED5'+ltrim(rtrim(str(ident_current('POSv2..tblPayment_Header'))))) FOR [Payment_SyncLocalID]
