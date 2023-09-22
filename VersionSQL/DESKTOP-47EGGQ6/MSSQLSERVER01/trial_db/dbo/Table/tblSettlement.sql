/****** Object:  Table [dbo].[tblSettlement]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblSettlement](
	[Settlement_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Settlement_Date] [datetime] NULL,
	[Settlement_Code] [nvarchar](50) NULL,
	[Settlement_GrossAmt] [money] NULL,
	[Settlement_GlobalDiscountAmt] [money] NULL,
	[Settlement_NetAmt] [money] NULL,
	[Settlement_RoundUp] [money] NULL,
	[Settlement_FinalAmt] [money] NULL,
	[Settlement_CashCount] [int] NOT NULL,
	[Settlement_CreditCount] [int] NOT NULL,
	[Settlement_RefundAmt] [money] NULL,
	[Settlement_CreatedDate] [datetime] NULL,
	[Settlement_CashierCode] [nvarchar](50) NOT NULL,
	[Settlement_CounterCode] [varchar](50) NULL,
	[Settlement_InitialCash] [money] NOT NULL,
	[Settlement_CashAmt] [money] NOT NULL,
	[Settlement_CreditCardAmt] [money] NOT NULL,
	[Settlement_CashierCash] [money] NOT NULL,
	[Settlement_Remarks] [nvarchar](255) NULL,
	[Settlement_AdjustmentAmt] [money] NOT NULL,
	[Settlement_TotalTaxAmt] [money] NOT NULL,
	[Settlement_AlipayAmt] [money] NOT NULL,
	[Settlement_WechatpayAmt] [money] NOT NULL,
	[Settlement_UnionpayAmt] [money] NOT NULL,
	[Settlement_WalletAmt] [money] NOT NULL,
	[Settlement_WalletCount] [money] NOT NULL,
	[Settlement_ItemDiscountAmt] [money] NOT NULL,
	[Settlement_Sync] [smallint] NOT NULL,
	[Settlement_SyncDate] [datetime] NULL,
	[Settlement_TopUpAmt] [money] NOT NULL,
	[Settlement_TopUpReturnAmt] [money] NOT NULL,
	[Settlement_DepositAmt] [money] NOT NULL,
	[Settlement_DepositReturnAmt] [money] NOT NULL,
	[Settlement_ServiceCharges] [money] NOT NULL,
 CONSTRAINT [PK_tblSettlement] PRIMARY KEY CLUSTERED 
(
	[Settlement_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_CashCount]  DEFAULT ((0)) FOR [Settlement_CashCount]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_CreditCount]  DEFAULT ((0)) FOR [Settlement_CreditCount]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_CashierCode]  DEFAULT ((0)) FOR [Settlement_CashierCode]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_InitialCash]  DEFAULT ((0)) FOR [Settlement_InitialCash]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_CashAmt]  DEFAULT ((0)) FOR [Settlement_CashAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_CreditCardAmt]  DEFAULT ((0)) FOR [Settlement_CreditCardAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_CashierCash]  DEFAULT ((0)) FOR [Settlement_CashierCash]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_Remarks]  DEFAULT ('') FOR [Settlement_Remarks]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_AdjustmentAmt]  DEFAULT ((0)) FOR [Settlement_AdjustmentAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_TotalTaxAmt]  DEFAULT ((0)) FOR [Settlement_TotalTaxAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_AlipayAmt]  DEFAULT ((0)) FOR [Settlement_AlipayAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_WechatpayAmt]  DEFAULT ((0)) FOR [Settlement_WechatpayAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_UnionpayAmt]  DEFAULT ((0)) FOR [Settlement_UnionpayAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_WalletAmt]  DEFAULT ((0)) FOR [Settlement_WalletAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_WalletCount]  DEFAULT ((0)) FOR [Settlement_WalletCount]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_ItemDiscountAmt]  DEFAULT ((0)) FOR [Settlement_ItemDiscountAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_Sync]  DEFAULT ((0)) FOR [Settlement_Sync]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_TopUpAmt]  DEFAULT ((0)) FOR [Settlement_TopUpAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_TopUpReturnAmt]  DEFAULT ((0)) FOR [Settlement_TopUpReturnAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_DepositAmt]  DEFAULT ((0)) FOR [Settlement_DepositAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_DepositReturnAmt]  DEFAULT ((0)) FOR [Settlement_DepositReturnAmt]
ALTER TABLE [dbo].[tblSettlement] ADD  CONSTRAINT [DF_tblSettlement_Settlement_ServiceCharges]  DEFAULT ((0)) FOR [Settlement_ServiceCharges]
