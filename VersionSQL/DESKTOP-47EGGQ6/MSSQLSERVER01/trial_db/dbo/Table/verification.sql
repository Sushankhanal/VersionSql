/****** Object:  Table [dbo].[verification]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[verification](
	[verification_id] [bigint] IDENTITY(1,1) NOT NULL,
	[verification_code] [nvarchar](50) NULL,
	[verification_createdon] [datetime] NULL,
	[verification_verify] [int] NOT NULL,
	[verification_type] [int] NOT NULL,
	[verification_mobileno] [nvarchar](50) NULL,
	[verification_verifiedon] [datetime] NULL,
	[verification_key] [nvarchar](1024) NULL,
 CONSTRAINT [PK_verification] PRIMARY KEY CLUSTERED 
(
	[verification_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[verification] ADD  CONSTRAINT [DF_verification_verification_verify]  DEFAULT ((0)) FOR [verification_verify]
ALTER TABLE [dbo].[verification] ADD  CONSTRAINT [DF_verification_verification_type]  DEFAULT ((0)) FOR [verification_type]
