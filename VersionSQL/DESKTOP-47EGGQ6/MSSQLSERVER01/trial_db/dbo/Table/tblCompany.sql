/****** Object:  Table [dbo].[tblCompany]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tblCompany](
	[Company_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Company_Code] [nvarchar](50) NULL,
	[Company_Name] [nvarchar](50) NULL,
	[Company_RegNo] [nvarchar](50) NULL,
	[Company_Address1] [nvarchar](50) NULL,
	[Company_Address2] [nvarchar](50) NULL,
	[Company_City] [nvarchar](50) NULL,
	[Company_Postcode] [nvarchar](50) NULL,
	[Company_State] [int] NULL,
	[Company_RegDate] [datetime] NULL,
	[Company_Status] [smallint] NOT NULL,
	[Company_Img] [nvarchar](50) NOT NULL,
	[Company_Theme] [nvarchar](50) NOT NULL,
	[Company_SST] [money] NOT NULL,
	[Company_SC] [money] NOT NULL,
	[Company_MasterPrinter] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblCompany] PRIMARY KEY CLUSTERED 
(
	[Company_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[tblCompany] ADD  CONSTRAINT [DF_tblCompany_Company_Status]  DEFAULT ((0)) FOR [Company_Status]
ALTER TABLE [dbo].[tblCompany] ADD  CONSTRAINT [DF_tblCompany_Company_Img]  DEFAULT ('') FOR [Company_Img]
ALTER TABLE [dbo].[tblCompany] ADD  CONSTRAINT [DF_tblCompany_Company_Theme]  DEFAULT ('') FOR [Company_Theme]
ALTER TABLE [dbo].[tblCompany] ADD  CONSTRAINT [DF_tblCompany_Company_SST]  DEFAULT ((0)) FOR [Company_SST]
ALTER TABLE [dbo].[tblCompany] ADD  CONSTRAINT [DF_tblCompany_Company_SC]  DEFAULT ((0)) FOR [Company_SC]
ALTER TABLE [dbo].[tblCompany] ADD  CONSTRAINT [DF_tblCompany_Company_MasterPrinter]  DEFAULT ('') FOR [Company_MasterPrinter]
