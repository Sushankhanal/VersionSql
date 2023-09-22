/****** Object:  Table [dbo].[tblPaymentMode]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPaymentMode](
	[PaymentMode_ID] [int] NOT NULL,
	[PaymentMode_Name] [nvarchar](50) NULL,
	[PaymentMode_AbleRefund] [smallint] NOT NULL,
	[PaymentMode_Order] [int] NOT NULL,
	[PaymentMode_Wallet] [smallint] NOT NULL,
	[PaymentMode_ColorCode] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblPaymentMode] PRIMARY KEY CLUSTERED 
(
	[PaymentMode_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPaymentMode] ADD  CONSTRAINT [DF_tblPaymentMode_PaymentMode_AbleRefund]  DEFAULT ((0)) FOR [PaymentMode_AbleRefund]
ALTER TABLE [dbo].[tblPaymentMode] ADD  CONSTRAINT [DF_tblPaymentMode_PaymentMode_Order]  DEFAULT ((0)) FOR [PaymentMode_Order]
ALTER TABLE [dbo].[tblPaymentMode] ADD  CONSTRAINT [DF_tblPaymentMode_PaymentMode_Wallet]  DEFAULT ((0)) FOR [PaymentMode_Wallet]
ALTER TABLE [dbo].[tblPaymentMode] ADD  CONSTRAINT [DF_tblPaymentMode_PaymentMode_ColorCode]  DEFAULT ('') FOR [PaymentMode_ColorCode]
