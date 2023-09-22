/****** Object:  Table [dbo].[tblPayment_Extra]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblPayment_Extra](
	[PaymentEx_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PaymentEx_ReceiptNo] [nvarchar](50) NULL,
	[PaymentEx_RunNo] [int] NOT NULL,
	[PaymentEx_ItemCode] [nvarchar](50) NULL,
	[PaymentEx_ItemDesc] [nvarchar](50) NOT NULL,
	[PaymentEx_AddOnPrice] [money] NOT NULL,
	[PaymentEx_CreatedBy] [nvarchar](50) NULL,
	[PaymentEx_CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_tblPayment_Extra] PRIMARY KEY CLUSTERED 
(
	[PaymentEx_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblPayment_Extra] ADD  CONSTRAINT [DF_tblPayment_Extra_PaymentEx_DID]  DEFAULT ((0)) FOR [PaymentEx_RunNo]
ALTER TABLE [dbo].[tblPayment_Extra] ADD  CONSTRAINT [DF_tblPayment_Extra_PaymentEx_AddOnSetID]  DEFAULT ((0)) FOR [PaymentEx_ItemDesc]
ALTER TABLE [dbo].[tblPayment_Extra] ADD  CONSTRAINT [DF_tblPayment_Extra_PaymentEx_AddOnPrice]  DEFAULT ((0)) FOR [PaymentEx_AddOnPrice]
