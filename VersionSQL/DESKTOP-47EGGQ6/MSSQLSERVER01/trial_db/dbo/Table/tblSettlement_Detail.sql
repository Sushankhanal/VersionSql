/****** Object:  Table [dbo].[tblSettlement_Detail]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblSettlement_Detail](
	[SettlePayment_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SettlePayment_Code] [nvarchar](50) NULL,
	[SettlePayment_PayMode] [nvarchar](50) NULL,
	[SettlePayment_Amt] [money] NOT NULL,
 CONSTRAINT [PK_tblSettlement_Detail] PRIMARY KEY CLUSTERED 
(
	[SettlePayment_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblSettlement_Detail] ADD  CONSTRAINT [DF_Table_1_SettlePayment_Mat]  DEFAULT ((0)) FOR [SettlePayment_Amt]
