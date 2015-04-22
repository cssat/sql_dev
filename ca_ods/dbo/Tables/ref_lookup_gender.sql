CREATE TABLE [dbo].[ref_lookup_gender] (
    [pk_gndr] INT          NOT NULL,
    [cd_gndr] VARCHAR (1)  NOT NULL,
    [tx_gndr] VARCHAR (10) NOT NULL,
    CONSTRAINT [ct_pk_gndr] PRIMARY KEY CLUSTERED ([pk_gndr] ASC)
);

