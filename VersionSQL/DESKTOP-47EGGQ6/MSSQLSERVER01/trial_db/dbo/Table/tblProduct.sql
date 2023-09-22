/****** Object:  Table [dbo].[tblProduct]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblProduct](
	[Product_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Product_ItemCode] [varchar](50) NULL,
	[Product_Desc] [nvarchar](255) NULL,
	[Product_UOM] [nvarchar](50) NOT NULL,
	[Product_UnitPrice] [money] NULL,
	[Product_Bal] [int] NOT NULL,
	[Product_Status] [smallint] NOT NULL,
	[Product_CreatedBy] [nvarchar](50) NULL,
	[Product_CreatedDate] [datetime] NULL,
	[Product_Discount] [float] NOT NULL,
	[Product_Cost] [money] NOT NULL,
	[Product_CategoryCode] [nvarchar](50) NOT NULL,
	[Product_MemberPrice] [money] NOT NULL,
	[Product_SupplierID] [bigint] NOT NULL,
	[Product_TaxCode] [nvarchar](50) NOT NULL,
	[Product_TaxRate] [money] NOT NULL,
	[Product_CounterCode] [nvarchar](50) NULL,
	[Product_CompanyCode] [nvarchar](50) NULL,
	[Product_img] [image] NULL,
	[Product_WalletsTransType] [int] NOT NULL,
	[Product_AddonGroup] [nvarchar](50) NULL,
	[Product_BranchCode] [nvarchar](50) NOT NULL,
	[Product_UpdatedBy] [nvarchar](50) NULL,
	[Product_UpdatedDate] [datetime] NULL,
	[Product_Sync] [smallint] NOT NULL,
	[Product_SyncDate] [datetime] NULL,
	[Product_PrinterName] [nvarchar](50) NOT NULL,
	[Product_ChiDesc] [nvarchar](100) NOT NULL,
	[Product_UnitPrice2] [money] NOT NULL,
	[Product_ImgPath] [nvarchar](50) NOT NULL,
	[Product_Desc2] [nvarchar](255) NOT NULL,
	[Product_ChiDesc2] [nvarchar](255) NOT NULL,
	[Product_FullDesc] [nvarchar](50) NOT NULL,
	[Product_HalfDesc] [nvarchar](50) NOT NULL,
	[Product_Remarks] [nvarchar](50) NOT NULL,
	[Product_RemarksChi] [nvarchar](50) NOT NULL,
	[Product_ImgExtra] [nvarchar](50) NOT NULL,
	[Product_FinanceGroup] [int] NOT NULL,
 CONSTRAINT [PK_tblProduct] PRIMARY KEY CLUSTERED 
(
	[Product_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Table_1_UOM]  DEFAULT ((0)) FOR [Product_UOM]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Table_1_ProdBal]  DEFAULT ((0)) FOR [Product_Bal]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_Status]  DEFAULT ((0)) FOR [Product_Status]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Table_1_Discount]  DEFAULT ((0)) FOR [Product_Discount]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Table_1_Cost]  DEFAULT ((0)) FOR [Product_Cost]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Table_1_CategoryID]  DEFAULT ((0)) FOR [Product_CategoryCode]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Table_1_MemberPrice]  DEFAULT ((0)) FOR [Product_MemberPrice]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Table_1_SupplierID]  DEFAULT ((0)) FOR [Product_SupplierID]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Table_1_TaxCode]  DEFAULT ('') FOR [Product_TaxCode]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_Table_1_TaxRate]  DEFAULT ((0)) FOR [Product_TaxRate]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_Sign]  DEFAULT ((-1)) FOR [Product_WalletsTransType]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_AddonGroup]  DEFAULT ('') FOR [Product_AddonGroup]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_BranchCode]  DEFAULT ('') FOR [Product_BranchCode]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_Sync]  DEFAULT ((0)) FOR [Product_Sync]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_PrinterName]  DEFAULT ('') FOR [Product_PrinterName]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_ChiDesc]  DEFAULT ('') FOR [Product_ChiDesc]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_UnitPrice2]  DEFAULT ((0)) FOR [Product_UnitPrice2]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_ImgPath]  DEFAULT ('') FOR [Product_ImgPath]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_Desc2]  DEFAULT ('') FOR [Product_Desc2]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_Desc21]  DEFAULT ('') FOR [Product_ChiDesc2]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_FullDesc]  DEFAULT ('') FOR [Product_FullDesc]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_HalfDesc]  DEFAULT ('') FOR [Product_HalfDesc]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_Remarks]  DEFAULT ('') FOR [Product_Remarks]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_RemarksChi]  DEFAULT ('') FOR [Product_RemarksChi]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_ImgExtra]  DEFAULT ('') FOR [Product_ImgExtra]
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_Product_FinanceGroup]  DEFAULT ((1)) FOR [Product_FinanceGroup]
